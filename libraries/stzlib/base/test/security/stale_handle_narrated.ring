load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-R16-01 -- a copy of a destroyed engine object cannot reach freed memory.
#
# Read against PHP2Shell (CVE-2026-109618/9) on 2026-10-22: Ring copies objects,
# and an engine-backed object's copy kept its handle after Destroy() freed the
# engine side. Measured on Ring 1.27 and Ring++: the copy of a destroyed ledger
# answered 1, then 0 once the memory was reused -- freed memory read, no error.
# The engine's handle table had the same hole in a quieter form: a released slot
# is reused, and an old id then named ANOTHER object. Every slot now carries a
# generation, every id carries it too, and a release bumps it.

Scenario("a destroyed ledger's copy raises instead of reading freed memory")
	oA = StzSecurityLedger(8)
	oA.Record(StzSecurityRefusal("auth.login.failed", HumanActor("x"), "user:x", "no"))
	oB = oA
	Then("before: both faces read the same ledger", "" + oA.Count() + "/" + oB.Count(), "1/1")
	oA.Destroy()
	for i = 1 to 50  oC = StzSecurityLedger(8)  oC.Count()  next   # reuse the freed slots
	cErr = ""
	try  oB.Count()  catch  cErr = cCatchError  done
	Then("the copy raises", cErr != "", 1)
	Then("...saying the object was destroyed", StzFindFirst("was destroyed", cErr) > 0, 1)
EndScenario()

Scenario("a stale copy cannot free the object that now owns the slot")
	oA = StzSecurityLedger(8)
	oB = oA
	oA.Destroy()
	oN = StzSecurityLedger(8)                  # may land in oA's old slot
	oN.Record(StzSecurityRefusal("auth.login.failed", HumanActor("y"), "user:y", "no"))
	try  oB.Destroy()  catch  done            # the stale copy tries to free
	Then("the new ledger is untouched", oN.Count(), 1)
EndScenario()

Scenario("an ordinary object is unaffected (negative sibling)")
	oL = StzSecurityLedger(8)
	oL.Record(StzSecurityRefusal("auth.login.failed", HumanActor("z"), "user:z", "no"))
	oM = oL
	Then("a copy of a LIVE ledger reads it", oM.Count(), 1)
	oL.Destroy()
	o2 = StzSecurityLedger(4)
	Then("a fresh ledger works after a destroy", o2.Count(), 0)
	s1 = new stzString("hello")
	s2 = s1
	Then("strings, which share the table, still work", s2.Uppercased(), "HELLO")
EndScenario()

Scenario("the same holds for the other engine objects moved onto the table")
	pC = StzEngineCircuitCreate(3, 1000)
	pC2 = pC                                   # a Ring copy of the handle
	Then("a circuit breaker answers while it lives", StzEngineCircuitCanPass(pC2), 1)
	StzEngineCircuitDestroy(pC)
	for i = 1 to 20  pX = StzEngineCircuitCreate(3, 1000)  next     # reuse the freed slots
	cErr = ""
	try  StzEngineCircuitCanPass(pC2)  catch  cErr = cCatchError  done
	Then("its copy raises after the destroy", StzFindFirst("circuit breaker was destroyed", cErr) > 0, 1)
	Then("a NULL handle is still just NULL, not an error", StzEngineCircuitCanPass(NULL) = 0 or StzEngineCircuitCanPass(NULL) = 1, 1)
EndScenario()

Scenario("the process ledger keeps one id")
	StzOpenSecurityLedger(16)
	Then("two faces of the process ledger see the same entries",
		StzSecurityLedgerQ().Count() = StzSecurityLedgerQ().Count(), 1)
	StzNoteRefusal("auth.login.failed", "w", "user:w", "no")
	Then("...and a refusal reaches it", StzSecurityLedgerQ().Count(), 1)
	StzCloseSecurityLedger()
	Then("closing it closes it", StzSecurityLedgerIsOpen(), 0)
EndScenario()

Summary()
