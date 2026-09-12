# The TEXT PIPELINE -- GR2 of the graphics plane (SOFTANZA_GRAPHICS_PLAN.md).
#
# SheenBidi reorders (UAX#9 visual runs), HarfBuzz shapes (contextual
# joining, MANDATORY ligatures, GSUB/GPOS -- codepoints in, GLYPH IDS
# out), stb_truetype rasters BY GLYPH ID. One engine entry serves every
# renderer. The plan's words stand over this file: per-codepoint Arabic
# is WRONG, not degraded -- disconnected letterforms are misspellings.
#
# The guard corpus the plan names, asserted by MECHANISM (glyph ids and
# run structure, not pixels):
#   - Latin: one glyph per char, x strictly advancing
#   - Arabic joining: the MEDIAL form of a letter is a DIFFERENT glyph id
#     than its isolated form (assert ids differ, the joining witness)
#   - lam-alef: the pair's output glyphs differ from isolated AND generic
#     joined forms (the mandatory-ligature witness; fonts may fuse to one
#     glyph like Tahoma or substitute dedicated pieces like Amiri)
#   - mixed-direction: 3 visual runs; the Arabic run's CLUSTERS descend
#     as x advances (RTL made visual); the Latin runs' clusters ascend
#   - raster: an inked glyph bitmap BY ID; whitespace answers ink-free
#
# Everything runs on the COMMITTED fixture (fixtures/amiri_arabic_subset
# .ttf, OFL, provenance in fixtures/README.md): CI shapes real Arabic
# with no download, no GPU, no system font. A device is NEVER required
# here -- this suite is CI coverage by construction.
#
# STANDALONE like the other gpu guards: loads only the engine bridge.

load "stdlib.ring"
$cEngineDir = "../../../engine"
load "../../../engine/stz_gpu.ring"

nPass = 0
nFail = 0

# Arabic codepoints, UTF-8 bytes composed explicitly (no source-encoding
# dependence): seen (0633), waw (0648), fa (0641), ta (062A), alef (0627),
# noon (0646), zay (0632), lam (0644), beh (0628)
cSeen = char(0xD8) + char(0xB3)
cWaw  = char(0xD9) + char(0x88)
cFa   = char(0xD9) + char(0x81)
cTa   = char(0xD8) + char(0xAA)
cAlef = char(0xD8) + char(0xA7)
cNoon = char(0xD9) + char(0x86)
cZay  = char(0xD8) + char(0xB2)
cLam  = char(0xD9) + char(0x84)
cBeh  = char(0xD8) + char(0xA8)
# the library's own name in Arabic: sin-waw-fa-ta-alef-noon-zay-alef
cSoftanza = cSeen + cWaw + cFa + cTa + cAlef + cNoon + cZay + cAlef

? "-- Scene 1: the committed fixture loads (no device, no download) --"
cFontBytes = read("fixtures/amiri_arabic_subset.ttf")
chk("fixture bytes on disk", len(cFontBytes) > 100000)
chk("no device is present or needed", StzEngineGpuIsAvailable() = 0)
hF = StzEngineGpuFontLoad(cFontBytes)
chk("font loads from memory (id > 0)", hF > 0)
chk("subset carries its glyph repertoire", StzEngineGpuFontGlyphCount(hF) = 1449)
chk("garbage bytes refuse (id 0)", StzEngineGpuFontLoad("not a font at all") = 0)

? ""
? "-- Scene 2: Latin -- one glyph per char, x strictly advancing --"
aLat = StzEngineGpuTextLayout(hF, "Softanza", 32)
# 9 items: 7 since the reversibility fields landed (§0 of the GUI plane):
# width, runs, glyphs, ascender, descender, lineGap, paraRtl -- and DN12
# appended inkTop and inkBottom (a label centres on its CAP height). Every
# field was APPENDED, never reordered -- items 1..3 mean what they always
# meant. (The guard said 7 from DN12 until 2026-09-11: a drift, not a fault.)
# 11 since the fallback chain landed (GR2c): the two coverage counters were
# APPENDED, like every slot before them. A doorway that grows owes its guard
# a line in the SAME commit -- this one drifted a month the last time it was
# widened, and reported a regression in code that had got better.
chk("layout answers width, runs, glyphs, metrics, the chain, the flow and the fit", len(aLat) = 16)
# both ink distances are POSITIVE, measured away from the baseline like the metrics
chk("the ink band lies inside the em box: inkTop <= ascender, inkBottom <= descender", aLat[8] <= aLat[4] and aLat[9] <= aLat[5])
aG = aLat[3]
chk("8 chars -> 8 glyphs", len(aG) = 8)
chk("one visual run", aLat[2] = 1)
chk("total width is positive", aLat[1] > 0)
bAdv = TRUE
bIds = TRUE
for _i_ = 2 to len(aG)
    if aG[_i_][2] <= aG[_i_-1][2]
        bAdv = FALSE
    ok
