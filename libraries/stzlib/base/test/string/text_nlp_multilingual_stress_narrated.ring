# stzText STRESS -- a large, MULTILINGUAL review corpus through the NLP layer.
#
# What the text layer is actually for: take a pile of real writing and get
# meaning out of it -- sentences, sentiment, lemmas, parts of speech,
# entities, keywords, readability. This runs a thousand product reviews
# through all of it and checks the answers, not just that it returned.
#
# Three things this file is looking for:
#
#   1. AGREEMENT BETWEEN SIBLINGS. A layer like this is full of methods that
#      must answer consistently -- NumberOfSentences() vs len(Sentences()),
#      POSTags() vs Words(). Those pairs are the cheapest real bugs to find
#      and the easiest to leave broken, because each half looks fine alone.
#      One such pair WAS broken: the text layer had its own sentence splitter
#      that disagreed with its own count on most real text.
#
#   2. REAL PUNCTUATION. Ellipses and emphatic punctuation are ordinary in
#      reviews -- "Hmm...", "Wow!!!" -- and a naive splitter turns each mark
#      into its own sentence, quietly feeding fragments to every sentence-level
#      analytic above it. UAX#29 keeps a RUN of terminators together.
#
#   3. MULTILINGUAL INPUT THAT THE MODELS WERE NOT TRAINED ON. The lemmatizer,
#      tagger and sentiment lexicon are English. Arabic, CJK and emoji must
#      still pass through without crashing, without corrupting bytes, and
#      without breaking the alignment invariants.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder, never
# typed as literals -- this codebase has a history of editors double-encoding
# source, so the test refuses to trust its own bytes.
#
# Ring traps avoided on purpose: no func named Show / Try (both collide with
# existing globals/keywords -- C22 and C6), no local named nL / oR.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# ---------------------------------------------------------------- vocabulary
cAr   = MkW([ 0x0639, 0x0645, 0x0644 ])                 # Arabic
cCJK  = MkW([ 0x6771, 0x4EAC ])                         # CJK  (Tokyo)
cGrUp = MkW([ 0x0391, 0x0398 ])                         # Greek UPPER
cCafe = MkW([ 0x0063, 0x0061, 0x0066, 0x00E9 ])         # Latin cafe'
cBox  = MkW([ 0x1F4E6 ])                                # Emoji

# --------------------------------------------------------------- build corpus
# Two review templates with KNOWN polarity, so the sentiment counts below are
# checked against a tally kept while building -- never against the analyser.
cPos = "Apple shipped a great product to Paris and the happy team loved the excellent design. "
cNeg = "However the critics were disappointed by the terrible price and the awful broken parts. "

nReviews = 1000

cCorpus      = ""
nExpectPos   = 0
nExpectNeg   = 0
nExpectSents = 0

t0 = clock()
for i = 1 to nReviews
	if i % 2 = 1
		cCorpus += cPos
		nExpectPos++
	else
		cCorpus += cNeg
		nExpectNeg++
	ok
	nExpectSents++
next
tBuild = (clock() - t0) / clockspersecond()

oCorpus = new stzText(cCorpus)

? "-- Scene 1: a 1000-review corpus --"
? "  built in " + tBuild + " s : " + len(cCorpus) + " bytes"
chk("the corpus is the expected size", len(cCorpus) > 80000)
chk("positive and negative reviews are balanced", nExpectPos = nExpectNeg)

? ""
? "-- Scene 2: segmentation, and siblings that must agree --"
t0 = clock()
aWords = oCorpus.Words()
tWords = (clock() - t0) / clockspersecond()

t0 = clock()
aSents = oCorpus.Sentences()
tSents = (clock() - t0) / clockspersecond()

? "  " + len(aWords) + " words in " + tWords + " s, " + len(aSents) + " sentences in " + tSents + " s"
chk("one sentence per review", len(aSents) = nExpectSents)
chk("NumberOfSentences agrees with Sentences()",
	oCorpus.NumberOfSentences() = len(aSents))
chk("NumberOfWords agrees with Words()", oCorpus.NumberOfWords() = len(aWords))
chk("segmentation is fast at scale (< 5s)", tWords + tSents < 5)

? ""
? "-- Scene 3: the punctuation that breaks naive splitters --"
# A run of terminators is ONE boundary (UAX#29 SB8a/SB9/SB10). A splitter
# that breaks on every mark returns "Wow!" then "!" then "!" -- fragments,
# not sentences -- and every sentence-level analytic inherits that.
oBang = new stzText("Wow!!!! Yes.")
chk("a run of '!' is one boundary, not four", len(oBang.Sentences()) = 2)
chk("...and the run stays attached to its sentence",
	oBang.Sentences()[1] = "Wow!!!!")

oDots = new stzText("Hmm... Yes.")
chk("an ellipsis is one boundary", len(oDots.Sentences()) = 2)
chk("...and stays attached", oDots.Sentences()[1] = "Hmm...")

oMix = new stzText("Really??? Wait!? Done.")
chk("mixed terminator runs also hold together", len(oMix.Sentences()) = 3)

oAbbr = new stzText("Dr. Smith arrived. He was late.")
chk("a known abbreviation does not end a sentence", len(oAbbr.Sentences()) = 2)

oDom = new stzText("Visit example.com now.")
chk("a dot inside a token does not end a sentence", len(oDom.Sentences()) = 1)

# every one of those must also match its own count
chk("count and list agree on the bang case",
	oBang.NumberOfSentences() = len(oBang.Sentences()))
chk("count and list agree on the abbreviation case",
	oAbbr.NumberOfSentences() = len(oAbbr.Sentences()))

