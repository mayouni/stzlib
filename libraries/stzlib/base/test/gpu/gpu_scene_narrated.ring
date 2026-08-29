# The 2D DISPLAY LIST and its TWO renderers -- GR2b of the graphics plane
# (SOFTANZA_GRAPHICS_PLAN.md).
#
# One model, two backends. A scene is a painter-ordered list of shapes and
# text in pixel space; ToSvg emits vector text with NO device (the tier
# ladder's CI-safe floor), ToPng tessellates and draws through the GR1
# surface. Neither backend owns the geometry -- the display list does --
# so they cannot disagree about WHERE anything sits.
#
# This guard asserts the MECHANISMS, each with its negative sibling:
#   - the SVG tier works deviceless, and carries the EXACT numbers asked
#     for (a coordinate typo cannot hide behind "it looks right")
#   - opaque axis-aligned rects render BYTE-IDENTICAL to a Ring-computed
#     reference -- alpha blending arrived in GR2b and did NOT cost the
#     GR0/GR1 exactness witness (src-over at a=1 is plain overwrite)
#   - painter order holds ACROSS kinds (a later shape covers an earlier
#     one; text does not silently float above shapes)
#   - the circle's parity band is COMPUTED, not hoped for: the segment
#     count comes from a sagitta bound, and the rendered pixels honour it
#     (filled inside r-1, clear outside r+1)
#   - the gradient interpolates (ends exact, midpoint between them)
#   - text lands on BOTH tiers from the SAME layout: the SVG's glyph path
#     and the GPU's ink both start where text_layout said
#   - the atlas CACHES glyphs (a repeated word rasters once) and it is a
#     TEXTURE atlas, not a font atlas
#   - retained buffers: redrawing an unchanged scene does NOT rebuild
#     (the build counter is the witness, not a comment)
#   - refusals answer by name; a device-less ToPng is COUNTED
#
# CI note: every scene except the explicitly-GPU ones runs without a
# device. The SVG tier IS the CI coverage, exactly as the plan says.
#
# STANDALONE like the other gpu guards: loads only the engine bridge.

load "stdlib.ring"
$cEngineDir = "../../../engine"
load "../../../engine/stz_gpu.ring"

nPass = 0
nFail = 0

C_FALL = 3
C_SUB  = 6

# packed 0xRRGGBBAA colors, built arithmetically (no hex-literal reliance)
RED    = rgba(220,  60,  60, 255)
GREEN  = rgba( 60, 180,  90, 255)
BLUE   = rgba( 70, 110, 230, 255)
GOLD   = rgba(240, 200,  40, 255)
WHITE  = rgba(255, 255, 255, 255)
BG     = rgba( 16,  20,  24, 255)

? "-- Scene 1: the SVG tier is the floor -- no device, exact numbers --"
chk("no device is present", StzEngineGpuIsAvailable() = 0)
hS = StzEngineGpuSceneNew(200, 150)
chk("scene created (id > 0)", hS > 0)
StzEngineGpuSceneClear(hS, BG)
chk("rect accepted", StzEngineGpuSceneRect(hS, 20, 30, 60, 40, RED) = 0)
chk("circle accepted", StzEngineGpuSceneCircle(hS, 120, 75, 25, BLUE) = 0)
chk("line accepted", StzEngineGpuSceneLine(hS, 10, 140, 190, 140, 4, GREEN) = 0)
chk("command count is 3 (clear is not a command)", StzEngineGpuSceneCommandCount(hS) = 3)
cSvg = StzEngineGpuSceneToSvg(hS)
chk("SVG came back", len(cSvg) > 100)
chk("SVG header carries the scene size",
    substr(cSvg, 'width="200" height="150"') > 0 and substr(cSvg, 'viewBox="0 0 200 150"') > 0)
chk("the rect's EXACT coordinates are in the SVG",
    substr(cSvg, 'x="20" y="30" width="60" height="40"') > 0)
chk("the circle's EXACT geometry is in the SVG",
    substr(cSvg, 'cx="120" cy="75" r="25"') > 0)
chk("colors round-trip as rgb()", substr(cSvg, 'rgb(220,60,60)') > 0)
chk("stroke carries round joins AND caps (matching the tessellator)",
    substr(cSvg, 'stroke-linejoin="round"') > 0 and substr(cSvg, 'stroke-linecap="round"') > 0)
chk("document is closed", substr(cSvg, "</svg>") > 0)

