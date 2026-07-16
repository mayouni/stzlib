# R4 step 7 ACCEPTANCE -- the Model Foundry, rung 1: stzDLM
# (5.9 + the DLM ruling): from ONE knowledgebase, a self-contained
# DOMAIN LANGUAGE MODEL -- zero neurons, zero cost, shippable FREE.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: forge from a SCOPED domain brain (no globals) --"
# the domain lives in ITS OWN stzKnowledgeGraph instance -- not the shared
# natural world, not a global StzKnow. A DLM is forged from that object.
oKB = new stzKnowledgeGraph("restaurant")
oKB.Know("margherita", "dish").
    Know("tiramisu", "dish").
    Know("chianti", "wine").
    KnowRelation("margherita", "contains", "tomato-sauce").
    KnowRelation("margherita", "contains", "mozzarella").
    KnowRelation("margherita", "pairs-with", "chianti")

oDLM = StzForgeDLM("restaurant", oKB)
aLex = oDLM.Lexicon()
chk("the lexicon is forged from the graph",
	len(aLex[:entities]) >= 3 and ring_find(aLex[:relations], "contains") > 0)

? ""
? "-- Scene 2: the domain SPEAKS, deterministically --"
chk("types answer", oDLM.Ask("what is margherita?") = "Margherita is a dish.")
chk("relations answer",
	oDLM.Ask("what does margherita contain? (contains)") =
	"Margherita contains tomato-sauce and mozzarella.")
chk("every answer carries its Why", len(StzFind("recorded fact", oDLM.Why())) > 0)

? ""
? "-- Scene 3: outside the domain = HONEST REFUSAL (LAW 3) --"
aX = oDLM.AskXT("what is the weather today?")
chk("out-of-domain refuses, naming the domain's extent",
	aX[:refused] = 1 and len(StzFind("outside", aX[:answer])) > 0)

? ""
? "-- Scene 4: constrained continuation (the grammar spirit) --"
chk("an entity completes with ITS relations",
	ring_find(oDLM.Complete("margherita"), "contains") > 0)
chk("a fragment completes with domain entities",
	oDLM.Complete("tira")[1] = "tiramisu")

? ""
? "-- Scene 5: the rung-2 seed -- facts AS a corpus --"
aC = oDLM.GenerateCorpus()
chk("the corpus renders every fact as a sentence (teacher-free)",
	len(aC) >= 6 and len(StzFind(" is a ", aC[1])) > 0)

? ""
? "-- Scene 6: the bundle is SELF-CONTAINED (*.stzdlm) --"
oDLM.AddGolden("what is margherita", "Margherita is a dish.")
cF = oDLM.Save("t_dlm_accept")
oD2 = StzLoadDLM(cF)
chk("the reloaded DLM answers WITHOUT the original graph",
	oD2.Ask("what is tiramisu") = "Tiramisu is a dish.")
chk("its goldens travel and pass", oD2.RunGoldens()[:passed] = 1)
remove(cF)

? ""
? "-- Scene 7: the domain tokenizer (the neural rung's vocabulary) --"
aV = oDLM.Tokenizer()
chk("the closed domain earns a closed vocabulary (id 1 = <unk>)",
	aV[1] = "<unk>" and len(aV) >= 6)
aIds = oDLM.Tokenize("margherita contains something-new")
chk("known words map to ids; the unknown maps to <unk>",
	aIds[1] > 1 and aIds[3] = 1)

? ""
? "-- Scene 8: RUNG 2 -- the NEURAL bigram LM, trained teacher-free --"
# the knowledgebase became a corpus (Scene 5); now the corpus trains a
# real neural model -- softmax over the domain vocabulary -- with NO
# remote teacher. Rung 1 still owns truth; this rung GENERATES.
oDLM.TrainNeuralRung(500)
chk("the neural rung trains on the DLM's own corpus (no teacher)",
	oDLM.IsNeuralTrained() = TRUE and
	len(StzFind("neural bigram rung", oDLM.NeuralWhy())) > 0)
chk("it LEARNED the deterministic bigram is->a at near-1 confidence",
	oDLM.NextToken("is") = "a" and oDLM.NextTokenConfidence("is") > 0.9)
chk("greedy generation yields domain-valid grammar ('X is a ...')",
	StzLeft(oDLM.NeuralGenerate("tiramisu", 3), 13) = "tiramisu is a")
cG = oDLM.ExportNeuralGguf("t_dlm_bigram")
chk("the trained rung exports as a real .gguf ggml reads back",
	StzEngineNeuralGgufInspect(cG) = 2)
remove(cG)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
