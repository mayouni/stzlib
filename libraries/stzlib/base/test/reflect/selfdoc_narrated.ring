load "../../stzBase.ring"
load "../_narrated.ring"

# SELF-DESCRIBING OBJECTS (stzSelfDoc, base/reflect/). Harvests a class's methods
# + doc-comments straight from source, then answers plain-English questions about
# them (Ask) and explains them (ExplainMethod) -- powered by the neural tier's
# embeddings, NOT a heavy LLM. Near-natural programming: describe intent, get the
# operation. Deterministic; the knowledge lives in the library's own source.

Scenario("Harvest + explain a class from its source (deterministic, no model)")
	o = StzSelfDocQ("stzText")
	Then("resolves the class to its source file",
		o.Source() != "", TRUE)
	Then("harvests the public methods from source",
		o.NumberOfMethods() >= 100, TRUE)
	Then("knows a method it has",
		o.HasMethod("Classify"), TRUE)
	Then("and rejects one it doesn't",
		o.HasMethod("NoSuchThing"), FALSE)
	Then("ExplainMethod returns the real doc-comment",
		substr(o.ExplainMethod("Classify"), "labels") > 0, TRUE)
	Then("DescriptionOf a documented method is non-empty",
		len(o.DescriptionOf("Classify")) > 0, TRUE)
	Then("a class can also be opened by source path",
		StzSelfDocQ("linguistic/stzText.ring").ClassName(), "stzText")
EndScenario()

Scenario("Ask: near-natural method discovery")
	# Model-free here (lexical fallback), so this asserts STRUCTURE + that results
	# are real methods. With an embedding model the ranking is semantic -- see the
	# manual note. The escape hatch for the long tail of "how do I ...?".
	o = StzSelfDocQ("stzText")
	r = o.Ask("find the named entities in the text")
	Then("Ask returns up to 3 [name, score, description] triples",
		len(r) = 3 and len(r[1]) = 3, TRUE)
	Then("each answer names a real method of the class",
		o.HasMethod(r[1][1]), TRUE)
	Then("BestMethodFor returns a single real method name",
		o.HasMethod(o.BestMethodFor("detect the language")), TRUE)
	# MANUAL (with an embedding model -- StzNeuralModelQ(minilm.gguf)):
	#   o.Ask("detect the language")                 -> DetectedLanguage / Language
	#   o.Ask("classify into topics without training") -> Classify
	#   o.Ask("how positive or negative is the tone") -> IsPositive / IsNegative
	#   o.Ask("names of people and places")          -> PersonNames / Locations
	# 22M embedder, instant on CPU, deterministic, zero hallucination -- no LLM.
EndScenario()

Scenario("stzLibDoc: cross-class method discovery")
	# Harvests MANY classes into one index, so Ask() spans the whole (curated)
	# library and the answer names the CLASS a method lives in -- fixing the
	# single-class blind spot (e.g. a text query whose method is on stzListOfTexts).
	# Harvest is inheritance-aware: each method is attributed to the class that
	# DEFINES it, so the 2 curated classes pool methods from their ancestors too
	# (stzText + stzListOfTexts + inherited stzStringList/stzListOfStrings = 4 owners).
	o = StzLibDocQ([ "stzText", "stzListOfTexts" ])
	Then("harvests across classes (owners span the inheritance chain)",
		o.NumberOfClasses(), 4)
	Then("with all their methods pooled",
		o.NumberOfEntries() >= 120, TRUE)
	r = o.AskFor("rank documents for a query", 3)
	Then("Ask returns [class, method, score, description] quadruples",
		len(r) = 3 and len(r[1]) = 4, TRUE)
	Then("BestMethodFor returns a class.method string",
		substr(o.BestMethodFor("rank documents for a query"), ".") > 0, TRUE)
	# MANUAL (embedding model): "sort documents by relevance to a query" ->
	#   stzListOfTexts.RankedForQuery (the method the SINGLE-class stzText missed).
	# MANUAL (reranker model, e.g. jina): the lexical-narrow-then-cross-encode path
	#   scales to a big corpus with no index -- StzLibDocQ(["stzText","stzList",
	#   "stzNumber"]).Ask("most relevant document") -> stzListOfTexts.MostRelevantTo.
EndScenario()

Scenario("Q(obj).Ask() -- any object describes ITSELF")
	# Doc()/Ask()/ExplainMethod() live on stzObject (-> stzString/stzList/stzNumber)
	# and stzStringText/stzStringList (-> stzText/stzListOfTexts), so any Softanza
	# object can answer questions about its own methods. Model-free lexical here.
	on = new stzNumber(5)
	Then("a number finds its square-root method by description",
		on.AskFor("compute the square root", 1)[1][1], "SquareRoot")
	ot = new stzText("The cat runs")
	Then("a text finds its language method",
		ot.AskFor("detect the language", 1)[1][1], "Language")
	Then("ExplainMethod works off the object",
		substr(ot.ExplainMethod("Classify"), "labels") > 0, TRUE)
	olt = new stzListOfTexts([ "a", "b" ])
	Then("a list-of-texts finds its relevance-ranking method",
		olt.AskFor("rank documents by relevance", 1)[1][1], "RankedForQuery")
	ol = new stzList([ 1, 2, 3 ])
	Then("a list can open its own doc",
		ol.Doc().NumberOfMethods() >= 100, TRUE)
	# A class whose FILE name != class name still resolves (content scan):
	Then("stzListOfStrings resolves (lives in stzStringList.ring)",
		StzSelfDocQ("stzListOfStrings").NumberOfMethods() >= 50, TRUE)
	# MANUAL (embedding model): Q("...").TextQ().Ask("closest sentence by meaning")
	#   -> MostSimilarSentenceTo; ranking is semantic, not just word overlap.
EndScenario()

Summary()
