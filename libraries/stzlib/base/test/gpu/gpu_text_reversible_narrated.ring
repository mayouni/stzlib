# THE TEXT LAYOUT IS REVERSIBLE -- §0 of base/gui/SOFTANZA_GUI_PLAN.md,
# filed against the graphics plane because that is where it lives.
#
# Drawing text is half a text pipeline. The other half is answering
# questions ABOUT what was drawn, and every platform IME on earth asks
# the same two -- Windows TSF (GetTextExt, GetACPFromPoint), macOS
# (firstRectForCharacterRange:, characterIndexForPoint:), Android, the
# Web's EditContext:
#
#   1. the screen rect of a character range
#   2. the character index at a point, with a leading/trailing affinity
#
# A layout that cannot answer them shapes Arabic beautifully and never
# accepts one character of Chinese -- and that is discovered late.
# Firefox's TSF work had to invent "query content events" so the widget
# layer could interrogate layout, and that was most of eight years.
#
# WHAT IS ASSERTED, and it is a MECHANISM, not a number: the ROUND TRIP
# closes. IndexAtPoint(x) answers (index, trailing); feeding that pair
# back to CaretRectAt lands on an edge of the very glyph box that
# contains x -- in LTR runs, in RTL runs, and across the seam between
# them, where "one byte offset" has TWO legitimate screen positions and
# only the affinity bit chooses between them.
#
# Runs on the COMMITTED fixture with no device, no download, no system
# font: this suite IS its own CI coverage, like its GR2a sibling.

load "stdlib.ring"
$cEngineDir = "../../../engine"
load "../../../engine/stz_gpu.ring"

nPass = 0
nFail = 0

# Arabic codepoints as explicit UTF-8 bytes (no source-encoding
# dependence), the same alphabet gpu_text_narrated.ring uses.
cSeen = char(0xD8) + char(0xB3)
cWaw  = char(0xD9) + char(0x88)
cFa   = char(0xD9) + char(0x81)
cTa   = char(0xD8) + char(0xAA)
cAlef = char(0xD8) + char(0xA7)
cNoon = char(0xD9) + char(0x86)
cZay  = char(0xD8) + char(0xB2)
cSoftanza = cSeen + cWaw + cFa + cTa + cAlef + cNoon + cZay + cAlef

cMixed = "abc " + cSoftanza + " xyz"   # 24 bytes: Arabic occupies [4, 20)

hF = StzEngineGpuFontLoad(read("fixtures/amiri_arabic_subset.ttf"))
chk("fixture font loads (no device needed)", hF > 0)

? ""
? "-- Scene 1: the layout now CARRIES what a caret needs --"
aL = StzEngineGpuTextLayout(hF, "Softanza", 32)
chk("layout answers 7 items (glyphs + metrics)", len(aL) = 7)
chk("every glyph carries 8 numbers", len(aL[3][1]) = 8)
chk("ascender is a positive distance", aL[4] > 0)
chk("descender is a positive distance", aL[5] > 0)
chk("line height exceeds the em at 32px", aL[4] + aL[5] + aL[6] > 32)
chk("a Latin paragraph is not RTL", aL[7] = 0)

? ""
? "-- Scene 2: pen and advance are NOT the draw x (the classic bug) --"
# x is where the glyph is PAINTED and carries the mark offset; the box a
# click is tested against is [pen, pen+adv). Confusing them is the
# textbook caret defect, so the two are separate fields, and the pen
# chain is exact: it reconstructs the total advance to the bit.
aG = aL[3]
nSum = 0
bChain = 1
for i = 1 to len(aG)
	if aG[i][5] != nSum
		bChain = 0
	ok
	nSum += aG[i][6]
next
chk("the first glyph's pen is the origin", aG[1][5] = 0)
chk("pen[i+1] = pen[i] + adv[i], exactly", bChain = 1)
chk("the advances sum to the reported width", nSum = aL[1])

? ""
? "-- Scene 3: cluster ENDS make the byte range knowable --"
# The cluster field always gave a START byte. Without the END, 'is byte
# B inside this cluster' is unanswerable, and every consumer guesses.
bAscii = 1
for i = 1 to len(aG)
	if aG[i][4] != i - 1 or aG[i][7] != i
		bAscii = 0
	ok
next
chk("8 ASCII chars: cluster i-1 ends at i", bAscii = 1)
chk("the last cluster ends at the text length", aG[len(aG)][7] = 8)
chk("Latin glyphs carry an even bidi level", aG[1][8] % 2 = 0)

? ""
? "-- Scene 4: RTL -- clusters DESCEND as x advances, ends still lead --"
aR = StzEngineGpuTextLayout(hF, cSoftanza, 32)
aRG = aR[3]
bDesc = 1
bEnds = 1
for i = 1 to len(aRG)
	if aRG[i][7] <= aRG[i][4]     # end is always PAST the start
		bEnds = 0
	ok
	if i > 1 and aRG[i][4] >= aRG[i-1][4]
		bDesc = 0
	ok
next
chk("a pure-Arabic paragraph IS RTL", aR[7] = 1)
chk("Arabic glyphs carry an ODD bidi level", aRG[1][8] % 2 = 1)
chk("clusters descend as x advances (RTL made visual)", bDesc = 1)
chk("every cluster end is past its start", bEnds = 1)
chk("the VISUALLY FIRST Arabic glyph ends at the text end", aRG[1][7] = 16)

? ""
? "-- Scene 5: THE ROUND TRIP -- click a glyph, land on that glyph --"
# The property, stated once: for any point x, the caret rect built from
# what IndexAtPoint answered there is an EDGE of the glyph box that
# contains x. If this holds through an RTL run and across a bidi seam,
# the layout is reversible. If it holds only for Latin, it is not.
aM = StzEngineGpuTextLayout(hF, cMixed, 32)
aMG = aM[3]
chk("the mixed string breaks into 3 visual runs", aM[2] = 3)