next
_aG12_ = aG
_nG12_ = len(_aG12_)
for _iG12_ = 1 to _nG12_
	_g_ = _aG12_[_iG12_]
    if _g_[1] = 0
        bIds = FALSE
    ok
next
chk("x strictly advances across the line", bAdv)
chk("every glyph id is real (no .notdef)", bIds)
chk("clusters ascend with x (LTR)", aG[1][4] < aG[len(aG)][4])

? ""
? "-- Scene 3: Arabic joining -- context CHANGES the glyph id --"
# beh alone (isolated form) vs beh mid-word in beh+beh+beh (medial form):
# same codepoint, different glyph -- the joining mechanism itself
aIso = StzEngineGpuTextLayout(hF, cBeh, 32)
aCtx = StzEngineGpuTextLayout(hF, cBeh + cBeh + cBeh, 32)
chk("isolated beh shapes to one glyph", len(aIso[3]) = 1)
chk("beh+beh+beh shapes to three glyphs", len(aCtx[3]) = 3)
nIsoGid = aIso[3][1][1]
# visual order is RTL: the MIDDLE glyph of the triple is the medial form
nMedGid = aCtx[3][2][1]
chk("medial form id DIFFERS from isolated form id (joining happened)",
    nMedGid != nIsoGid)
chk("word width < 3x isolated width (joined forms are narrower)",
    aCtx[1] < 3 * aIso[1])

? ""
? "-- Scene 4: lam-alef -- the MANDATORY ligature fires --"
# The witness is the MECHANISM, not a fusion count: Tahoma fuses the pair
# into ONE glyph; Amiri (measured here) substitutes TWO dedicated
# lam-alef pieces -- both are the mandatory ligature working. What must
# hold in ANY correct font: the output ids differ from the ISOLATED
# forms AND from the GENERIC joined forms (lam-initial as in lam+beh,
# alef-final as in beh+alef). Per-codepoint rendering would fail all four.
aLA = StzEngineGpuTextLayout(hF, cLam + cAlef, 32)
chk("the pair fuses below 2 separate letters' glyph count OR substitutes special forms",
    len(aLA[3]) <= 2)
nLigGid = aLA[3][1][1]
aLamOnly = StzEngineGpuTextLayout(hF, cLam, 32)
aAlefOnly = StzEngineGpuTextLayout(hF, cAlef, 32)
nLamIso = aLamOnly[3][1][1]
nAlefIso = aAlefOnly[3][1][1]
# generic joined forms from neutral contexts
aLB = StzEngineGpuTextLayout(hF, cLam + cBeh, 32)
nLamInit = 0
_aG13_ = aLB[3]
_nG13_ = len(_aG13_)
for _iG13_ = 1 to _nG13_
	_g_ = _aG13_[_iG13_]
    if _g_[4] = 0
        nLamInit = _g_[1]
    ok
next
aBA = StzEngineGpuTextLayout(hF, cBeh + cAlef, 32)
nAlefFin = 0
_aG14_ = aBA[3]
_nG14_ = len(_aG14_)
for _iG14_ = 1 to _nG14_
	_g_ = _aG14_[_iG14_]
    if _g_[4] = 2
        nAlefFin = _g_[1]
    ok
next
bSpecial = TRUE
_aG15_ = aLA[3]
_nG15_ = len(_aG15_)
for _iG15_ = 1 to _nG15_
	_g_ = _aG15_[_iG15_]
    if _g_[1] = nLamIso or _g_[1] = nAlefIso or _g_[1] = nLamInit or _g_[1] = nAlefFin
        bSpecial = FALSE
    ok
