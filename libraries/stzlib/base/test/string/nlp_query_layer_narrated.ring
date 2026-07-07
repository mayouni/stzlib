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

Scenario("Language detection across the three supported languages")
	oe = new stzString("The quick brown fox that was running in the field")
	of = new stzString("Le renard brun qui est dans la maison des voisins")
	oa = new stzString("الطلاب يدرسون في المدارس الكبيرة")
	Then("english", oe.Language(), "english")
	Then("french",  of.Language(), "french")
	Then("arabic",  oa.Language(), "arabic")
EndScenario()

Scenario("Explainability: why an overall score differs from word polarity")
	o1 = new stzString("The movie was not good")
	ae = o1.SentimentExplained()
	Then("overall lands negative (negation applied)",
		ae[1][2], "negative")
	Then("yet 'good' still reads as a positive word lexically",
		@@(ae[2][2]), @@([ "good" ]))
EndScenario()

Scenario("Stylometry and comparison")
	o1 = new stzString("The cat sat on the mat in the warm sun")
	Then("lexical diversity is distinct/total words (8 distinct / 10)",
		o1.LexicalDiversity(), 0.8)
	ac = o1.ComparedTo("The dog sat on the mat in the cold rain")
	Then("shared content vocabulary",
		@@(ac[4][2]), @@([ "sat", "mat" ]))
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