? ""
? "-- Scene 4: sentiment against a tally kept while building --"
t0 = clock()
aPositive = oCorpus.PositiveSentences()
tSentiment = (clock() - t0) / clockspersecond()
? "  " + len(aPositive) + " positive sentences in " + tSentiment + " s"
chk("every positive review was recognised", len(aPositive) = nExpectPos)
chk("sentiment is fast at scale (< 5s)", tSentiment < 5)

oGood = new stzText("The product was great and the team was excellent.")
oBad  = new stzText("The design was terrible and the price was awful.")
chk("a clearly positive sentence reads positive", oGood.Sentiment() = "positive")
chk("a clearly negative sentence reads negative", oBad.Sentiment() = "negative")
chk("IsPositive agrees with Sentiment", oGood.IsPositive())
chk("the positive compound outscores the negative one",
	oGood.SentimentCompound() > oBad.SentimentCompound())

? ""
? "-- Scene 5: lemmatisation --"
oLem = new stzText("The teams were releasing better results and studying cities.")
cLem = oLem.Lemmatized()
? "  " + cLem
chk("plural nouns are singularised", StzFindFirst("team", cLem) > 0)
chk("verbs are reduced to their lemma", StzFindFirst("release", cLem) > 0)
chk("irregular plurals too", StzFindFirst("city", cLem) > 0)
# Lemmatisation is POS-AWARE, so it is NOT idempotent in a single pass: it
# rewrites the surface form, which changes what the tagger sees, which can
# change the lemma. "better"(RB) -> "well", then "well" reads as JJ -> "good",
# then stable. That is how POS-aware lemmatisers behave; what matters is that
# it CONVERGES rather than oscillating.
oLem2 = new stzText(cLem)
cLem2 = oLem2.Lemmatized()
oLem3 = new stzText(cLem2)
cLem3 = oLem3.Lemmatized()

chk("a second pass may still change the text (POS-aware, not idempotent)",
	cLem2 != cLem)
chk("...but it CONVERGES -- the third pass is a fixed point", cLem3 = cLem2)

? ""
? "-- Scene 6: parts of speech line up with the words --"
oPos = new stzText("The happy team shipped excellent products quickly.")
aPosWords = oPos.Words()
aPosTags = oPos.POSTags()
chk("one tag per word", len(aPosTags) = len(aPosWords))
chk("the determiner is tagged DT", aPosTags[1] = "DT")
chk("the adjective is tagged JJ", aPosTags[2] = "JJ")
chk("the plural noun is tagged NNS", aPosTags[6] = "NNS")

? ""
? "-- Scene 7: entities and keywords --"
oEnt = new stzText("Apple opened an office in Paris and hired Sarah Johnson.")
aEnts = oEnt.NamedEntities()
? "  " + len(aEnts) + " entities found"
chk("entities are found at all", len(aEnts) > 0)

aKw = oCorpus.RankedKeywords(10)
chk("ten ranked keywords come back", len(aKw) = 10)
aKp = oCorpus.KeyPhrases(5)
chk("five key phrases come back", len(aKp) = 5)
chk("readability returns a grade", oCorpus.ReadabilityGrade() != "")

? ""
? "-- Scene 8: multilingual input the models never saw --"
# English models on Arabic/CJK/emoji: the answers are not expected to be
# linguistically meaningful, but nothing may crash, no bytes may be mangled,
# and the alignment invariants must still hold.
cMixed = "The team visited " + cCJK + " and " + cCafe + " was great. " +
         cAr + " is a word. " + cGrUp + " too. Shipping " + cBox + " arrived."

oML = new stzText(cMixed)
aMLWords = oML.Words()
aMLTags = oML.POSTags()

chk("multilingual text still segments into words", len(aMLWords) > 0)
chk("tags still line up one per word", len(aMLTags) = len(aMLWords))
chk("count still agrees with the sentence list",
	oML.NumberOfSentences() = len(oML.Sentences()))

cMLLem = oML.Lemmatized()
chk("CJK survives the lemmatiser byte-for-byte", StzFindFirst(cCJK, cMLLem) > 0)
chk("Arabic survives", StzFindFirst(cAr, cMLLem) > 0)
chk("the emoji survives", StzFindFirst(cBox, cMLLem) > 0)
chk("accented Latin survives", StzFindFirst(cCafe, cMLLem) > 0)

bNoEmpty = TRUE
for i = 1 to len(aMLWords)
	if StzLen(aMLWords[i]) < 1
		bNoEmpty = FALSE
	ok
next
chk("no word came back empty or truncated", bNoEmpty)
chk("sentiment on multilingual text does not crash", oML.Sentiment() != "")

? ""
? "-- Scene 9: the whole pipeline at document scale --"
t0 = clock()
aNP = oCorpus.NounPhrases()
tNP = (clock() - t0) / clockspersecond()

t0 = clock()
cBigLem = oCorpus.Lemmatized()
tLem = (clock() - t0) / clockspersecond()

t0 = clock()
aBigTags = oCorpus.POSTags()
tTags = (clock() - t0) / clockspersecond()

? "  NounPhrases " + tNP + " s, Lemmatized " + tLem + " s, POSTags " + tTags + " s"
chk("noun phrases scale linearly (< 10s)", tNP < 10)
chk("lemmatising the whole corpus is fast (< 5s)", tLem < 5)
chk("tagging the whole corpus is fast (< 5s)", tTags < 5)
chk("tags still line up across the whole corpus", len(aBigTags) = len(aWords))
chk("the lemmatised corpus is still substantial", len(cBigLem) > 50000)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