next
chk("every output glyph differs from isolated AND generic joined forms " +
    "(the lam-alef-SPECIFIC substitution fired)", bSpecial)
chk("the pair is one cluster-connected unit, narrower than lam + alef apart",
    aLA[1] < aLamOnly[1] + aAlefOnly[1])

? ""
? "-- Scene 5: the full Arabic word shapes joined --"
aAr = StzEngineGpuTextLayout(hF, cSoftanza, 32)
chk("8 codepoints -> 8 glyphs (no lam-alef pair in this word)", len(aAr[3]) = 8)
chk("one visual run (pure RTL)", aAr[2] = 1)
# RTL made visual: first glyph OUT is the LAST letter typed -- clusters
# strictly DESCEND as x advances
bDesc = TRUE
for _i_ = 2 to len(aAr[3])
    if aAr[3][_i_][4] >= aAr[3][_i_-1][4]
        bDesc = FALSE
    ok
next
chk("clusters strictly descend across x (RTL visual order)", bDesc)
# joining witness at word scale: seen WORD-INITIAL differs from seen ISOLATED
aSeenIso = StzEngineGpuTextLayout(hF, cSeen, 32)
# word-initial seen is the RIGHTMOST glyph = LAST in visual order
nSeenInWord = aAr[3][len(aAr[3])][1]
chk("word-initial seen id != isolated seen id", nSeenInWord != aSeenIso[3][1][1])

? ""
? "-- Scene 6: mixed direction -- 3 visual runs, orders opposed --"
aMix = StzEngineGpuTextLayout(hF, "abc " + cSoftanza + " xyz", 32)
chk("three visual runs", aMix[2] = 3)
chk("all glyphs present (4 + 8 + 4)", len(aMix[3]) = 16)
# the latin prefix occupies the visual LEFT (clusters 0..3), the latin
# suffix the visual RIGHT (clusters 12..), arabic between them
chk("first visual glyph is 'a' (cluster 0)", aMix[3][1][4] = 0)
# clusters are BYTE indices: "abc " = bytes 0..3, the 8 Arabic letters =
# bytes 4..19 (2 bytes each), " xyz" = bytes 20..23 -- 'z' sits at 23
chk("last visual glyph is 'z' (byte cluster 23)", aMix[3][16][4] = 23)
nArFirst = aMix[3][5][4]
nArLast = aMix[3][12][4]
chk("the Arabic segment's clusters DESCEND (RTL inside LTR)", nArFirst > nArLast)

? ""
? "-- Scene 7: raster BY GLYPH ID -- ink where there should be ink --"
aBm = StzEngineGpuGlyphBitmap(hF, nLigGid, 32)
chk("lam-alef bitmap has area", aBm[1] > 0 and aBm[2] > 0)
chk("bytes match w*h", len(aBm[5]) = aBm[1] * aBm[2])
nInk = 0
for _i_ = 1 to len(aBm[5])
    if ascii(substr(aBm[5], _i_, 1)) > 128
        nInk++
    ok
next
chk("real coverage (some pixels above half-ink)", nInk > 10)
chk("bitmap top sits above the baseline (yoff < 0)", aBm[4] < 0)
# whitespace: ink-free is the CORRECT answer, not an error
aSp = StzEngineGpuTextLayout(hF, " ", 32)
aSpBm = StzEngineGpuGlyphBitmap(hF, aSp[3][1][1], 32)
chk("space glyph answers ink-free [0x0]", aSpBm[1] = 0 and aSpBm[2] = 0)

? ""
? "-- Scene 8: refusals answer by name; churn is exact --"
hF2 = StzEngineGpuFontLoad(cFontBytes)
chk("second font loads (id differs)", hF2 > 0 and hF2 != hF)
chk("free answers OK", StzEngineGpuFontFree(hF2) = 0)
chk("double free answers STALE (2)", StzEngineGpuFontFree(hF2) = 2)
chk("layout on freed font answers []", len(StzEngineGpuTextLayout(hF2, "x", 32)) = 0)
chk("glyph count on freed font answers -1", StzEngineGpuFontGlyphCount(hF2) = -1)
chk("zero size refuses ([])", len(StzEngineGpuTextLayout(hF, "x", 0)) = 0)
chk("empty text refuses ([])", len(StzEngineGpuTextLayout(hF, "", 32)) = 0)

