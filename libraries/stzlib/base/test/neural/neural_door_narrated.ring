# EVERY LANGUAGE-MODEL CALL IS A RECORD -- narrated (COMPASS-KERN-05)
#
# Kern's lesson, routed by the Compass: every model call writes a chained
# record to the security ledger BEFORE its answer returns, and no face can
# switch it off. The image plane's door has done this since IM3; this guard
# proves the language models' door (_StzNeuralDoor, stzNeuralModel.ring):
#
#   Scene 1  generate, option probabilities, streaming, chat -- one record each
#   Scene 2  embeddings, through every face that embeds
#   Scene 3  the records: who, what, and a chain that verifies
#
# NEEDS the small models in models/ (smollm2-135m, all-MiniLM-L6-v2); when
# absent the guard says which and stops.

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$cModels = "../../../models/"

if NOT fexists($cModels + "smollm2-135m-instruct-q8_0.gguf") or NOT fexists($cModels + "all-MiniLM-L6-v2.Q8_0.gguf")
	? "NOT RUN: smollm2-135m-instruct-q8_0.gguf or all-MiniLM-L6-v2.Q8_0.gguf is not in " + $cModels
	shutdown(1)
ok

pr()

? "-- Scene 1: generation --"

StzNeuralModelQ($cModels + "smollm2-135m-instruct-q8_0.gguf")
chk("a generative model is loaded", StzHasGenerativeModel() = 1)

n0 = NeuralRecords()
StzGenerate("The capital of France is", 4)
chk("StzGenerate writes one record", NeuralRecords() = n0 + 1)
chk("...and the door opened the ledger itself: it is open now", StzSecurityLedgerIsOpen() = 1)

n0 = NeuralRecords()
StzOptionProbabilities("Is the sky blue? Answer yes or no:", [ "yes", "no" ])
chk("StzOptionProbabilities writes one record", NeuralRecords() = n0 + 1)

n0 = NeuralRecords()
StzStartGeneration("Count: one, two,", [ :MaxTokens = 4 ])
while StzGenerationActive() = 1
	StzNextToken()
end
chk("a streamed generation writes one record when it starts", NeuralRecords() = n0 + 1)

n0 = NeuralRecords()
oChat = StzNeuralChatQ("")
oChat.Say("Hello")
oChat.Say("And again")
chk("a chat writes one record per turn (2 turns)", NeuralRecords() = n0 + 2)

? ""
? "-- Scene 2: embeddings --"

StzNeuralModelQ($cModels + "all-MiniLM-L6-v2.Q8_0.gguf")
chk("an embedding model is loaded", StzHasNeuralModel() = 1)

n0 = NeuralRecords()
StzSemanticSimilarity("a cat sleeps", "a kitten naps")
chk("StzSemanticSimilarity embeds twice: two records", NeuralRecords() = n0 + 2)

n0 = NeuralRecords()
StzNeuralEmbeddingOf("a red bus")
chk("StzNeuralEmbeddingOf (the semantic index's embedder) writes one record", NeuralRecords() = n0 + 1)

n0 = NeuralRecords()
oIdx = new stzSemanticIndex([])
oIdx.AddTexts([ "bread is baked in an oven", "a compiler turns code into programs" ])
oIdx.SearchXT("how do I bake bread", 1)
chk("a semantic index of 2 texts and 1 query writes 3 records", NeuralRecords() = n0 + 3)

? ""
? "-- Scene 3: the records --"

aR = StzSecurityLedgerQ().OfActor("stzNeuralModel")
aLast = aR[len(aR)]
chk("each record is of kind model.call, by stzNeuralModel", aLast[:kind] = "model.call")
chk("...says which faculty answered (" + aLast[:reason] + ")", StzFindFirst("embed:", aLast[:reason]) = 1)
chk("...and names the model's architecture (" + aLast[:subject] + ")", aLast[:subject] != "")
chk("the ledger's hash chain verifies", StzSecurityLedgerQ().Verify()[:intact] = 1)

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pf()

func NeuralRecords()
	if StzSecurityLedgerIsOpen() = 0
		return 0
	ok
	return len(StzSecurityLedgerQ().OfActor("stzNeuralModel"))

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok
