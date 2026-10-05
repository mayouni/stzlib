load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-LEDGER-ANCHOR-01 -- threat-model risk R5: a cut tail is seen.
#
# The durable log is a hash chain, and a chain shows an EDIT, never a CUT:
# delete its last rows and what remains still verifies from genesis. Anyone
# holding the file can also rebuild a whole new chain, because the chain has
# no key. An ANCHOR -- the count and head digest at one moment, sent OFF the
# machine -- is what the stored history must still reach. Where the anchor
# goes (an operator, another host, a ticket) is the deployment's choice; the
# library makes it and checks it.

$cDb = "_tmp_ledger_anchor.db"
$cDb2 = "_tmp_ledger_anchor2.db"
CleanDb($cDb)
CleanDb($cDb2)

Scenario("an anchor taken now holds now, and after the log grows")
	oLed = Durable($cDb, 10)
	aA = oLed.Anchor()
	Then("the anchor counts the entries", aA[:count], 10)
	Then("...and has a one-line form to send away", StzLeft(aA[:line], 20), "stzledger-anchor:v1:")
	Then("it holds", oLed.VerifyAgainstAnchor(aA)[:holds], 1)
	Record(oLed, 5)
	Then("it still holds after 5 more entries (negative sibling)", oLed.VerifyAgainstAnchor(aA[:line])[:state], "holds")
	$cLine = aA[:line]
	oLed.Destroy()
EndScenario()

Scenario("a cut tail: the chain alone says intact, the anchor says truncated")
	oDb = new stzDatabase($cDb)
	oDb.Exec("DROP TRIGGER seclog_no_delete")
	oDb.Exec("DELETE FROM seclog WHERE seq > 6")
	oDb.Close()
	oLed = StzSecurityLedger(8)
	Then("the cut file is ACCEPTED as a history -- this is R5", oLed.PersistTo($cDb)[:ok], 1)
	Then("...and verifies from genesis", oLed.VerifyDurable()[:intact], 1)
	aV = oLed.VerifyAgainstAnchor($cLine)
	Then("the anchor sees it", aV[:state], "truncated")
	Then("...and says so", StzFindFirst("its tail was cut", aV[:why]) > 0, 1)
	oLed.Destroy()
EndScenario()

Scenario("a rebuilt history: a whole new chain, just as long")
	oLed = Durable($cDb2, 15)          # 15 different, perfectly chained entries
	aV = oLed.VerifyAgainstAnchor($cLine)
	Then("the new chain verifies on its own", oLed.VerifyDurable()[:intact], 1)
	Then("the anchor says diverged", aV[:state], "diverged")
	oLed.Destroy()
EndScenario()

Scenario("what an anchor cannot check is said, not guessed")
	oLed = StzSecurityLedger(8)
	Then("a ledger with no file", oLed.VerifyAgainstAnchor($cLine)[:state], "not-durable")
	Then("a line that is not an anchor", oLed.VerifyAgainstAnchor("stzledger-anchor:v1:ten:abc")[:state], "malformed")
	oLed.Destroy()
EndScenario()

CleanDb($cDb)
CleanDb($cDb2)
Summary()

# -- helpers (after the main code) ------------------------------------

func Durable cPath, n
	oL = StzSecurityLedger(4)
	oL.PersistTo(cPath)
	Record(oL, n)
	return oL

func Record oL, n
	for i = 1 to n
		oL.Record(StzSecurityRefusal("auth.login.failed", HumanActor("user-" + i), "user:u" + i, "bad password #" + i))
	next

func CleanDb cPath
	acSuffix = [ "", "-wal", "-shm", "-journal" ]
	for i = 1 to 4
		if fexists(cPath + acSuffix[i])  remove(cPath + acSuffix[i])  ok
	next
