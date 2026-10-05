load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-DURABLE-LOG-01 -- HaroBase rung 2: the security ledger's chain
# is written, continuously, to an insert-only store and verified on load.
#
# The ledger is a bounded ring: past capacity the oldest events give way,
# Verify() can only vouch for the window that remains, and a process that
# stops takes its evidence with it. PersistTo(path) writes every event --
# in the engine's own lock, so disk order is chain order -- to an SQLite
# table whose triggers refuse UPDATE and DELETE, carrying the same chained
# digest. Re-attaching replays the stored chain FROM GENESIS and refuses a
# history with an edited or missing row.
#
# There is no failing-before here in the usual sense: before this rung
# the ledger had NO durable form at all (PersistTo did not exist), which
# is the gap the scenarios below close.

$cDb = "_tmp_durable_ledger.db"
$cDb2 = "_tmp_durable_ledger2.db"
CleanDb($cDb)
CleanDb($cDb2)

Scenario("a small ring keeps a durable history of everything")
	oLed = StzSecurityLedger(4)
	aV = oLed.PersistTo($cDb)
	Then("the ledger becomes durable", aV[:ok], 1)
	Then("a new file starts empty", aV[:verified], 0)
	for i = 1 to 10
		oLed.Record(StzSecurityRefusal("auth.login.failed", HumanActor("user-" + i), "user:u" + i, "bad password #" + i))
	next
	Then("the ring still holds only its window (4)", oLed.Size(), 4)
	Then("Count() says 10 were recorded", oLed.Count(), 10)
	Then("the WHOLE stored chain verifies from genesis", oLed.VerifyDurable()[:intact], 1)
	cHead = oLed.Digest()
	oLed.Destroy()
EndScenario()

Scenario("a restarted process resumes the same chain")
	oLed = StzSecurityLedger(4)
	aV = oLed.PersistTo($cDb)
	Then("the stored history is accepted", aV[:ok], 1)
	Then("all 10 entries were verified on the way in", aV[:verified], 10)
	Then("the count carries over", oLed.Count(), 10)
	Then("the head digest is the one the old process ended on", oLed.Digest(), cHead)
	oLed.Record(StzSecurityRefusal("sig.nonce.replayed", HumanActor("peer-3"), "key:billing", "nonce already used"))
	Then("recording continues the chain (11)", oLed.Count(), 11)
	Then("and the stored chain is still intact", oLed.VerifyDurable()[:intact], 1)
	bRaised = 0
	try  oLed.Reset()  catch  bRaised = 1  done
	Then("a durable ledger refuses Reset()", bRaised, 1)
	oLed.Destroy()
EndScenario()

Scenario("the store is insert-only")
	oDb = new stzDatabase($cDb)
	bRaised = 0
	try  oDb.Exec("UPDATE seclog SET canonical = 'x' WHERE seq = 2")  catch  bRaised = 1  done
	Then("an UPDATE is refused", bRaised, 1)
	bRaised = 0
	try  oDb.Exec("DELETE FROM seclog WHERE seq = 2")  catch  bRaised = 1  done
	Then("a DELETE is refused", bRaised, 1)
	Then("all 11 rows are still there", oDb.Value("SELECT COUNT(*) FROM seclog"), "11")
	oDb.Close()
EndScenario()

Scenario("an EDITED row is caught on load, and the history refused")
	Given("an attacker who owns the file: drops the trigger, rewrites row 3")
	oDb = new stzDatabase($cDb)
	oDb.Exec("DROP TRIGGER seclog_no_update")
	oDb.ExecWith("UPDATE seclog SET canonical = ? WHERE seq = 3", [ "auth.login.failed|nothing to see" ])
	oDb.Close()
	oLed = StzSecurityLedger(4)
	aV = oLed.PersistTo($cDb)
	Then("the history is refused", aV[:ok], 0)
	Then("the break is named at entry 3", aV[:brokenAt], 3)
	Then("nothing was attached", oLed.IsDurable(), 0)
	Then("and the ledger holds none of the forged history", oLed.Count(), 0)
	oLed.Destroy()
EndScenario()

Scenario("a DELETED row is caught too -- a gap is a break")
	oLed = StzSecurityLedger(8)
	oLed.PersistTo($cDb2)
	for i = 1 to 5
		oLed.Record(StzSecurityRefusal("secret.reveal.refused", HumanActor("a" + i), "secret:s", "denied"))
	next
	oLed.Destroy()
	oDb = new stzDatabase($cDb2)
	oDb.Exec("DROP TRIGGER seclog_no_delete")
	oDb.Exec("DELETE FROM seclog WHERE seq = 2")
	oDb.Close()
	oLed = StzSecurityLedger(8)
	aV = oLed.PersistTo($cDb2)
	Then("the history is refused", aV[:ok], 0)
	Then("the gap is named at entry 2", aV[:brokenAt], 2)
	oLed.Destroy()
EndScenario()

Scenario("a ledger that already recorded cannot be made durable")
	oLed = StzSecurityLedger(8)
	oLed.Record(StzSecurityRefusal("auth.login.failed", HumanActor("x"), "user:x", "no"))
	aV = oLed.PersistTo($cDb2 + ".other")
	Then("refused: two histories would be spliced", aV[:ok], 0)
	oLed.Destroy()
	CleanDb($cDb2 + ".other")
EndScenario()

Scenario("the PROCESS ledger can be durable, so the seams' refusals persist")
	CleanDb($cDb2)
	oPL = StzOpenDurableSecurityLedger(16, $cDb2)
	Then("the process ledger is open and durable", StzSecurityLedgerIsOpen() and oPL.IsDurable(), 1)
	StzEngineSecLogCurrentAppend("secret.reveal.refused|seam|test", StzEngineTimeWallMs(), 2)
	Then("a seam's append reached it", oPL.Count(), 1)
	Then("and the disk", oPL.VerifyDurable()[:intact], 1)
	StzCloseSecurityLedger()
EndScenario()

CleanDb($cDb)
CleanDb($cDb2)

Summary()

func CleanDb cPath
	acSuffix = [ "", "-wal", "-shm", "-journal" ]
	for i = 1 to 4
		if fexists(cPath + acSuffix[i])  remove(cPath + acSuffix[i])  ok
	next
