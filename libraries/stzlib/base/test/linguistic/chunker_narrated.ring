# R3 (slice 1) ACCEPTANCE -- linguistic/: the domain is born
# stzText promoted as ENTRY OBJECT; the POS-PATTERN CHUNKER covers
# NLTK's RegexpParser with a cleaner grammar (patterns over tags).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the entry object answers from its new home --"
o = new stzText("The quick brown fox jumps over the lazy dog")
chk("stzText lives (linguistic/)", o.NumberOfWords() = 9)
chk("POS tagging on board", len(o.POSTags()) = 9)

? ""
? "-- Scene 2: patterns over tags (the chunker) --"
aNP = o.NounPhrases()
? "  NounPhrases: " + @@(aNP)
chk("the classic NP grammar finds both phrases",
	len(aNP) = 2 and aNP[1] = "The quick brown fox" and aNP[2] = "the lazy dog")
chk("any tag grammar works (VBZ IN)", o.Chunks("VBZ IN")[1] = "jumps over")
chk("quantifiers behave (JJ+ NN+ needs at least one adjective)",
	len(o.Chunks("JJ+ NN+")) >= 1)
chk("an empty grammar refuses quietly", len(o.Chunks("")) = 0)

? ""
? "-- Scene 3: prefix tag semantics --"
o2 = new stzText("Dogs eat bones")
? "  tagged: " + @@(o2.TaggedWords())
chk("NN covers NNS (plural nouns match by prefix)",
	len(o2.Chunks("NN+")) >= 1)

? ""
? "-- Scene 4: the corpus (your texts ARE the corpus, no downloads) --"
oC = new stzCorpus([
	"the quick brown fox jumps over the lazy dog",
	"the fox eats the quick rabbit",
	"a lazy dog sleeps all day"
])
chk("documents counted", oC.NumberOfDocuments() = 3)
chk("tokens + vocabulary counted", oC.NumberOfWords() = 21 and oC.VocabularySize() = 14)
chk("frequencies answer", oC.FreqOf("the") = 4)
chk("MostFrequent ranks", oC.MostFrequent(1)[1][1] = "the")

? ""
? "-- Scene 5: the n-gram language model (nltk.lm counterpart, floor) --"
chk("seen bigram outweighs unseen (Laplace)",
	oC.BigramProbability("the", "fox") > oC.BigramProbability("the", "zebra"))
nIn = oC.Perplexity("the quick fox")
nOut = oC.Perplexity("purple elephants compute quietly")
? "  perplexity in-domain " + nIn + " vs out-domain " + nOut
chk("perplexity prefers in-domain text", nIn < nOut)

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
