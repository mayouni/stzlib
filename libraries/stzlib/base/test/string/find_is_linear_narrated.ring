# Finding ALL occurrences is linear in the size of the string.
#
# It was quadratic. StzFindCS collects every match by calling the engine's
# FindFirstFrom once per hit, and that function resolved its start position
# by walking from byte 0 EVERY time. Two matches cost two walks, n matches
# cost n walks over an ever-longer prefix:
#
#     42 KB / 2000 matches   29.20 ms
#     84 KB / 4000 matches  114.79 ms     <- 4x the time for 2x the input
#    168 KB / 8000 matches  462.15 ms     <- 4x again
#
# WHAT THIS GUARD PINS IS THE SHAPE, NOT A SPEED. A millisecond count would
# drift with the machine, the build mode, and whatever else is running; the
# RATIO between two sizes is a property of the algorithm. Quadratic means
# 4x input -> ~16x time. Linear means ~4x. The band below (< 8x) sits
# between the two, far from both, so the guard fails on a return to
# quadratic and does not fail on a slow afternoon.
#
# The correctness scenes come FIRST and deliberately outnumber the timing
# one: a fast find that returns the wrong positions is not an optimisation.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: it finds every occurrence, at the right place --"
cSmall = "fox in a box, fox on a rock, fox by the dock"
aPos = StzFindCS("fox", cSmall, TRUE)
chk("three occurrences", len(aPos) = 3)
chk("...at the positions a human would count", SameList(aPos, [1, 15, 30]))
# Verified independently of the finder: read the substring back out at each
# reported position. If a position were wrong, this would not spell "fox".
bSpellsFox = TRUE
for i = 1 to len(aPos)
	if StzMid(cSmall, aPos[i], 3) != "fox"
		bSpellsFox = FALSE
	ok
next
chk("...and each position really does begin the needle", bSpellsFox)

? ""
? "-- Scene 2: find is OVERLAPPING, and both surfaces say so --"
chk("'aa' in 'aaaa' is [1, 2, 3]", SameList(StzFindCS("aa", "aaaa", TRUE), [1, 2, 3]))
# The global used to answer [1, 3]: its Ring loop advanced by the needle's
# LENGTH after each hit, so the third "aa" -- the one starting inside the
# second -- was never looked for. The class surface used the engine
# primitive and answered [1, 2, 3] all along. Overlapping is the Softanza
# behaviour (the BoundedBy family depends on it), so the global was the
# outlier, and this is what the disagreement is settled AS.
oFindS = new stzString("aaaa")
chk("...and the class surface agrees, character for character",
	SameList(StzFindCS("aa", "aaaa", TRUE), oFindS.Find("aa")))
# THE POINT OF THIS ASSERTION: the two spellings drifted apart silently for
# as long as nobody compared them. Comparing them is now a test, so the next
# person to optimise one of the two cannot quietly re-fork them.
chk("non-overlapping patterns are unaffected",
	SameList(StzFindCS("ab", "ababab", TRUE), [1, 3, 5]))
chk("case-insensitive overlaps the same way",
	SameList(StzFindCS("AA", "aAaA", FALSE), [1, 2, 3]))
chk("Last and Nth derive from that same list",
	StzFindLast("aa", "aaaa") = 3 and StzFindNth("aa", "aaaa", 2) = 2)

? ""
? "-- Scene 3: absent needles, and needles longer than the string --"
chk("an absent needle finds nothing", len(StzFindCS("zebra", cSmall, TRUE)) = 0)
chk("a needle longer than the haystack finds nothing",
	len(StzFindCS(cSmall + "!", cSmall, TRUE)) = 0)
chk("the whole string matches itself once", SameList(StzFindCS(cSmall, cSmall, TRUE), [1]))

? ""
? "-- Scene 4: multibyte text counts CODEPOINTS, not bytes --"
# 'e' + combining acute is 2 bytes; a byte-oriented finder reports 4 here.
cAcc = StzChar(233)   # e-acute, 2 bytes in UTF-8
cMulti = cAcc + cAcc + "fox" + cAcc
aMPos = StzFindCS("fox", cMulti, TRUE)
chk("one match", len(aMPos) = 1)
chk("...reported at codepoint 3, not byte 5", SameList(aMPos, [3]))

? ""
? "-- Scene 5: and the cost grows LINEARLY with the input --"
# Sizes chosen so the smaller run is tens of ms: too fast to time and the
# ratio is measuring noise, not the algorithm.
cUnit = "the quick brown fox jumps over the lazy dog. "

cBase = ""
for i = 1 to 12000
	cBase += cUnit
next
cBig = cBase + cBase + cBase + cBase   # exactly 4x

nT0 = StzEngineWatchTimestampMs()
aB1 = StzFindCS("fox", cBase, TRUE)
nBaseMs = StzEngineWatchTimestampMs() - nT0

nT0 = StzEngineWatchTimestampMs()
aB2 = StzFindCS("fox", cBig, TRUE)
nBigMs = StzEngineWatchTimestampMs() - nT0

? "   1x = " + len(cBase) + " bytes / " + len(aB1) + " matches : " + nBaseMs + " ms"
? "   4x = " + len(cBig) + " bytes / " + len(aB2) + " matches : " + nBigMs + " ms"
? "   ratio = " + (nBigMs / nBaseMs) + "x for 4x the input"

chk("the 1x run was slow enough to time honestly", nBaseMs >= 3)
chk("4x the input found 4x the matches", len(aB2) = 4 * len(aB1))
chk("...and cost well under the 16x a quadratic scan would",
	(nBigMs / nBaseMs) < 8.0)
# The old code measured 4.0x and 4.03x per DOUBLING here, i.e. ~16x across
# this 4x step. The band is 8x: unreachable by the linear form, unreachable
# by anything quadratic.

chk("the big result is still correct at its far end",
	StzMid(cBig, aB2[len(aB2)], 3) = "fox")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

# Ring's "=" does NOT deep-compare lists -- it answers FALSE for two lists
# with identical contents. Five assertions here were written as
# `aPos = [1, 15, 30]` and could never have passed, whatever the code did.
# An assertion that cannot pass is as useless as one that cannot fail.
func SameList aExpected, aGot
	if NOT (isList(aExpected) and isList(aGot)) return FALSE ok
	_nSlA_ = len(aExpected)
	if _nSlA_ != len(aGot) return FALSE ok
	for _nSlI_ = 1 to _nSlA_
		if aExpected[_nSlI_] != aGot[_nSlI_] return FALSE ok
	next
	return TRUE

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
