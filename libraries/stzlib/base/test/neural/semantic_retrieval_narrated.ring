load "../../stzBase.ring"
load "../_narrated.ring"

# SEMANTIC-RETRIEVAL probe -- the neural counterpart of ask_probe. It runs ONLY
# when a neural model is present in libraries/stzlib/models/ (a *.gguf, gitignored
# -- so CI without one skips gracefully). It asserts that the NEURAL paths resolve
# phrasings with NO lexical/aka overlap with the method -- the value the neural
# tier adds over the zero-setup lexical floor guarded by ask_probe. Two paths:
#   - EMBEDDING (bi-encoder cosine over a cached vector index)
#   - RERANKER  (retrieve-then-rerank: lexical top-25 pool, cross-encoded)
# whichever model(s) are present. Same query set -> both should resolve them.

bRan = FALSE

# --- EMBEDDING path (whatever auto-loads, unless it's a reranker) ---
if StzAutoLoadNeuralModel() and NOT StzHasRerankerModel()
	RunSemanticScenarios("embedding")
	Scenario("[embedding] semantic similarity separates meanings")
		Then("happy ~ joyful  >  happy ~ table",
			StzSemanticSimilarity("happy", "joyful") > StzSemanticSimilarity("happy", "table"), TRUE)
	EndScenario()
	bRan = TRUE
ok

# --- RERANKER path (cross-encoder), if a reranker GGUF is present ---
cRr = FindModel("rerank")
if cRr != ""
	StzUseNeuralModel(cRr)
	if StzHasRerankerModel()
		RunSemanticScenarios("reranker")
		Scenario("[reranker] cross-encoder orders relevant above irrelevant")
			r = StzRerank("how do I reverse a string",
				[ "Compute the average of a list of numbers", "Reverse the characters of the string" ])
			Then("the relevant doc ranks first",
				r[1][1], "Reverse the characters of the string")
		EndScenario()
		bRan = TRUE
	ok
ok

if bRan
	Summary()
else
	? nl + "SKIPPED: no neural model in libraries/stzlib/models/ (drop a *.gguf to enable)."
	? "The lexical floor is guarded by ask_probe_narrated.ring; this probe adds the"
	? "embedding + reranker layers that need a runtime model."
ok

#-- helpers ---------------------------------------------------------------
func RunSemanticScenarios cLabel
	o = new stzSelfDoc("stzText")
	Scenario("[" + cLabel + "] resolves unseen phrasings (no lexical overlap)")
		Then("'gauge the emotional tone of the writing' -> Sentiment",
			o.AskFor("gauge the emotional tone of the writing", 1)[1][1], "Sentiment")
		Then("'pull out the key ideas' -> KeyPhrases",
			o.AskFor("pull out the key ideas", 1)[1][1], "KeyPhrases")
		Then("'who are the individuals referenced' -> an entity method",
			ring_find([ "EntitiesOfType","PersonNames","NamedEntities","Entities" ],
				o.AskFor("who are the individuals referenced", 1)[1][1]) > 0, TRUE)
	EndScenario()

# a *.gguf in models/ whose name contains pcNeedle, else "".
func FindModel pcNeedle
	d = StzModelsDir()
	if d = "" or NOT direxists(d) return "" ok
	aE = dir(d)
	for i = 1 to len(aE)
		if aE[i][2] = 0 and right(lower(aE[i][1]), 5) = ".gguf" and
		   substr(lower(aE[i][1]), pcNeedle) > 0
			return d + "/" + aE[i][1]
		ok
	next
	return ""
