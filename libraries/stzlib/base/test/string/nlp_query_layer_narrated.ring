load "../../stzBase.ring"
load "../_narrated.ring"

# Linguistic query / explain / explore layer -- the fluent surface over the NLP
# primitives (POS, NER, sentiment, lemma, UAX#29 segmentation). Runs for real.

Scenario("UAX#29 sentences keep abbreviations and decimals whole")
	o1 = new stzString("The fox ran fast. Dr. Smith paid $3.14 today. It works.")
	Then("three sentences, not split on 'Dr.' or '3.14'",
		o1.NumberOfSentences(), 3)
	Then("Sentences() list agrees with the count",
		len(o1.Sentences()), 3)
	Then("the middle sentence stays intact",
		o1.NthSentence(2), "Dr. Smith paid $3.14 today.")
EndScenario()

Scenario("POS-aware word filters")
	# Tags are the averaged-perceptron model's actual output (= NLTK's), so the
	# filters inherit its statistical quirks -- these expected values record what
	# the deterministic tagger really produces on this sentence.
	o1 = new stzString("The quick brown fox quickly jumps over lazy dogs")
	Then("nouns (tags starting NN)",
		@@(o1.Nouns()), @@([ "brown", "dogs" ]))
	Then("verbs (tags starting VB)",
		@@(o1.Verbs()), @@([ "jumps" ]))
	Then("adjectives (tags starting JJ)",
		@@(o1.Adjectives()), @@([ "quick", "fox", "lazy" ]))
	Then("adverbs (tags starting RB)",
		@@(o1.Adverbs()), @@([ "quickly" ]))
EndScenario()

Scenario("Sentence filters by sentiment and similarity")
	o1 = new stzString("I love this wonderful product. The service was terrible and slow. It is a chair.")
	Then("the most positive sentence",
		o1.MostPositiveSentence(), "I love this wonderful product.")
	Then("the most negative sentence",
		o1.MostNegativeSentence(), "The service was terrible and slow.")
	Then("the sentence most similar to a query",
		o1.MostSimilarSentenceTo("bad slow service"), "The service was terrible and slow.")
EndScenario()

Scenario("Language detection across six languages + script + unknown")
	oe = new stzString("The quick brown fox that was running in the field")
	of = new stzString("Le renard brun qui est dans la maison des voisins")
	os = new stzString("El zorro marrón que está en la casa de los vecinos")
	og = new stzString("Der schnelle braune Fuchs ist nicht in dem Haus und")
	oi = new stzString("Il veloce volpe che sono nella casa degli vicini anche")
	op = new stzString("A raposa que não está com você então são muito mais")
	oa = new stzString("الطلاب يدرسون في المدارس الكبيرة")
	ou = new stzString("1234 5678")
	Then("english", oe.Language(), "english")
	Then("french",  of.Language(), "french")
	Then("spanish", os.Language(), "spanish")
	Then("german",  og.Language(), "german")
	Then("italian", oi.Language(), "italian")
	Then("portuguese", op.Language(), "portuguese")
	Then("arabic (by script)", oa.Language(), "arabic")
	Then("no signal -> unknown", ou.Language(), "unknown")
EndScenario()

Scenario("Q-chaining: SentencesQ keeps TEXT ops, not just generic list ops")
	o1 = new stzString("I love this wonderful product. The service was terrible and slow. It is a plain wooden chair.")
	Then("MostSimilarByMeaning picks by word overlap (cosine)",
		o1.SentencesQ().MostSimilarByMeaning("bad slow service"), "The service was terrible and slow.")
	Then("ThatAre filters sentences by sentiment",
		@@(o1.SentencesQ().ThatAre("positive")), @@([ "I love this wonderful product." ]))
	Then("ThatContain filters by substring",
		@@(o1.SentencesQ().ThatContain("chair")), @@([ "It is a plain wooden chair." ]))
	Then("chain ThatAreQ -> Joined stays fluent",
		o1.SentencesQ().ThatAreQ("positive").Joined(), "I love this wonderful product.")
	Then("generic list ops still available (NthString)",
		o1.SentencesQ().NthString(2), "The service was terrible and slow.")
	# the inherited Jaro-Winkler MostSimilarTo (character similarity) is preserved
	Then("WordsQ().MostSimilarTo fuzzy-matches a typo",
		o1.WordsQ().MostSimilarTo("wonderfull"), "wonderful")
EndScenario()

Scenario("Explainability: per-word valences follow the score's own rules")
	o1 = new stzString("The movie was not good")
	ae = o1.SentimentExplained()
	Then("overall lands negative",
		ae[1][2], "negative")
	# the engine applies 'not' to 'good', so 'good' is a NEGATIVE contributor
	Then("'good' contributes negatively because of 'not'",
		ae[3][2][1][1], "good")
	Then("no positive contributors remain",
		@@(ae[2][2]), @@([ ]))
EndScenario()

Scenario("Stylometry and comparison")
	o1 = new stzString("The cat sat on the mat in the warm sun")
	Then("lexical diversity is distinct/total words (8 distinct / 10)",
		o1.LexicalDiversity(), 0.8)
	ac = o1.ComparedTo("The dog sat on the mat in the cold rain")
	Then("shared content vocabulary",
		@@(ac[4][2]), @@([ "sat", "mat" ]))
EndScenario()

Scenario("Key-phrase extraction (RAKE)")
	o1 = new stzString("Criteria of compatibility of a system of linear Diophantine equations, strict inequations, and nonstrict inequations are considered.")
	Then("the top phrase is the multi-word technical term",
		o1.TopKeyPhrase(), "linear Diophantine equations")
	kp = o1.KeyPhrases(3)
	Then("top-3 are content phrases (stopwords/punctuation delimit them)",
		@@(kp), @@([ "linear Diophantine equations", "strict inequations", "nonstrict inequations" ]))
	Then("KeyPhrasesQ chains text-list ops",
		@@(o1.KeyPhrasesQ(0).ThatContain("inequations")),
		@@([ "strict inequations", "nonstrict inequations" ]))
EndScenario()

Scenario("TextRank: graph-centrality keywords + extractive summary")
	o1 = new stzString("Natural language processing enables computers to understand human language. Machine learning models power modern natural language processing. Language models learn patterns from large text corpora. These models improve many language tasks and applications. Deep learning has transformed natural language processing research.")
	Then("the single most central keyword",
		o1.RankedKeywords(1)[1], "language")
	Then("top-3 ranked keywords by PageRank centrality",
		@@(o1.RankedKeywords(3)), @@([ "language", "models", "processing" ]))
	Then("summary keeps the n most central sentences",
		len(o1.SummarySentences(2)), 2)
	Then("summary is joined in reading order",
		o1.Summary(2),
		"Machine learning models power modern natural language processing. Deep learning has transformed natural language processing research.")
EndScenario()

Scenario("Concordance / keyword in context")
	o1 = new stzString("a red car and a blue car and a green car")
	ak = o1.InContextWithWindow("car", 2)
	Then("three occurrences of 'car'",
		len(ak), 3)
	Then("the first window",
		ak[1], "a red car and a")
EndScenario()

Summary()