? ""
? "-- Scene 9: determinism -- same input, same ids, same positions --"
aA1 = StzEngineGpuTextLayout(hF, cSoftanza, 32)
aA2 = StzEngineGpuTextLayout(hF, cSoftanza, 32)
bSame = len(aA1[3]) = len(aA2[3]) and aA1[1] = aA2[1]
if bSame
    for _i_ = 1 to len(aA1[3])
        if aA1[3][_i_][1] != aA2[3][_i_][1] or aA1[3][_i_][2] != aA2[3][_i_][2]
            bSame = FALSE
        ok
    next
ok
chk("layout is deterministic (ids and positions)", bSame)

? ""
? "-- Scene 10: the FALLBACK CHAIN -- one font rarely covers all scripts --"
#
# Measured before the chain existed: this subset carries Arabic and Latin
# and has NO Hangul, Cyrillic, Greek, Hebrew or CJK -- so those shape to
# .notdef, which DRAWS, as one hollow box per character, and nothing
# counted them. A font may now name fonts to ask when it cannot answer.

# what the fixture cannot draw, stated rather than assumed
cHangul = char(0xEC) + char(0x95) + char(0x88) + char(0xEB) + char(0x85) + char(0x95)
aBare = StzEngineGpuTextLayout(hF, cHangul, 24)
chk("the fixture has no Hangul: two codepoints, two .notdef",
    len(aBare[3]) = 2 and aBare[11] = 2)
chk("...and it DOES carry Arabic and Latin, so the gap is the script and not the font",
    StzEngineGpuTextLayout(hF, cSoftanza, 24)[11] = 0 and
    StzEngineGpuTextLayout(hF, "Softanza", 24)[11] = 0)

# the chain's own verbs, which need no second font
chk("a font begins with no chain", StzEngineGpuFontFallbackCount(hF) = 0)
chk("NEGATIVE: a font cannot fall back to ITSELF -- that would make coverage a loop",
    StzEngineGpuFontAddFallback(hF, hF) != 0)
chk("NEGATIVE: nor to a font that was never loaded", StzEngineGpuFontAddFallback(hF, 999999) != 0)
chk("...and neither refusal grew the chain", StzEngineGpuFontFallbackCount(hF) = 0)

# THE COVERAGE SWITCH needs a second font carrying what the first lacks, and
# this repository commits ONE fixture. The scene names what it skipped rather
# than passing quietly, which is the house rule for a gate that cannot run.
cKo = "C:/Windows/Fonts/malgun.ttf"
if NOT fexists(cKo)
    ? "   (SKIPPED, by name: the coverage switch needs a Hangul font and this"
    ? "    machine has no " + cKo + ". The chain's verbs above were judged; the"
    ? "    switch itself was NOT, and is unjudged here rather than passed.)"
else
    hKo = StzEngineGpuFontLoad(read(cKo))
    chk("the second font loads", hKo > 0)
    chk("naming it is accepted", StzEngineGpuFontAddFallback(hF, hKo) = 0)
    chk("...and the chain says so", StzEngineGpuFontFallbackCount(hF) = 1)
    chk("naming it TWICE changes nothing -- the chain is a set, not a list of repeats",
        StzEngineGpuFontAddFallback(hF, hKo) = 0 and StzEngineGpuFontFallbackCount(hF) = 1)

    aNow = StzEngineGpuTextLayout(hF, cHangul, 24)
    chk("the same two codepoints now draw: no .notdef, and both came from the FALLBACK",
        aNow[11] = 0 and aNow[10] = 2)
    chk("each glyph says which font drew it, and it is not the one that was asked",
        aNow[3][1][9] = hKo and aNow[3][2][9] = hKo)
    chk("the width is a real width now, not two boxes wide",
        aNow[1] > 0 and fabs(aNow[1] - aBare[1]) > 0.5)

    # THE PRIMARY IS ALWAYS ASKED FIRST: a fallback must never take a glyph
    # the author's own font could have drawn.
    aMix = StzEngineGpuTextLayout(hF, "ab" + cHangul, 24)
    chk("a mixed string splits by coverage: the Latin stays with the font that was asked",
        aMix[10] = 2 and aMix[11] = 0 and
        aMix[3][1][9] = hF and aMix[3][2][9] = hF and aMix[3][3][9] = hKo)
    chk("NEGATIVE: with the chain cleared, the same string is two boxes again",
        StzEngineGpuFontClearFallbacks(hF) = 0 and
        StzEngineGpuTextLayout(hF, cHangul, 24)[11] = 2)

    # AND THE ARABIC STILL SHAPES. A chain that quietly changed the joining
    # of the script the font DOES carry would be a bad trade for coverage.
    StzEngineGpuFontAddFallback(hF, hKo)
    aAr = StzEngineGpuTextLayout(hF, cSoftanza, 24)
    chk("with a chain in place, the Arabic word shapes exactly as it did without one",
        aAr[11] = 0 and aAr[10] = 0 and len(aAr[3]) = len(StzEngineGpuTextLayout(hF, cSoftanza, 24)[3]))
    StzEngineGpuFontFree(hKo)
