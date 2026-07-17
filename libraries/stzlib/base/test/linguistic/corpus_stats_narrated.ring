# stzCorpus stats -- vocabulary, frequency and TF-IDF, all ENGINE-OWNED.
#
# These used to be counted in Ring hashlists inside _EnsureCounts: a linear
# scan per token (~O(tokens * vocab)) plus Ring-side insertion sorts. Every one
# now runs in the engine's corpus model -- counting, the vocabulary sort, and
# the TF-IDF arithmetic. stzCorpus hands the engine the documents and asks.
#
# The point of a refactor is that the answers do not change, so every value
# here is hand-checked against the definition. Corpus:
#   doc1: "the cat sat on the mat"
#   doc2: "the dog sat on the log"
#   doc3: "a cat and a dog play"

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oC = new stzCorpus([
	"the cat sat on the mat",
	"the dog sat on the log",
	"a cat and a dog play"
])

? "-- Scene 1: token & vocabulary counts --"

chk("18 tokens (three six-word documents)", oC.NumberOfWords() = 18)
chk("10 distinct words", oC.VocabularySize() = 10)
chk("the vocabulary lists exactly those 10", len(oC.Vocabulary()) = 10)
chk("... and it really contains the words", ring_find(oC.Vocabulary(), "cat") > 0)

? ""
? "-- Scene 2: frequency --"

chk("'the' occurs 4 times", oC.FreqOf("the") = 4)
chk("'cat' occurs twice", oC.FreqOf("cat") = 2)
chk("a word not in the corpus has frequency 0", oC.FreqOf("zebra") = 0)
chk("frequency is case-insensitive (engine lowercases)", oC.FreqOf("THE") = 4)

# MostFrequent returns [ word, count ] pairs, engine-sorted descending
aTop = oC.MostFrequent(3)
chk("MostFrequent returns the requested number of pairs", len(aTop) = 3)
chk("the most frequent word is 'the' with count 4",
	aTop[1][1] = "the" and aTop[1][2] = 4)
chk("... and the list is sorted descending", aTop[1][2] >= aTop[2][2] and aTop[2][2] >= aTop[3][2])
chk("asking for more than the vocabulary caps at the vocabulary",
	len(oC.MostFrequent(999)) = 10)

? ""
? "-- Scene 3: TF-IDF --"

# term frequency: 'the' appears twice in doc 1 ("the cat sat on the mat")
chk("TF('the', doc1) = 2", oC.TfOf("the", 1) = 2)
chk("TF of a word absent from a document is 0", oC.TfOf("dog", 1) = 0)
chk("TF of an out-of-range document is 0", oC.TfOf("the", 99) = 0)

# document frequency: 'the' is in docs 1 and 2 (not 3); 'cat' in docs 1 and 3
chk("df('the') = 2 (docs 1 and 2)", oC.NumberOfDocumentsWith("the") = 2)
chk("df('cat') = 2 (docs 1 and 3)", oC.NumberOfDocumentsWith("cat") = 2)
chk("df('mat') = 1 (doc 1 only)", oC.NumberOfDocumentsWith("mat") = 1)

# smoothed idf = log((1+D)/(1+df)) + 1, D = 3
chk("IdfOf('mat') = log(4/2)+1 (rarer -> higher)",
	abs(oC.IdfOf("mat") - (log(4.0/2) + 1)) < 0.0000001)
chk("IdfOf('cat') = log(4/3)+1", abs(oC.IdfOf("cat") - (log(4.0/3) + 1)) < 0.0000001)
chk("a rarer term has a HIGHER idf than a common one",
	oC.IdfOf("mat") > oC.IdfOf("cat"))

chk("TfIdf('the', doc1) = TF * IDF",
	abs(oC.TfIdfOf("the", 1) - oC.TfOf("the", 1) * oC.IdfOf("the")) < 0.0000001)

# top distinctive terms of doc 1, by TF-IDF
aTerms = oC.TopTermsOf(1, 3)
chk("TopTermsOf returns [word, tfidf] pairs, sorted descending",
	len(aTerms) = 3 and aTerms[1][2] >= aTerms[2][2])
chk("'the' is doc 1's top term (tf 2, and not the commonest across docs)",
	aTerms[1][1] = "the")

? ""
? "-- Scene 4: the corpus can grow, and the model rebuilds --"

nBefore = oC.VocabularySize()
oC.AddDocument("penguins waddle")
chk("adding a document with new words grows the vocabulary",
	oC.VocabularySize() = nBefore + 2)
chk("... and the new word is counted", oC.FreqOf("penguins") = 1)
chk("... and the old counts still hold", oC.FreqOf("the") = 4)

oC.FreeModel()

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