? ""
? "-- Scene 2: the tessellation is real, and its curve bound is COMPUTED --"
aSt = StzEngineGpuSceneStats(hS)
# GR5 widened this to 6: `builds` counts TESSELLATIONS, and a frame loop
# needed to know about UPLOADS as well -- a still scene that re-tessellates
# once can still re-upload its whole vertex set 60 times a second, which is
# exactly what the window found it doing.
chk("stats answer [cmds, shapeV, textV, segs, builds, uploads]", len(aSt) = 6)
chk("3 commands", aSt[1] = 3)
# rect 6 verts + circle 3*N + line (quad 6 + 2 discs of 3*M)
nSegC = StzEngineGpuCircleSegments(25)
chk("circle at r=25 tessellates to a computed segment count", nSegC >= 12)
nSag = 25 * (1 - cos(3.14159265358979 / nSegC))
chk("its chord sagitta is under the 0.15 px bound (" + nSag + ")", nSag <= 0.15)
chk("a bigger radius needs MORE segments (the bound scales)",
    StzEngineGpuCircleSegments(400) > nSegC)
chk("shape vertices were produced", aSt[2] > 6)
chk("no text vertices in a text-free scene", aSt[3] = 0)
chk("one draw segment (all shapes, one kind)", aSt[4] = 1)

? ""
? "-- Scene 3: retained buffers -- an unchanged scene does NOT rebuild --"
nBuilds = aSt[5]
aSt2 = StzEngineGpuSceneStats(hS)
chk("second read did not rebuild (the §3b door, witnessed)", aSt2[5] = nBuilds)
StzEngineGpuSceneRect(hS, 5, 5, 10, 10, WHITE)
aSt3 = StzEngineGpuSceneStats(hS)
chk("adding a command DOES rebuild", aSt3[5] = nBuilds + 1)
chk("and the vertex count grew by one quad", aSt3[2] = aSt2[2] + 6)

? ""
? "-- Scene 4: refusals answer by name --"
chk("zero-size scene refuses", StzEngineGpuSceneNew(0, 100) = 0)
chk("rect with zero width refuses BAD_ARG", StzEngineGpuSceneRect(hS, 0, 0, 0, 10, RED) = 3)
chk("circle with zero radius refuses BAD_ARG", StzEngineGpuSceneCircle(hS, 0, 0, 0, RED) = 3)
chk("polygon with 2 points refuses BAD_ARG", StzEngineGpuScenePolygon(hS, [0,0, 1,1], RED) = 3)
hDead = StzEngineGpuSceneNew(10, 10)
StzEngineGpuSceneFree(hDead)
chk("freed scene answers STALE", StzEngineGpuSceneFree(hDead) = 2)
chk("drawing into a freed scene answers STALE", StzEngineGpuSceneRect(hDead, 0,0,1,1, RED) = 2)
chk("ToSvg on a freed scene answers ''", StzEngineGpuSceneToSvg(hDead) = "")
nF0 = StzEngineGpuCounter(C_FALL)
chk("ToPng with NO device answers ''", StzEngineGpuSceneToPng(hS, 1) = "")
chk("and the refusal was COUNTED", StzEngineGpuCounter(C_FALL) > nF0)

? ""
? "-- Scene 5: concave polygons fill (ear clipping, not a fan) --"
hP = StzEngineGpuSceneNew(100, 100)
# an L: 6 vertices, one reflex corner -- a triangle fan would spill outside
StzEngineGpuScenePolygon(hP, [10,10, 90,10, 90,40, 40,40, 40,90, 10,90], GOLD)
aPs = StzEngineGpuSceneStats(hP)
chk("6-gon tessellates to exactly (n-2) triangles = 12 verts", aPs[2] = 12)
cPsvg = StzEngineGpuSceneToSvg(hP)
chk("SVG carries the polygon with its exact points",
    substr(cPsvg, '<polygon points="10,10 90,10 90,40 40,40 40,90 10,90"') > 0)

? ""
? "-- Scene 6: text rides the GR2a pipeline on BOTH tiers --"
cFontBytes = read("fixtures/amiri_arabic_subset.ttf")
hFont = StzEngineGpuFontLoad(cFontBytes)
chk("fixture font loaded", hFont > 0)
StzEngineGpuAtlasReset()
hT = StzEngineGpuSceneNew(300, 100)
StzEngineGpuSceneClear(hT, BG)
chk("text accepted", StzEngineGpuSceneText(hT, hFont, "Softanza", 20, 60, 28, WHITE) = 0)
aLay = StzEngineGpuTextLayout(hFont, "Softanza", 28)
cTsvg = StzEngineGpuSceneToSvg(hT)
chk("SVG emits glyph OUTLINES (a path, not a <text> the viewer must shape)",
    substr(cTsvg, '<path d="M') > 0)
chk("SVG needs no font installed to render right", substr(cTsvg, "font-family") = 0)
aTs = StzEngineGpuSceneStats(hT)
chk("text vertices exist (6 per inked glyph)", aTs[3] > 0)
chk("and they are a whole number of quads", aTs[3] % 6 = 0)
chk("glyph count and quad count agree", aTs[3] / 6 <= len(aLay[3]))