ok

? ""
? "-- Scene 11: the flow can be a COLUMN -- vertical writing (GR2d) --"
#
# Vertical is not a rotated line. It selects the font's VERTICAL metrics
# and its vertical FORMS, which is why a comma sits in the corner a
# vertical reader expects rather than under the character. HarfBuzz does
# that from the direction alone -- the plan's claim that CJK vertical was
# an opportunity bought with the shaper and no new vendor.

aHz = StzEngineGpuTextLayout(hF, "Softanza", 32)
aVt = StzEngineGpuTextLayoutXT(hF, "Softanza", 32, 1)
chk("both answer 16 items now: the flow's own extent, which axis it is, and the fit",
    len(aHz) = 16 and len(aVt) = 16)
chk("a horizontal layout fills the WIDTH and says it is not vertical",
    aHz[1] > 0 and aHz[12] = 0 and aHz[13] = 0)
chk("a vertical layout fills the HEIGHT instead, and says which it is",
    aVt[12] > 0 and aVt[1] = 0 and aVt[13] = 1)
chk("the same text, the same glyph count -- a column is a flow, not a filter",
    len(aHz[3]) = len(aVt[3]))

# THE PEN WALKS DOWN. The renderer draws at (y - glyph.y), so a column is
# written as a DESCENDING y -- the same subtraction that lifts a mark above
# a baseline walks a column down the page, which is why no renderer here
# needed changing.
aGv = aVt[3]
bDown = TRUE
bAdv = TRUE
for iV = 2 to len(aGv)
	if NOT (aGv[iV][3] < aGv[iV - 1][3])  bDown = FALSE  ok
next
for iV = 1 to len(aGv)
	if NOT (aGv[iV][6] > 0)  bAdv = FALSE  ok
next
chk("every glyph sits below the one before it -- the pen walks DOWN the column", bDown)
chk("...and each advance is a positive DISTANCE, not the shaper's own negative", bAdv)
# the PEN, not the drawn y: a glyph's y carries its own vertical offset
# (HarfBuzz places it against the vertical origin), so the drawn position
# and the pen's travel are two different numbers and only one of them adds up
chk("the column's height is exactly where the pen arrived: the last pen plus its advance",
    fabs(aVt[12] - (aGv[len(aGv)][5] + aGv[len(aGv)][6])) < 0.01)

# NEGATIVE: the horizontal layout of the same text does the opposite, so
# neither assertion can be passing on something that never moved.
aGh = aHz[3]
bRight = TRUE
bFlat = TRUE
for iV = 2 to len(aGh)
	if NOT (aGh[iV][2] > aGh[iV - 1][2])  bRight = FALSE  ok
	if NOT (fabs(aGh[iV][3] - aGh[1][3]) < 0.01)  bFlat = FALSE  ok
next
chk("NEGATIVE: horizontally the same text walks RIGHT and stays on one baseline", bRight and bFlat)

# THE VERTICAL FORMS are the point, and they need a font that has them.
# This repository commits an Arabic subset, so the check names what it
# skipped rather than passing quietly.
cCjk = "C:/Windows/Fonts/malgun.ttf"
if NOT fexists(cCjk)
	? "   (SKIPPED, by name: the vertical FORMS need a CJK font and this"
	? "    machine has no " + cCjk + ". The flow above was judged; the"
	? "    substitution itself is UNJUDGED here rather than passed.)"
