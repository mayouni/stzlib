# R4 step 7 ACCEPTANCE -- the Model Foundry, rung 1: stzDLM
# (5.9 + the DLM ruling): from ONE knowledgebase, a self-contained
# DOMAIN LANGUAGE MODEL -- zero neurons, zero cost, shippable FREE.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: forge from the brain (compose-and-go) --"
StzKnow("margherita", "dish")
StzKnow("tiramisu", "dish")
StzKnow("chianti", "wine")
StzKnowRelation("margherita", "contains", "tomato-sauce")
StzKnowRelation("margherita", "contains", "mozzarella")
StzKnowRelation("margherita", "pairs-with", "chianti")

oDLM = StzForgeDLM("restaurant")
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
