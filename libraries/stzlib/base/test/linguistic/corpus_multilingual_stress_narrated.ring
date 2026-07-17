# stzCorpus STRESS TEST -- large, multilingual, Arabic-heavy.
#
# The engine claims Unicode-correct tokenisation and lowercasing (utf8proc).
# ASCII proves nothing about that, so this hammers it with real multibyte text
# across scripts that behave differently under case-mapping:
#
#   Arabic   -- CASELESS: lowercasing must be a byte-preserving no-op, and the
#               bytes must survive counting / vocabulary / lookup intact.
#   Greek    -- HAS case: uppercase and lowercase must FOLD to one token.
#   Cyrillic -- HAS case: same fold test in another alphabet.
#   Latin    -- accented (café); CJK -- 3-byte, caseless; Emoji -- 4-byte.
#
# All text is built from RAW CODEPOINTS via a UTF-8 encoder, never typed as
# literals -- this very codebase has a history of editors double-encoding
# non-ASCII source, so the test refuses to depend on its own file's bytes.
#
# Scale: ~100k tokens over tens of thousands of documents, so the engine path
# is exercised at a size the old Ring hashlist floor could never finish.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# -- the multilingual vocabulary, by codepoint ------------------------------
cKitab   = MkWord([ 0x0643, 0x062A, 0x0627, 0x0628 ])           # kitab   (book)
cQalam   = MkWord([ 0x0642, 0x0644, 0x0645 ])                   # qalam   (pen)
cMadrasa = MkWord([ 0x0645, 0x062F, 0x0631, 0x0633, 0x0629 ])   # madrasa (school)
cAlphaUp = MkWord([ 0x0391, 0x039B, 0x03A6, 0x0391 ])           # Greek UPPER
cAlphaLo = MkWord([ 0x03B1, 0x03BB, 0x03C6, 0x03B1 ])           # Greek lower
cMirUp   = MkWord([ 0x041C, 0x0418, 0x0420 ])                   # Cyrillic UPPER
cMirLo   = MkWord([ 0x043C, 0x0438, 0x0440 ])                   # Cyrillic lower
cCafe    = MkWord([ 0x0063, 0x0061, 0x0066, 0x00E9 ])           # cafe (Latin accent)
cNihon   = MkWord([ 0x65E5, 0x672C ])                           # CJK (3-byte)
cEmoji   = MkWord([ 0x1F389 ])                                  # emoji (4-byte)

# -- build a large corpus from three document templates ---------------------
nK = 8000
cDocA = cKitab + " " + cQalam + " " + cAlphaUp + " " + cCafe + " " + cNihon  # 5 words
cDocB = cKitab + " " + cMadrasa + " " + cMirUp + " " + cCafe                  # 4 words
cDocC = cQalam + " " + cAlphaLo + " " + cMirLo + " " + cEmoji                 # 4 words

aDocs = []
for i = 1 to nK
	aDocs + cDocA
	aDocs + cDocB
	aDocs + cDocC
next

t0 = clock()
oC = new stzCorpus(aDocs)
h = oC._ModelHandle()
tTrain = (clock() - t0) / clockspersecond()

? "-- Scene 1: it trains at scale --"
? "  " + len(aDocs) + " documents, " + oC.NumberOfWords() + " tokens, trained in " + tTrain + " s"

chk("every token was counted (K x 13)", oC.NumberOfWords() = nK * 13)
chk("the vocabulary is the 8 distinct words", oC.VocabularySize() = 8)
chk("training a 100k-token corpus is fast (< 5s)", tTrain < 5)

? ""
? "-- Scene 2: ARABIC survives byte-for-byte (caseless, multibyte) --"

chk("kitab is 8 bytes (4 Arabic letters x 2)", len(cKitab) = 8)
chk("kitab round-trips into the vocabulary byte-identical",
	ring_find(oC.Vocabulary(), cKitab) > 0)
chk("kitab was counted exactly (2 templates x K)", oC.FreqOf(cKitab) = 2 * nK)
chk("madrasa (5 Arabic letters) counted exactly (1 template x K)",
	oC.FreqOf(cMadrasa) = nK)