else
	hCjk = StzEngineGpuFontLoad(read(cCjk))
	chk("the CJK font loads", hCjk > 0)
	# a bracket and a comma: the two characters whose vertical forms differ
	cBr = char(0xE3) + char(0x80) + char(0x8C)      # 「
	cCm = char(0xE3) + char(0x80) + char(0x81)      # 、
	cKa = char(0xE3) + char(0x81) + char(0x82)      # あ
	cPunct = cBr + cKa + cCm + cKa
	aPh = StzEngineGpuTextLayout(hCjk, cPunct, 32)
	aPv = StzEngineGpuTextLayoutXT(hCjk, cPunct, 32, 1)
	chk("the same characters, the same count, both ways",
	    len(aPh[3]) = len(aPv[3]) and len(aPh[3]) = 4)
	nSubst = 0
	for iV = 1 to len(aPh[3])
		if aPh[3][iV][1] != aPv[3][iV][1]  nSubst++  ok
	next
	? "   glyphs the vertical forms replaced : " + nSubst + " of " + len(aPh[3])
	chk("THE VERTICAL FORMS FIRE: the bracket and the comma are different GLYPHS " +
	    "down a column -- this is typography, not a rotation", nSubst = 2)
	chk("...and the letter between them is the SAME glyph, so the substitution is " +
	    "chosen per character and not applied to everything",
	    aPh[3][2][1] = aPv[3][2][1] and aPh[3][4][1] = aPv[3][4][1])
	StzEngineGpuFontFree(hCjk)
ok

? ""
? "-- Scene 12: a line that FILLS a width -- kashida justification (GR2e) --"
#
# Latin justifies BETWEEN the words; Arabic justifies INSIDE them, by
# elongating the stroke that joins two letters. A page of Arabic stretched
# on its spaces alone has rivers of white down it and reads as a page set
# by somebody who did not know the script. So the engine elongates first
# and spends the remainder on the spaces, which is why a justified line
# lands on its target EXACTLY while kashidas are discrete.

cJAr = "الحمد لله رب العالمين"
aJ0 = StzEngineGpuTextLayout(hF, cJAr, 32)
aJ1 = StzEngineGpuTextLayoutJustified(hF, cJAr, 32, aJ0[1] + 60)
? "   natural " + aJ0[1] + "px -> justified " + aJ1[1] + "px, " + aJ1[15] +
  " kashidas and " + aJ1[16] + "px on each space"
chk("the layout answers 16 items now: the three that say what justification did",
    len(aJ0) = 16 and len(aJ1) = 16)
chk("A JUSTIFIED LINE LANDS ON ITS TARGET, not near it -- the kashidas take it " +
    "most of the way and the spaces close the rest",
    fabs(aJ1[1] - (aJ0[1] + 60)) < 0.01 and aJ1[14] = 1)
chk("IT IS KASHIDA AND NOT WIDER SPACES: tatweels were inserted, so the line grew " +
    "GLYPHS the natural line does not have",
    aJ1[15] > 0 and len(aJ1[3]) > len(aJ0[3]))
# WHERE THE KASHIDA GOES IS A CALLIGRAPHIC RULE, NOT "EVERYWHERE IT FITS".
# The first version of this engine elongated every join the font allowed,
# and the Principal marked the render up in red: in Arabic a kashida does
# not apply to all letters, only to the one before the last. So a word
# takes ONE elongation, at the join before its final letter, and a longer
# kashida is that one join drawn longer.
#
# THE WORD THAT SETTLES IT is one whose last two letters do NOT join while
# an earlier pair does. In برد the reh refuses to join forward, so the
# join before the last letter does not exist -- and the FIRST join, beh to
# reh, does. Under the old rule that word was stretched; under the rule it
# has now it takes nothing, and the difference is exactly the finding.
chk("a word takes its elongation at the join before its LAST letter",
    _KashidasOf("بحر", aJ0[1]) > 0 and _KashidasOf("الحمد", aJ0[1]) > 0)
chk("NEGATIVE: a word whose last two letters do not join takes NO kashida, even " +
    "though an earlier join in the same word would have taken one",
    _KashidasOf("برد", aJ0[1]) = 0 and _KashidasOf("رب", aJ0[1]) = 0)

