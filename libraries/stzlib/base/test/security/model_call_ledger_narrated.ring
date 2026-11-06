load "../../stzBase.ring"
load "../_narrated.ring"

# COMPASS-KERN-05 ACCEPTANCE -- every model call writes a chained record to the
# security ledger before its answer returns, and no face can switch it off.
#
# The doors were built by stzlib-intelligence (45cb4e675: _StzNeuralDoor; the
# image plane's _StzVisionDoor since IM3). This guard is the security plane's
# acceptance: it asks the Compass's own question -- stzLLMAgent first -- and then
# tries every switch a face holds. Needs the two small models; set STZ_MODELS_DIR
# when they are not in libraries/stzlib/models.

cModels = sysget("STZ_MODELS_DIR")
if cModels = ""  cModels = "../../../models"  ok
cGen = cModels + "/smollm2-135m-instruct-q8_0.gguf"
cEmb = cModels + "/all-MiniLM-L6-v2.Q8_0.gguf"
if NOT fexists(cGen) or NOT fexists(cEmb)
	? "NOT RUN: smollm2-135m-instruct-q8_0.gguf or all-MiniLM-L6-v2.Q8_0.gguf is not in " + cModels
	shutdown(0)
ok

StzNeuralModelQ(cGen)

Scenario("1. stzLLMAgent: one record per model call it makes, written before Propose returns")
	StzCloseSecurityLedger()
	Then("no ledger is open to begin with", StzSecurityLedgerIsOpen(), 0)
	oF = new stzLLMFunction("kern05-summary")
	oF.SetPrompt("Say one word about: {input}")
	oF.ReturnsString()
	oF.Budget(3)
	oA = new stzLLMAgent("kern05-agent")
	oA.SetSkillFrom(oF)
	cOut = oA.Propose("the sea")
	nMade = oA.@oFn.CallsMade()            # the agent holds a COPY of oF (Ring copies objects)
	Then("the agent's model ran at least once", nMade >= 1, 1)
	Then("NUMBER -- model.call records equal model calls made (" + nMade + ")", ModelCalls(), nMade)
	Then("the ledger was opened by the door, not by the caller", StzSecurityLedgerIsOpen(), 1)
	n0 = ModelCalls()
	oA.Propose("the sea")
	Then("a memoized answer runs no model and writes no record", ModelCalls(), n0)
	? "  NUMBER agent: " + ModelCalls() + " record(s) for " + nMade + " model call(s)"
EndScenario()

Scenario("2. no face can switch it off")
	StzCloseSecurityLedger()
	StzGenerate("Hello", 4)
	Then("after StzCloseSecurityLedger, a call reopens the ledger and is recorded", ModelCalls(), 1)
	StzEngineSecLogClearCurrent()
	StzGenerate("Hello", 4)
	Then("after the engine's own slot is cleared, the same", ModelCalls(), 1)
	StzSecurityLedgerQ().SetRefusalBudget(1, 60000)
	n0 = ModelCalls()
	for i = 1 to 3  StzGenerate("Hi " + i, 2)  next
	Then("a refusal budget does not thin model records: 3 calls, 3 records", ModelCalls() - n0, 3)
	Then("the chain verifies", StzSecurityLedgerQ().Verify()[:intact], 1)
EndScenario()

Scenario("3. every model kind, one record each")
	StzCloseSecurityLedger()
	nG = 0
	StzGenerate("One", 2)                  nG++
	StzGenerateXT("Two", [ :MaxTokens = 2 ])  nG++
	StzAskModel("Three?", 2)               nG++
	Then("generation, its options form and a chat question: " + nG + " records", ModelCalls(), nG)
	StzNeuralModelQ(cEmb)
	n0 = ModelCalls()
	StzNeuralEmbeddingOf("a red bus")
	Then("an embedding: one record", ModelCalls() - n0, 1)
	aR = StzSecurityLedgerQ().OfKind("model.call")
	aLast = aR[len(aR)]
	Then("the record names the faculty", StzFindFirst("embed", aLast[:reason]) > 0, 1)
	Then("...and the model's architecture", aLast[:subject] != "", 1)
	? "  NUMBER kinds: " + ModelCalls() + " records for " + (nG + 1) + " calls"
EndScenario()

Summary()
shutdown($_zst_fail)

func ModelCalls()
	if NOT StzSecurityLedgerIsOpen()  return 0  ok
	return len(StzSecurityLedgerQ().OfKind("model.call"))