nMiss = 0
nProbes = 0
for i = 1 to len(aMG)
	# probe both halves of every glyph box: the half decides the affinity
	aProbe = [ aMG[i][5] + aMG[i][6] * 0.25, aMG[i][5] + aMG[i][6] * 0.75 ]
	for k = 1 to 2
		nX = aProbe[k]
		aHit = StzEngineGpuTextIndexAt(hF, cMixed, 32, nX)
		aRect = StzEngineGpuTextCaretRect(hF, cMixed, 32, aHit[1], aHit[2])
		nProbes++
		# the caret must sit on one of the probed box's two edges
		nL = aMG[i][5]
		nR = aMG[i][5] + aMG[i][6]
		if fabs(aRect[1] - nL) > 0.001 and fabs(aRect[1] - nR) > 0.001
			nMiss++
		ok
	next
next
chk("every glyph was probed on both halves", nProbes = 2 * len(aMG))
chk("EVERY probe round-trips onto its own glyph's edge", nMiss = 0)

# ...and the negative sibling: the two halves of one glyph must NOT
# answer the same caret, or 'affinity' would be a field nobody reads.
aHitL = StzEngineGpuTextIndexAt(hF, cMixed, 32, aMG[1][5] + aMG[1][6] * 0.25)
aHitR = StzEngineGpuTextIndexAt(hF, cMixed, 32, aMG[1][5] + aMG[1][6] * 0.75)
chk("the two halves of a glyph disagree on affinity", aHitL[2] != aHitR[2])
chk("...and so resolve to different caret bytes", aHitL[3] != aHitR[3])

? ""
? "-- Scene 6: affinity is REQUIRED, not decoration --"
# In an LTR run the visually-left half is the LEADING half. In an RTL
# run it is the TRAILING one. That asymmetry IS the affinity bit, and it
# is the reason one number cannot answer 'where is byte 4 on screen'.
nArabStart = 4
aCaretLead  = StzEngineGpuTextCaretRect(hF, cMixed, 32, nArabStart, 0)
aCaretTrail = StzEngineGpuTextCaretRect(hF, cMixed, 32, nArabStart, 1)
chk("one byte offset, two screen positions", aCaretLead[1] != aCaretTrail[1])
chk("both carets are zero-width", aCaretLead[3] = 0 and aCaretTrail[3] = 0)
chk("a caret is a full line tall", aCaretLead[4] > 32)
chk("the caret top is above the baseline", aCaretLead[2] < 0)

# the RTL rule, asserted directly: leading is to the RIGHT of trailing
chk("in an RTL run the LEADING edge is the right one", aCaretLead[1] > aCaretTrail[1])

? ""
? "-- Scene 7: a range becomes rects -- one, or several across a seam --"
aPure = StzEngineGpuTextRects(hF, cMixed, 32, 0, 3)       # "abc", one run
chk("a within-run range gives exactly one rect", len(aPure) = 1)
nAbcW = aMG[1][6] + aMG[2][6] + aMG[3][6]
chk("...whose width is those glyphs' advances", fabs(aPure[1][3] - nAbcW) < 0.001)

aSeam = StzEngineGpuTextRects(hF, cMixed, 32, 2, 8)       # "c " + 2 Arabic
chk("a range crossing the bidi seam gives SEVERAL rects", len(aSeam) > 1)

aAll = StzEngineGpuTextRects(hF, cMixed, 32, 0, 24)
nCover = 0
for i = 1 to len(aAll)
	nCover += aAll[i][3]
next
chk("selecting everything covers the whole advance", fabs(nCover - aM[1]) < 0.001)

? ""
? "-- Scene 8: refusals and edges answer by name --"
chk("an empty range selects nothing", len(StzEngineGpuTextRects(hF, cMixed, 32, 5, 5)) = 0)
chk("a reversed range selects nothing", len(StzEngineGpuTextRects(hF, cMixed, 32, 9, 4)) = 0)

aEndL = StzEngineGpuTextCaretRect(hF, "Softanza", 32, 8, 0)
chk("past the end of an LTR line the caret is at the width", fabs(aEndL[1] - aL[1]) < 0.001)
aEndR = StzEngineGpuTextCaretRect(hF, cSoftanza, 32, 16, 0)
chk("past the end of an RTL line the caret is at x=0", aEndR[1] = 0)

aFarL = StzEngineGpuTextIndexAt(hF, "Softanza", 32, -500)
chk("a click far left clamps to the first glyph", aFarL[1] = 0)
aFarR = StzEngineGpuTextIndexAt(hF, "Softanza", 32, 5000)
chk("a click far right clamps to the last, trailing", aFarR[2] = 1 and aFarR[3] = 8)

chk("queries on a stale font answer []", len(StzEngineGpuTextIndexAt(0, "x", 32, 1)) = 0)

? ""
? "-- Scene 9: the queries are deterministic --"
a1 = StzEngineGpuTextIndexAt(hF, cMixed, 32, 60)
a2 = StzEngineGpuTextIndexAt(hF, cMixed, 32, 60)
chk("the same point answers the same hit", a1[1] = a2[1] and a1[2] = a2[2] and a1[3] = a2[3])
r1 = StzEngineGpuTextCaretRect(hF, cMixed, 32, 4, 1)
r2 = StzEngineGpuTextCaretRect(hF, cMixed, 32, 4, 1)
chk("the same caret answers the same rect", r1[1] = r2[1] and r1[4] = r2[4])

StzEngineGpuFontFree(hF)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
