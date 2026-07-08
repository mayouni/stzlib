load "../../stzBase.ring"
load "../_narrated.ring"

# SEMANTIC-RETRIEVAL probe -- the neural counterpart of ask_probe. It runs ONLY
# when a neural embedding model is present in libraries/stzlib/models/ (a *.gguf,
# gitignored -- so CI without one skips gracefully). It asserts that the EMBEDDING
# path resolves phrasings with NO lexical/aka overlap with the method -- the value
# the neural tier adds over the zero-setup lexical floor guarded by ask_probe.

if StzAutoLoadNeuralModel()

	o = new stzSelfDoc("stzText")

	Scenario("Embedding retrieval resolves unseen phrasings (no lexical overlap)")
		Then("'gauge the emotional tone of the writing' -> Sentiment",
			o.AskFor("gauge the emotional tone of the writing", 1)[1][1], "Sentiment")
		Then("'pull out the key ideas' -> KeyPhrases",
			o.AskFor("pull out the key ideas", 1)[1][1], "KeyPhrases")
		Then("'who are the individuals referenced' -> an entity method",
			ring_find([ "EntitiesOfType","PersonNames","NamedEntities","Entities" ],
				o.AskFor("who are the individuals referenced", 1)[1][1]) > 0, TRUE)
	EndScenario()

	Scenario("Semantic similarity separates related from unrelated meanings")
		Then("happy ~ joyful  >  happy ~ table",
			StzSemanticSimilarity("happy", "joyful") > StzSemanticSimilarity("happy", "table"), TRUE)
		Then("a text is highly similar to itself",
			StzSemanticSimilarity("the cat sat", "the cat sat") > 0.98, TRUE)
	EndScenario()

	Summary()

else
	? nl + "SKIPPED: no neural model in libraries/stzlib/models/ (drop a *.gguf to enable)."
	? "The lexical floor is guarded by ask_probe_narrated.ring; this probe adds the"
	? "semantic layer that needs a runtime embedding model."
ok
