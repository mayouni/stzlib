load "../../stzBase.ring"
load "../_narrated.ring"

# TEXT DOMAIN (stzText, base/natural/). What others call "NLP" is just natural
# operations applied to text, so it lives in the natural/ domain: a string
# elevated to meaning (words, sentences, sentiment, entities, topics, semantics).
# Every op below runs for real. The methods are reachable both directly on
# stzString (thin delegators) and via the domain object Q(str).TextQ().

Scenario("The text domain: stzText carries meaning; stzString.TextQ() bridges to it")
	# Same result three ways: direct on string, via TextQ() (the chainable domain
	# OBJECT -- Q-form is mandatory for chaining), and on a stzText.
	o1 = new stzString("Barack Obama loves the wonderful city of Paris.")
	Then("string delegates to the domain",
		o1.Sentiment(), "positive")
	Then("Q(str).TextQ() reaches the same domain object",
		o1.TextQ().Sentiment(), "positive")
	Then("Text() (no Q) returns DATA -- the content, not an object",
		o1.Text(), "Barack Obama loves the wonderful city of Paris.")
	ot = StzTextQ("Barack Obama loves the wonderful city of Paris.")
	Then("a stzText is the domain object itself",
		@@(ot.PersonNames()), @@([ "Barack Obama" ]))
	Then("stzText inherits the structural layer (Words) from stzStringText",
		len(ot.Words()), 8)
EndScenario()

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

Scenario("The Q-ladder: Q -> basic, QQ -> secondary, QQQ -> most specific")
	o1 = new stzString("I love this wonderful product. The service was terrible and slow. It is a plain wooden chair.")
	# On a STRING, sentences climb stzList -> stzListOfStrings -> stzListOfTexts.
	Then("SentencesQ() is the BASIC object (stzList)",
		classname(o1.SentencesQ()), "stzlist")
	Then("SentencesQQ() is the first secondary type (stzListOfStrings)",
		classname(o1.SentencesQQ()), "stzlistofstrings")
	Then("SentencesQQQ() is the most specific (stzListOfTexts)",
		classname(o1.SentencesQQQ()), "stzlistoftexts")
	# Meaning ops live on stzListOfTexts (QQQ from a string).
	Then("MostSimilarByMeaning (a natural op) picks the closest sentence",
		o1.SentencesQQQ().MostSimilarByMeaning("bad slow service"), "The service was terrible and slow.")
	Then("ThatAre filters sentences by sentiment",
		@@(o1.SentencesQQQ().ThatAre("positive")), @@([ "I love this wonderful product." ]))
	Then("chain ThatAreQ -> Joined stays fluent",
		o1.SentencesQQQ().ThatAreQ("positive").Joined(), "I love this wonderful product.")
	# Lexical ops on the stzListOfStrings rung (QQ).
	Then("ThatContain (lexical) filters by substring",
		@@(o1.SentencesQQ().ThatContain("chair")), @@([ "It is a plain wooden chair." ]))
	Then("NthString on the stzListOfStrings rung",
		o1.SentencesQQ().NthString(2), "The service was terrible and slow.")
	# Words are LEXICAL: the ladder stops at stzListOfStrings (QQ), no text rung.
	Then("WordsQ() is the BASIC object (stzList)",
		classname(o1.WordsQ()), "stzlist")
	Then("WordsQQ().MostSimilarTo fuzzy-matches a typo (Jaro-Winkler)",
		o1.WordsQQ().MostSimilarTo("wonderfull"), "wonderful")
EndScenario()

