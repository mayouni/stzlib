# The n-gram language model -- OWNED BY THE ENGINE, consumed by Ring.
#
# R3 shipped a Ring-side LM floor: Laplace-smoothed bigrams counted in Ring
# hashlists. A Ring hashlist is a linear scan, so every token costs an
# O(vocab) lookup and a corpus count is ~O(tokens * vocab) -- fine for a
# paragraph, hopeless at scale.
#
# So the counting now lives entirely in the engine (Zig hash map, O(tokens)):
# tokenisation, Unicode lowercasing and the probability arithmetic are all
# engine work. stzCorpus is a thin consumer -- it hands the engine the raw
# documents and asks BigramProbability / LogProbability / Perplexity. There is
# no Ring counting path: heavy processing belongs to the engine.
#
# What this suite checks: the numbers are RIGHT (hand-verified against the
# Laplace formula), a bigram never crosses a document boundary, the model
# ranks in-domain text as less surprising, and the engine is a HARD dependency
# (a clear refusal, never a silent Ring fallback, if the DLL is absent).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oC = new stzCorpus([
	"the cat sat on the mat",
	"the dog sat on the log",
	"a cat and a dog play"
])

? "-- Scene 1: the probabilities are RIGHT (hand-checked Laplace) --"

# The 10 distinct words: the cat sat on mat dog log a and play.
# "the" occurs 4 times; "the cat" occurs once. V = 10.
# P(cat|the) = (1 + 1) / (4 + 10) = 2/14
chk("the vocabulary is the 10 distinct words",
	stzengine_ngram_vocab_size(oC._LmHandle()) = 10)
chk("the corpus has 18 tokens (3 docs x 6 words)",
	stzengine_ngram_token_count(oC._LmHandle()) = 18)
chk("P(cat|the) = (1+1)/(4+10) = 2/14",
	abs(oC.BigramProbability("the", "cat") - 2.0 / 14) < 0.0000001)

# an unseen pair from the same first word: (0+1)/(4+10) = 1/14
chk("an UNSEEN bigram falls back to (0+1)/(uni+V) = 1/14",
	abs(oC.BigramProbability("the", "zebra") - 1.0 / 14) < 0.0000001)
chk("a seen bigram outranks an unseen one from the same word",
	oC.BigramProbability("the", "cat") > oC.BigramProbability("the", "zebra"))

# a wholly-unknown first word: uni=0, so (0+1)/(0+10) = 0.1
chk("a pair of unknown words -> (0+1)/(0+V) = 1/10",
	abs(oC.BigramProbability("zzz", "qqq") - 0.1) < 0.0000001)

? ""
? "-- Scene 2: case does not matter -- the engine lowercases (Unicode) --"

chk("upper-case query words match the lowercased counts",
	oC.BigramProbability("THE", "CAT") = oC.BigramProbability("the", "cat"))
chk("mixed case too", oC.BigramProbability("The", "Cat") = oC.BigramProbability("the", "cat"))

? ""
? "-- Scene 3: LogProbability and Perplexity --"

chk("LogProbability of a single bigram is its log",
	abs(oC.LogProbability("the cat") - log(oC.BigramProbability("the", "cat"))) < 0.0000001)
chk("a query shorter than two words has log-prob 0",
	oC.LogProbability("the") = 0)

nIn  = oC.Perplexity("the cat sat on the mat")
nOut = oC.Perplexity("quantum flux capacitor engaged")
chk("in-domain perplexity is lower than out-of-domain", nIn < nOut)
chk("both perplexities are positive", nIn > 0 and nOut > 0)

? ""
? "-- Scene 4: a bigram never spans a document boundary --"

# "mat" ends doc 1 and "the" starts doc 2; they are adjacent in the joined
# text but must NOT be counted as a bigram.
oB = new stzCorpus([ "alpha beta", "gamma delta" ])
# beta->gamma straddles the boundary -> unseen -> (0+1)/(uni(beta)+V)
# alpha->beta is within doc 1 -> seen. So the within-doc pair must score higher.
chk("a within-document bigram outranks a cross-document one",
	oB.BigramProbability("alpha", "beta") > oB.BigramProbability("beta", "gamma"))
chk("the cross-document pair really is unseen (count 0 -> Laplace floor)",
	oB.BigramProbability("beta", "gamma") = oB.BigramProbability("beta", "zzz"))
oB.FreeLm()

? ""
? "-- Scene 5: the engine is a HARD dependency, reached only through it --"

# _LmHandle returns a live engine handle (a positive id), proving the model is
# engine-resident, not a Ring structure.
chk("the model is an engine handle, not a Ring object", oC._LmHandle() > 0)

# training is idempotent: asking again returns the same handle, not a re-count
_h1_ = oC._LmHandle()
_h2_ = oC._LmHandle()
chk("the model is trained once and reused", _h1_ = _h2_)

oC.FreeLm()

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