chk("an Arabic word not in the corpus has frequency 0",
	oC.FreqOf(MkWord([ 0x0634, 0x0645, 0x0633 ])) = 0)   # shams (sun)

? ""
? "-- Scene 3: case FOLDS for cased scripts, across alphabets --"

# Greek ALPHA appears UPPER in template A and lower in template C. Both must
# count as the same token, and the vocabulary must hold the LOWER form only.
chk("Greek upper and lower fold to the same count",
	oC.FreqOf(cAlphaUp) = oC.FreqOf(cAlphaLo))
chk("... which is 2 templates x K", oC.FreqOf(cAlphaLo) = 2 * nK)
chk("the vocabulary stores the LOWER form", ring_find(oC.Vocabulary(), cAlphaLo) > 0)
chk("... and NOT the upper form", ring_find(oC.Vocabulary(), cAlphaUp) = 0)

chk("Cyrillic folds the same way", oC.FreqOf(cMirUp) = oC.FreqOf(cMirLo))
chk("... to 2 templates x K", oC.FreqOf(cMirLo) = 2 * nK)

chk("a Latin accented word (cafe with e-acute) counts", oC.FreqOf(cCafe) = 2 * nK)
chk("a 3-byte CJK word counts", oC.FreqOf(cNihon) = nK)
chk("a 4-byte emoji counts as one token", oC.FreqOf(cEmoji) = nK)

? ""
? "-- Scene 4: bigrams and TF-IDF work on multibyte tokens --"

# within template A: kitab -> qalam is a real bigram; kitab -> madrasa (B) too
chk("a within-document Arabic bigram outranks an unseen one",
	oC.BigramProbability(cKitab, cQalam) > oC.BigramProbability(cQalam, cKitab))

# emoji appears only in template C, so it is more DISTINCTIVE (higher idf)
chk("a rarer token has higher idf than a common one",
	oC.IdfOf(cEmoji) > oC.IdfOf(cKitab))

# df: kitab is in templates A and B -> 2K documents
chk("document frequency counts multibyte tokens", oC.NumberOfDocumentsWith(cKitab) = 2 * nK)

# TopTermsOf on a document that mixes scripts -- returns [word, tfidf] pairs
aTop = oC.TopTermsOf(1, 3)   # doc 1 is template A
chk("TopTermsOf returns pairs on a multilingual document", len(aTop) = 3)
chk("... each a real word from the document",
	ring_find([ cKitab, cQalam, cAlphaLo, cCafe, cNihon ], aTop[1][1]) > 0)

oC.FreeModel()

? ""
? "-- Scene 5: a pathological long multibyte token does not corrupt --"

# 400 Arabic letters = 800 bytes -- past the engine's lowercase buffer. It
# must be counted WHOLE (never truncated) and round-trip byte-identical.
cLongCps = []
for i = 1 to 400
	cLongCps + 0x0628   # repeat Arabic 'ba'
next
cLong = MkWord(cLongCps)
oL = new stzCorpus([ cLong + " " + cKitab ])
chk("the long token is 800 bytes", len(cLong) = 800)
chk("... counted (not dropped)", oL.FreqOf(cLong) = 1)
chk("... and round-trips byte-identical (no truncation)",
	ring_find(oL.Vocabulary(), cLong) > 0)
chk("... the normal token beside it is unaffected", oL.FreqOf(cKitab) = 1)
oL.FreeModel()

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
func EncCp n
	if n < 128
		return char(n)
	but n < 2048
		return char(192 + floor(n/64)) + char(128 + (n % 64))
	but n < 65536
		return char(224 + floor(n/4096)) + char(128 + floor((n%4096)/64)) + char(128 + (n%64))
	else
		return char(240 + floor(n/262144)) + char(128 + floor((n%262144)/4096)) +
		       char(128 + floor((n%4096)/64)) + char(128 + (n%64))
	ok

func MkWord aCp
	cW = ""
	n = len(aCp)
	for i = 1 to n
		cW += EncCp(aCp[i])
	next
	return cW