Scenario("The Q-ladder on stzText: QQ jumps straight to stzListOfTexts")
	# In the TEXT layer there is no 'string' rung above -- a sentence of a text
	# IS a text -- so QQ lands on stzListOfTexts directly (no QQQ needed).
	t = new stzText("I love this wonderful product. The service was terrible and slow.")
	Then("SentencesQ() is still the basic stzList",
		classname(t.SentencesQ()), "stzlist")
	Then("SentencesQQ() is stzListOfTexts immediately",
		classname(t.SentencesQQ()), "stzlistoftexts")
	Then("meaning ops chain off QQ on a text",
		t.SentencesQQ().MostSimilarByMeaning("great item"), "I love this wonderful product.")
	Then("words stay lexical: WordsQQ() is stzListOfStrings",
		classname(t.WordsQQ()), "stzlistofstrings")
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
	# Q -> basic stzList; QQ -> stzListOfTexts (key phrases carry meaning), which
	# chains the list ops.
	Then("KeyPhrasesQ() is the basic stzList",
		classname(o1.KeyPhrasesQ(0)), "stzlist")
	Then("KeyPhrasesQQ chains text-list ops",
		@@(o1.KeyPhrasesQQ(0).ThatContain("inequations")),
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

Scenario("WordNet synonyms + hypernyms + language support")
	oh = new stzString("happy")
	Then("synonyms of 'happy'",
		@@(oh.Synonyms()), @@([ "felicitous", "glad", "well-chosen" ]))
	oc = new stzString("car")
	Then("'car' is a synonym of 'automobile'",
		oc.IsSynonymOf("automobile"), TRUE)
	Then("'car' hypernyms include 'motor vehicle' (is-a parent)",
		StzContains(oc.Hypernyms(), "motor vehicle"), 1)
	ox = new stzString("xyzzy")
	Then("unknown word -> no synonyms",
		len(ox.Synonyms()), 0)
	Then("25 Snowball stemmer languages are exposed",
		len(oc.SupportedStemmerLanguages()), 25)
EndScenario()

Scenario("Concordance / keyword in context")
	o1 = new stzString("a red car and a blue car and a green car")
	ak = o1.InContextWithWindow("car", 2)
	Then("three occurrences of 'car'",
		len(ak), 3)
	Then("the first window",
		ak[1], "a red car and a")
EndScenario()

Scenario("Semantic layer -- graceful lexical fallback with no model loaded")
	# The embedding-backed ops (upgraded when StzUseNeuralModel(path) is called)
	# degrade to lexical bag-of-words when no neural model is present, so the
	# API always works. Model-free here; the true-semantic path is verified
	# manually with a BERT GGUF (see below).
	o = new stzText("The cat sits on the mat")
	Then("no model loaded here",
		o.HasSemanticModel(), FALSE)
	Then("Embedding() is empty without a model",
		len(o.Embedding()), 0)
	Then("SemanticSimilarityWith falls back to a lexical score in [-1,1]",
		o.SemanticSimilarityWith("A kitten rests on the rug") >= 0, TRUE)
	Then("identical text is maximally similar (lexical)",
		o.SemanticSimilarityWith("The cat sits on the mat") > 0.99, TRUE)
	Then("a non-string comparand is rejected",
		o.SemanticSimilarityWith(123), 0)
	Then("IsSemanticallySimilarTo respects the threshold",
		o.IsSemanticallySimilarTo("The cat sits on the mat", 0.5), TRUE)
	# MANUAL (needs a BERT GGUF, e.g. all-MiniLM-L6-v2 -- large, not committed):
	#   StzUseNeuralModel(cPath)
	#   Q("The cat sits on the mat").TextQ().SemanticSimilarityWith("A kitten rests on the rug")
	#     -> ~0.65 (semantic); vs "Stock markets fell today" -> ~0.06
	#   new stzText("... Cats are wonderful pets.").MostSimilarSentenceTo("feline animals")
	#     -> "Cats are wonderful pets." (matched by MEANING, zero word overlap)
EndScenario()

Scenario("Zero-shot classification -- rank arbitrary labels, no training")
	# Model-free here (deterministic lexical fallback with lexically-distinct
	# labels). With StzUseNeuralModel(path) it ranks by MEANING instead.
	t = new stzText("the stock market prices fell sharply on wall street today")
	Then("ClassifiedAs picks the closest label",
		t.ClassifiedAs([ "market finance", "cooking food" ]), "market finance")
	Then("Classify returns ranked [label, score] pairs, best first",
		t.Classify([ "market finance", "cooking food" ])[1][1], "market finance")
	Then("Classify keeps all labels",
		len(t.Classify([ "market finance", "cooking food", "space travel" ])), 3)
	Then("ClassifyQ is the basic stzList",
		classname(t.ClassifyQ([ "a", "b" ])), "stzlist")
	Then("ClassifyQQ is stzListOfPairs",
		classname(t.ClassifyQQ([ "a", "b" ])), "stzlistofpairs")
	Then("a non-list of labels is rejected",
		@@(t.Classify("not a list")), @@([ ]))
	# MANUAL (with a BERT GGUF): classifies by MEANING, not word overlap --
	#   Q("The team scored in the final minute").TextQ().ClassifiedAs(
	#     ["sports","politics","cooking"]) -> "sports".
EndScenario()

Summary()