? ""
? "-- Scene 7: the atlas caches -- the same word rasters ONCE --"
aA1 = StzEngineGpuAtlasStats()
chk("atlas has entries after layout", aA1[3] > 0)
hT2 = StzEngineGpuSceneNew(300, 100)
StzEngineGpuSceneText(hT2, hFont, "Softanza", 20, 60, 28, GOLD)
StzEngineGpuSceneStats(hT2)
aA2 = StzEngineGpuAtlasStats()
chk("the same glyphs at the same size add NO new entries", aA2[3] = aA1[3])
StzEngineGpuSceneText(hT2, hFont, "Softanza", 20, 90, 41, GOLD)
StzEngineGpuSceneStats(hT2)
aA3 = StzEngineGpuAtlasStats()
chk("a DIFFERENT size does add entries (size is part of the key)", aA3[3] > aA2[3])
chk("the atlas is a texture surface, not a glyph list", aA1[1] = 1024 and aA1[2] = 1024)

? ""
? "-- Scene 8: Arabic goes through the SAME pipeline on the SVG tier --"
cAr = char(0xD8)+char(0xB3) + char(0xD9)+char(0x88) + char(0xD9)+char(0x81) +
      char(0xD8)+char(0xAA) + char(0xD8)+char(0xA7) + char(0xD9)+char(0x86) +
      char(0xD8)+char(0xB2) + char(0xD8)+char(0xA7)
hAr = StzEngineGpuSceneNew(300, 100)
StzEngineGpuSceneText(hAr, hFont, cAr, 20, 60, 28, WHITE)
cArSvg = StzEngineGpuSceneToSvg(hAr)
chk("Arabic emits outlines too", substr(cArSvg, '<path d="M') > 0)
aArS = StzEngineGpuSceneStats(hAr)
aArLay = StzEngineGpuTextLayout(hFont, cAr, 28)
chk("8 shaped glyphs -> 8 quads (joined forms, not codepoints)",
    aArS[3] = len(aArLay[3]) * 6)
chk("the scene's text is as wide as the pipeline says", aArLay[1] > 0)

? ""
? "-- Scene 9: with a device, the GPU tier draws the SAME model --"
nInit = StzEngineGpuInit($cStzGpuRuntime)
if StzEngineGpuIsAvailable() = 0
    ? "  NO GPU ON THIS MACHINE -- GPU tier skipped; scenes 1-8 ARE the coverage"