# AND AN ELONGATION MAY ADD INK, NEVER LOSE ANY. The same render lost the
# SHADDA over the name of God: this face writes lam-lam-heh with a
# contextual glyph that CARRIES the mark, and a tatweel between the letters
# stopped the rule matching. A diacritic is a letter and its absence
# changes the word, so the word refuses the elongation instead.
aJSh = StzEngineGpuTextLayout(hF, "لله", 32)
aJSj = StzEngineGpuTextLayoutJustified(hF, "لله", 32, aJSh[1] + 30)
? "   the name of God reaches " + aJSh[8] + "px above the baseline, and after " +
  "justification " + aJSj[8] + "px"
chk("NEGATIVE: the word whose mark an elongation would destroy REFUSES to be " +
    "elongated, and keeps every bit of its ink",
    aJSj[15] = 0 and aJSj[8] = aJSh[8] and aJSj[9] = aJSh[9])
chk("...and the whole justified line loses no ink either, above the baseline or below",
    aJ1[8] >= aJ0[8] - 0.01 and aJ1[9] >= aJ0[9] - 0.01)

# THE CLUSTERS STILL INDEX THE CALLER'S STRING. The engine justifies by
# shaping a text with tatweels inserted, so every cluster it gets back
# indexes a string the caller never saw. Left unmapped, a caret rect and a
# hit test would answer confidently about the wrong character.
nJMax = 0
bJIn = TRUE
for iJ = 1 to len(aJ1[3])
	if aJ1[3][iJ][4] > nJMax  nJMax = aJ1[3][iJ][4]  ok
	if aJ1[3][iJ][4] > len(cJAr) or aJ1[3][iJ][7] > len(cJAr)  bJIn = FALSE  ok
next
chk("every cluster still indexes the CALLER'S string, not the elongated one the " +
    "engine shaped -- reversibility survives justification", bJIn and nJMax < len(cJAr))

# THE GEOMETRY STILL ADDS UP. The spaces were widened after shaping, so
# the pens had to be shifted with them; if the shift were dropped the
# glyphs would overlap and nothing else here would notice.
nJSum = 0
bJMono = TRUE
for iJ = 1 to len(aJ1[3])
	nJSum += aJ1[3][iJ][6]
	if iJ > 1 and aJ1[3][iJ][5] < aJ1[3][iJ - 1][5]  bJMono = FALSE  ok
next
chk("the advances still sum to the width and the pen still runs left to right, " +
    "so the widened spaces carried their neighbours with them",
    fabs(nJSum - aJ1[1]) < 0.05 and bJMono)

# LATIN GETS THE OTHER HALF, and the negative sibling is what makes the
# Arabic assertion mean something: the same call on Latin inserts NO
# kashida, because the face joins nothing there.
cJLat = "the quick brown fox jumps"
aL0 = StzEngineGpuTextLayout(hF, cJLat, 32)
aL1 = StzEngineGpuTextLayoutJustified(hF, cJLat, 32, aL0[1] + 40)
chk("NEGATIVE: Latin is justified on its SPACES ALONE -- no kashida, because the " +
    "face joins nothing there",
    aL1[15] = 0 and aL1[16] > 0 and fabs(aL1[1] - (aL0[1] + 40)) < 0.01)
chk("...and the space stretch is the deficit shared out, not a guess",
    fabs(aL1[16] * 4 - 40) < 0.01)

# TWO REFUSALS, both saying so in the answer rather than by looking normal.
aJN = StzEngineGpuTextLayoutJustified(hF, cJAr, 32, aJ0[1] - 20)
chk("NEGATIVE: a target NARROWER than the text returns the text -- this stretches " +
    "and never compresses, and it says justified=0",
    fabs(aJN[1] - aJ0[1]) < 0.01 and aJN[14] = 0 and aJN[15] = 0)
aJW = StzEngineGpuTextLayoutJustified(hF, "Unbreakable", 32, 400)
chk("NEGATIVE: one Latin word has no join and no space, so nothing is stretched " +
    "and the layout says so rather than inventing room",
    aJW[14] = 0 and aJW[15] = 0 and aJW[16] = 0)

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

func _KashidasOf pcWord, pnUnused
	_a_ = StzEngineGpuTextLayout(hF, pcWord, 32)
	_j_ = StzEngineGpuTextLayoutJustified(hF, pcWord, 32, _a_[1] + 30)
	return _j_[15]
