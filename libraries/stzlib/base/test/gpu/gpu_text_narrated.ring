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
# 7 items since the reversibility fields landed (§0 of the GUI plane):
# width, runs, glyphs, ascender, descender, lineGap, paraRtl. They were
# APPENDED, never reordered -- items 1..3 mean what they always meant.
chk("layout answers width, runs, glyphs and metrics", len(aLat) = 7)
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
for _g_ in aG
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
for _g_ in aLB[3]
    if _g_[4] = 0
        nLamInit = _g_[1]
    ok
next
aBA = StzEngineGpuTextLayout(hF, cBeh + cAlef, 32)
nAlefFin = 0
for _g_ in aBA[3]
    if _g_[4] = 2
        nAlefFin = _g_[1]
    ok
next
bSpecial = TRUE
for _g_ in aLA[3]
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