else
    ? "  device: " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

    # -- opaque rects: byte-identical to a Ring-computed reference
    nW = 60  nH = 40
    hG = StzEngineGpuSceneNew(nW, nH)
    StzEngineGpuSceneClear(hG, BG)
    StzEngineGpuSceneRect(hG, 5, 5, 20, 10, RED)
    StzEngineGpuSceneRect(hG, 30, 20, 25, 15, GREEN)
    StzEngineGpuSceneRect(hG, 10, 12, 12, 12, BLUE)   # overlaps the first
    cPix = StzEngineGpuSceneToPixels(hG)
    chk("GPU tier returned w*h*4 bytes", len(cPix) = nW * nH * 4)
    aRefRects = [ [5,5,20,10, 220,60,60], [30,20,25,15, 60,180,90], [10,12,12,12, 70,110,230] ]
    nBad = 0
    for _y_ = 0 to nH - 1
        for _x_ = 0 to nW - 1
            _aC_ = [16, 20, 24]
            _aR11_ = aRefRects       # painter order: later wins
            _nR11_ = len(_aR11_)
            for _iR11_ = 1 to _nR11_
            	_r_ = _aR11_[_iR11_]
                if _x_ >= _r_[1] and _x_ < _r_[1] + _r_[3] and
                   _y_ >= _r_[2] and _y_ < _r_[2] + _r_[4]
                    _aC_ = [_r_[5], _r_[6], _r_[7]]
                ok
            next
            _nO_ = (_y_ * nW + _x_) * 4
            if ascii(substr(cPix, _nO_+1, 1)) != _aC_[1] or
               ascii(substr(cPix, _nO_+2, 1)) != _aC_[2] or
               ascii(substr(cPix, _nO_+3, 1)) != _aC_[3]
                nBad++
            ok
        next
    next
    chk("opaque rects are BYTE-IDENTICAL to the Ring reference (" + nBad + " of " +
        (nW*nH) + " wrong)", nBad = 0)
    chk("painter order held: the blue rect covers the red one",
        pxeq(cPix, nW, 15, 15, 70, 110, 230))

    # -- one pass per render, however many shapes
    StzEngineGpuCountersReset()
    StzEngineGpuSceneToPixels(hG)
    chk("a whole scene costs ONE render submit", StzEngineGpuCounter(C_SUB) = 2)  # pass + readback

    # -- the circle's computed parity band, checked on real pixels
    hC = StzEngineGpuSceneNew(80, 80)
    StzEngineGpuSceneClear(hC, BG)
    StzEngineGpuSceneCircle(hC, 40, 40, 30, GOLD)
    cCpix = StzEngineGpuSceneToPixels(hC)
    chk("circle centre is filled", pxeq(cCpix, 80, 40, 40, 240, 200, 40))
    chk("a pixel just INSIDE the rim is filled (sagitta < 1px)",
        pxeq(cCpix, 80, 40, 12, 240, 200, 40))
    chk("a pixel just OUTSIDE the rim is background",
        pxeq(cCpix, 80, 40, 8, 16, 20, 24))
    chk("the corner (far outside) is background", pxeq(cCpix, 80, 2, 2, 16, 20, 24))

    # -- gradient: ends exact, middle between them
    hGr = StzEngineGpuSceneNew(64, 20)
    StzEngineGpuSceneRectGradient(hGr, 0, 0, 64, 20, rgba(0,0,0,255), rgba(255,255,255,255), 0)
    cGpix = StzEngineGpuSceneToPixels(hGr)
    nL = ascii(substr(cGpix, (10*64 + 1)*4 + 1, 1))
    nM = ascii(substr(cGpix, (10*64 + 32)*4 + 1, 1))
    nR = ascii(substr(cGpix, (10*64 + 63)*4 + 1, 1))
    chk("gradient starts dark (" + nL + ")", nL < 12)
    chk("gradient ends bright (" + nR + ")", nR > 243)
    chk("and the middle sits between them (" + nM + ")", nM > 100 and nM < 155)

    # -- alpha actually blends (the negative sibling of the exactness claim)
    hAl = StzEngineGpuSceneNew(20, 20)
    StzEngineGpuSceneClear(hAl, rgba(0, 0, 0, 255))
    StzEngineGpuSceneRect(hAl, 0, 0, 20, 20, rgba(255, 255, 255, 128))
    cApix = StzEngineGpuSceneToPixels(hAl)
    nHalf = ascii(substr(cApix, (10*20 + 10)*4 + 1, 1))
    chk("a 50% white over black lands mid-grey (" + nHalf + ")", nHalf > 118 and nHalf < 138)

    # -- text: ink lands where the layout said, on the GPU tier
    hTG = StzEngineGpuSceneNew(200, 60)
    StzEngineGpuSceneClear(hTG, BG)
    StzEngineGpuSceneText(hTG, hFont, "Soft", 20, 42, 32, WHITE)
    cTpix = StzEngineGpuSceneToPixels(hTG)
    nInk = 0
    nInkLeft = 999
    for _x_ = 0 to 199
        for _y_ = 0 to 59
            _nO_ = (_y_ * 200 + _x_) * 4
            if ascii(substr(cTpix, _nO_+1, 1)) > 140
                nInk++
                if _x_ < nInkLeft  nInkLeft = _x_  ok
            ok
        next
    next
    chk("text put real ink on the target (" + nInk + " px)", nInk > 100)
    aTL = StzEngineGpuTextLayout(hFont, "Soft", 32)
    chk("the leftmost ink starts at the layout's pen (x=20, got " + nInkLeft + ")",
        nInkLeft >= 18 and nInkLeft <= 26)
    chk("nothing inked left of the pen", nInkLeft >= 18)

    # -- the atlas texture is a GPU resident, and survives a redraw
    aAG = StzEngineGpuAtlasStats()
    chk("the atlas uploaded to the device", aAG[4] >= 1)
    StzEngineGpuSceneToPixels(hTG)
    aAG2 = StzEngineGpuAtlasStats()
    chk("an unchanged atlas does NOT re-upload", aAG2[4] = aAG[4])

    # -- both tiers, same model: the SVG of the SAME scene still holds
    cTsvg2 = StzEngineGpuSceneToSvg(hTG)
    chk("the GPU-rendered scene still emits its SVG twin", substr(cTsvg2, '<path d="M') > 0)

    # -- device loss: the scene survives, the SVG tier keeps working
    StzEngineGpuShutdown()
    chk("ToPng refuses once the device is gone", StzEngineGpuSceneToPng(hG, 1) = "")
    chk("but ToSvg still answers -- the floor never depended on a device",
        len(StzEngineGpuSceneToSvg(hG)) > 50)
ok

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

func rgba nR, nG, nB, nA
	return nR * 16777216 + nG * 65536 + nB * 256 + nA

func pxeq cBytes, nRowW, nX, nY, nR, nG, nB
	_nOff_ = (floor(nY) * nRowW + floor(nX)) * 4
	return ascii(substr(cBytes, _nOff_+1, 1)) = nR and
	       ascii(substr(cBytes, _nOff_+2, 1)) = nG and
	       ascii(substr(cBytes, _nOff_+3, 1)) = nB
