load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-R18b, the seclog half -- an engine DLL writes its model.call record
# itself, before it returns, without passing any Ring function.
#
# The model doors (COMPASS-KERN-05) are Ring functions, so a direct
# StzEngineNeural* call passed none of them. stz_seclog now exports
# stz_seclog_door_fact, and seclog_door.zig lets any engine DLL find it. The
# consumer here is the test-support DLL (stz_testsrv), standing where stz_neural
# will stand: its StzEngineTestSrvDoorProbe is a model-shaped call that never
# touches Ring's ledger code. Wiring stz_neural itself is stzlib-intelligence's.

Scenario("1. a call from another DLL writes its record, and opens the ledger to do it")
	StzCloseSecurityLedger()
	Then("no ledger is open", StzSecurityLedgerIsOpen(), 0)
	n0 = StzEngineSecLogDoorRecords()
	Then("the probe reports its record written", StzEngineTestSrvDoorProbe("llama", "generate: 12 tokens"), 1)
	Then("the ENGINE opened the process ledger", StzSecurityLedgerIsOpen(), 1)
	Then("...and Ring reads it like any other: one record", DoorRecords(), 1)
	aR = StzSecurityLedgerQ().OfActor("stzEngineDoorProbe")[1]
	Then("kind model.call", aR[:kind], "model.call")
	Then("severity info, outcome observed -- the shape StzNoteFact writes",
		aR[:severity] + "/" + aR[:outcome], "info/observed")
	Then("the subject and what ran", aR[:subject] + " -- " + aR[:reason], "llama -- generate: 12 tokens")
	Then("a wall time from the engine clock", aR[:atWall] > 1700000000000, 1)
	Then("the seclog side counted it", StzEngineSecLogDoorRecords() - n0, 1)
EndScenario()

Scenario("2. one record per call, and no switch turns it off")
	n0 = DoorRecords()
	for i = 1 to 50  StzEngineTestSrvDoorProbe("llama", "call " + i)  next
	Then("NUMBER -- 50 calls, records written", DoorRecords() - n0, 50)
	Then("NUMBER -- calls whose record could not be written", StzEngineTestSrvDoorMissed(), 0)
	StzCloseSecurityLedger()
	StzEngineTestSrvDoorProbe("llama", "after close")
	Then("after StzCloseSecurityLedger, the next call reopens it", DoorRecords(), 1)
	StzEngineSecLogClearCurrent()
	StzEngineTestSrvDoorProbe("llama", "after clear")
	Then("after the engine slot is cleared, the same", DoorRecords(), 1)
	? "  NUMBER engine door: 50 of 50 calls recorded, " + StzEngineTestSrvDoorMissed() + " missed"
EndScenario()

Scenario("3. engine and Ring records share one chain")
	StzCloseSecurityLedger()
	StzEngineTestSrvDoorProbe("llama", "engine side")
	StzNoteFact("model.call", "stzNeuralModel", "llama", "ring side")
	StzEngineTestSrvDoorProbe("a|b", "pipe|inside")
	oL = StzSecurityLedgerQ()
	Then("three records, in call order", oL.Count(), 3)
	Then("the chain verifies across both writers", oL.Verify()[:intact], 1)
	aLast = oL.OfActor("stzEngineDoorProbe")[2]
	Then("a bar inside a field is folded, so the line splits back into 12 fields",
		aLast[:subject] + " / " + aLast[:reason], "a/b / pipe/inside")
	StzCloseSecurityLedger()
	Then("a ledger the engine opened closes like any other", StzSecurityLedgerIsOpen(), 0)
EndScenario()

Summary()

func DoorRecords()
	if NOT StzSecurityLedgerIsOpen()  return 0  ok
	return len(StzSecurityLedgerQ().OfActor("stzEngineDoorProbe"))
