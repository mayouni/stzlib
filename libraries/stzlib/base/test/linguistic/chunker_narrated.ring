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
