# THE GUI PLANE, G1 -- base/gui/SOFTANZA_GUI_PLAN.md.
#
# The render interface, end to end. RmlUi lays a document out and hands
# back TRIANGLES; the graphics plane draws them. Nothing in this plane
# paints, which is why a panel gets ToSVG() on a machine with no GPU and
# ToPNG() on one with a device without knowing which it is on.
#
# WHAT IS ASSERTED, and it is the MECHANISM rather than the look:
#   - the display list's new mesh primitive carries triangles through
#     BOTH renderers, and refuses a malformed one at the door
#   - a panel lays out: named elements have the boxes flexbox implies,
#     and the layout MOVES when the panel is resized
#   - the panel's triangles reach a canvas, and the canvas answers on
#     both tiers
#   - the bounded record COUNTS what it cannot draw
#   - and KILL CRITERION 3 of G0, deferred to here because it needs a
#     real render: is text legible in a texture mapped at an oblique
#     angle?
#
# The device-free scenes run first and are this suite's CI coverage. The
# 3D scenes are gated on a GPU being present, the way every graphics
# guard in the house gates them.

load "../../stzBase.ring"

nPass = 0
nFail = 0

# A panel's root does NOT fill its context on its own -- found in G1 and
# recorded in the plan's divergence table. `width: 100%` is what makes a
# document occupy the panel it was given.
cStyle = 'body { display: flex; flex-direction: column; width: 100%; height: 100%; }' +
	' #bar { display: flex; flex-direction: row; height: 48px; background: #2b6cb0; width: 100%; }' +
	' #body { display: flex; flex-direction: row; flex: 1 1 auto; width: 100%; background: #1a202c; }' +
	' #side { width: 160px; flex-shrink: 0; background: #2d3748; }' +
	' #main { flex: 1 1 auto; background: #4a5568; }'

cDoc = '<rml><head><style>' + cStyle + '</style></head><body>' +
	'<div id="bar"/><div id="body"><div id="side"/><div id="main"/></div>' +
	'</body></rml>'

? "-- Scene 1: the display list learned to take TRIANGLES --"
# Every other Add* names a shape and lets the engine tessellate. A UI
# toolkit arrives having already tessellated, so this is the other door.
oC = new stzCanvas(200, 100)
oC.SetBackground("#101010")
aV = [ 10,10, 255,0,0,255,   90,10, 255,0,0,255,   90,90, 255,0,0,255,
       10,90, 255,0,0,255,  110,10, 0,255,0,255,  190,10, 0,255,0,255,
       150,90, 0,255,0,255 ]
oC.AddMesh(aV, [ 0,1,2,  0,2,3,  4,5,6 ])
chk("three triangles are ONE display-list command", oC.ShapeCount() = 1)
cSvg = oC.ToSVG()
chk("the SVG tier draws one polygon per triangle", len(StzFindCS("<polygon", cSvg, 1)) = 3)
chk("...and it carries the per-vertex colour", StzFindFirst("rgb(255,0,0)", cSvg) > 0)
chk("...including the SECOND triangle's, which differs",
    StzFindFirst("rgb(0,255,0)", cSvg) > 0)

# the negative siblings: a mesh that cannot be drawn is REFUSED at the
# door, not at draw time, because an out-of-range index would read
# someone else's memory during tessellation
chk("an index past the last vertex is refused",
    StzEngineGpuSceneMesh(oC.Id_(), aV, [ 0, 1, 99 ]) != 0)
chk("a vertex list that is not a multiple of 6 is refused",
    StzEngineGpuSceneMesh(oC.Id_(), [ 1,2,3,4,5 ], [ 0,0,0 ]) != 0)
chk("an index count that is not a multiple of 3 is refused",
    StzEngineGpuSceneMesh(oC.Id_(), aV, [ 0, 1 ]) != 0)
chk("...and none of those three was added", oC.ShapeCount() = 1)

? ""
? "-- Scene 2: is there a layout engine on this machine? --"
bGui = StzGuiAvailable()
chk("StzGuiAvailable answers without raising", bGui = 1 or bGui = 0)
if bGui = 0
	? "   stz_gui.dll is absent -- a legitimate state, like a missing window."
	? "   Every scene below needs it, so they are skipped, not failed."
	? ""
	? "=============================================================="
	? " " + nPass + " ok, " + nFail + " failed"
	? "=============================================================="
	return
ok

? ""
? "-- Scene 3: a document lays itself out --"
oP = new stzPanel(640, 400)
oP.LoadMarkup(cDoc)
oP.Layout()
aBar = oP.BoxOf("bar")
aSide = oP.BoxOf("side")
aMain = oP.BoxOf("main")
? "   #bar  " + @@(aBar)
? "   #side " + @@(aSide)
? "   #main " + @@(aMain)
chk("the bar spans the panel's width", aBar[3] = 640)
chk("...at its declared height", aBar[4] = 48)
chk("the sidebar keeps its declared 160px", aSide[3] = 160)
chk("...and sits BELOW the bar, not beside it", aSide[2] = 48)
chk("main takes the rest of the row", aMain[3] = 640 - 160)
chk("...starting where the sidebar ends", aMain[1] = 160)
chk("an element that does not exist answers []", len(oP.BoxOf("nope")) = 0)

? ""
? "-- Scene 4: it is layout, not arithmetic done once --"
# The negative sibling for scene 3: if the boxes were computed from the
# markup rather than laid out, they would not MOVE when the panel does.
oP.Resize(320, 400)
aSide2 = oP.BoxOf("side")
aMain2 = oP.BoxOf("main")
chk("after a resize the sidebar still holds 160", aSide2[3] = 160)
chk("...and main shrank with the panel", aMain2[3] = 320 - 160)
chk("...which is a DIFFERENT number than before", aMain2[3] != aMain[3])
oP.Resize(640, 400)

? ""
? "-- Scene 5: the triangles come across, and the record counts --"
nTris = oP.TriangleCount()
aCount = oP.Counters()
? "   triangles " + nTris + "   counters " + @@(aCount)
chk("four coloured boxes became triangles", nTris >= 8)
chk("every draw RmlUi asked for was recorded", aCount[1] > 0)
# the bounded record's own account: G1 has no texture path and no
# clipping, so both must read zero on a document that needs neither --
# and a nonzero reading later is exactly what G2 turns on
chk("no textured draw was dropped on this document", aCount[2] = 0)
chk("no scissor region was ignored", aCount[3] = 0)
chk("the stub font engine was never asked to draw", aCount[5] = 0)

aVerts = oP.Verts()
chk("the vertex list is 6 numbers per vertex", len(aVerts) % 6 = 0)
chk("...and there are at least 3 vertices per triangle",
    len(aVerts) / 6 >= 3)
# colours arrive as 0..255 channels, un-premultiplied by the recorder
bChan = 1
nVL = len(aVerts)
for i = 3 to nVL step 6
	if aVerts[i] < 0 or aVerts[i] > 255
		bChan = 0
	ok
next
chk("every colour channel is inside 0..255", bChan = 1)

? ""
? "-- Scene 6: a panel is a picture, on whichever tier this box has --"
oCanvas = new stzCanvas(640, 400)
oCanvas.SetBackground("#000000")
chk("the panel draws into a canvas", oP.DrawInto(oCanvas) = 1)
chk("...as ONE display-list command", oCanvas.ShapeCount() = 1)
cPanelSvg = oCanvas.ToSVG()
chk("the SVG tier renders it with no device at all", len(cPanelSvg) > 200)
chk("...and the bar's declared blue survived the whole seam",
    StzFindFirst("rgb(43,108,176)", cPanelSvg) > 0)
# #2b6cb0 is (43,108,176). It reached SVG through RmlUi's premultiplied
# vertex colour and the recorder's division back to straight alpha -- so
# this one assertion covers that seam end to end. A recorder that forgot
# to un-premultiply would still be right for opaque colours, which is why
# scene 5 checks the channel range too.
chk("...and the sidebar's, which is a different colour",
    StzFindFirst("rgb(45,55,72)", cPanelSvg) > 0)

? ""
? "-- Scene 7: RML IS NOT HTML, and the loader is LENIENT about it --"
# Two divergences from the survey's expectations, both found by contact
# and both consequential for the emitter (§3, §4 of the plan).
#
# FIRST: an unclosed <br> does not parse -- RML is XML syntax -- but the
# loader does NOT refuse. It logs the parse error and hands back a
# PARTIAL document. So an emitter bug produces a broken screen silently,
# and this plane must check LastEngineMessage rather than trust a status.
nStatus = StzEngineGuiLoadRml(oP.Id_(), '<rml><body><br></body></rml>')
cMsg = oP.LastEngineMessage()
? "   unclosed <br> -> status " + nStatus
? "   said: " + left(cMsg, 66) + "..."
chk("an unclosed <br> is a parse ERROR", StzFindFirst("mismatched", cMsg) > 0)
chk("...and the loader still answers OK, not a refusal", nStatus = 0)
chk("...so the message is the only witness -- and it names the tag",
    StzFindFirst("br", cMsg) > 0)

# SECOND, and larger: RML carries no HTML semantics. `div` is not a block
# element here -- RmlUi defaults every element to INLINE, and width and
# height correctly do not apply to a non-replaced inline box. In a
# browser the same markup lays out; here it collapses to nothing. The
# emitter must therefore declare `display` on every box it emits.
oInline = new stzPanel(200, 100)
oInline.LoadMarkup('<rml><head><style>body { display: block; width: 100%; }' +
	' #a { width: 50px; height: 20px; background: #2b6cb0; }</style></head>' +
	'<body><div id="a"/></body></rml>')
oInline.Layout()
aInl = oInline.BoxOf("a")
chk("a div under a BLOCK parent ignores width and height", aInl[3] = 0 and aInl[4] = 0)
chk("...and therefore produces no geometry at all", oInline.TriangleCount() = 0)
oInline.Free()

oBlock = new stzPanel(200, 100)
oBlock.LoadMarkup('<rml><head><style>body { display: block; width: 100%; }' +
	' #a { display: block; width: 50px; height: 20px; background: #2b6cb0; }</style></head>' +
	'<body><div id="a"/></body></rml>')
oBlock.Layout()
aBlk = oBlock.BoxOf("a")
chk("the SAME markup with an explicit display: block lays out", aBlk[3] = 50 and aBlk[4] = 20)
chk("...and now it draws", oBlock.TriangleCount() = 2)
oBlock.Free()

? ""
? "-- Scene 7b: handles answer by name after they die --"

oDead = new stzPanel(100, 100)
nDeadId = oDead.Id_()
oDead.Free()
chk("a freed panel answers STALE, not another panel's geometry",
    StzEngineGuiUpdate(nDeadId) = 2)
chk("...and freeing it twice still answers STALE",
    StzEngineGuiContextFree(nDeadId) = 2)

? ""
? "-- Scene 8: KILL CRITERION 3 -- text in a texture, at an angle --"
# G0 deferred this because nothing was rendered there. It is a question
# about THIS house's rasterization and sampling, not about RmlUi: the
# text comes from the plane's own SheenBidi -> HarfBuzz -> stb_truetype
# pipeline, drawn into a canvas, uploaded as a texture and mapped onto a
# quad. RmlUi's font engine is a stub until G2, so a panel has no glyphs
# to contribute yet -- and borrowing the answer from RmlUi would have
# measured the wrong thing anyway.
if NOT oCanvas.CanDrawPixels()
	? "   no GPU on this machine -- criterion 3 needs real pixels."
	? "   Skipped, and it stays OPEN rather than being assumed."
else
	oFont = new stzFont("../gpu/fixtures/amiri_arabic_subset.ttf")
	oT = new stzCanvas(512, 256)
	oT.SetBackground("#101418")
	oT.SetFont(oFont, 44)
	oT.AddTextQ("Softanza", 40, 90).ColorQ("#FFFFFF")
	# Arabic in the same texture, because §2.3 says no LTR case ships
	# without its RTL sibling
	cAr = char(0xD8)+char(0xB3) + char(0xD9)+char(0x88) + char(0xD9)+char(0x81) +
	      char(0xD8)+char(0xAA) + char(0xD8)+char(0xA7) + char(0xD9)+char(0x86) +
	      char(0xD8)+char(0xB2) + char(0xD8)+char(0xA7)
	oT.AddTextQ(cAr, 40, 180).ColorQ("#FFFFFF")
	cPix = oT.ToPixels()
	chk("the text texture rendered", len(cPix) = 512 * 256 * 4)

	hTex = StzEngineGpuTextureNew(512, 256, 2)     # 2 = sampled LINEAR
	chk("a LINEAR-sampled texture was created", hTex > 0)
	chk("...and took the panel's pixels", StzEngineGpuTextureWrite(hTex, cPix) = 0)

	oMat = new stzMaterialMaker()
	oMat.TakesTexture(:skin)
	oMat.ForEachFragment('{ @out = sample(skin, @uv) }')

	# 89 degrees of elevation is face-on to an XZ plane (90 exactly is a
	# degenerate camera -- the view direction would be parallel to the up
	# vector); 12 is a hard graze.
	#
	# THE METRIC, and why it is this one. The obvious measure -- count the
	# lit pixels -- falls with the angle for a reason that has nothing to
	# do with legibility: the quad simply covers less screen. So the
	# measure is the SHAPE of the luminance distribution over the pixels
	# the quad DOES cover: what fraction is ink, and what fraction is
	# stuck in the smear between ink and paper. Blur moves pixels out of
	# the ink bucket and into the middle; shrinking does not.
	#
	# (The paper reads as mid-grey rather than the #101418 it was drawn
	# with, because the material transpiler linearises on entry and
	# encodes on the way out. Measured, not assumed -- the first version
	# of this scene used absolute thresholds and reported the same wrong
	# number at every angle.)
	aAngles = [ 89, 45, 20, 12 ]
	aInk = []
	aSmear = []
	aCov = []
	nA = len(aAngles)
	for i = 1 to nA
		aM = _SharpnessAt(oMat, hTex, aAngles[i])
		aCov + aM[1]
		aInk + aM[2]
		aSmear + aM[3]
		# per-mille, as integers: Ring prints two decimals by default and
		# these fractions are ~0.017, which reads as noise at that width
		? "   elevation " + aAngles[i] + " deg: covered " + aM[1] +
			" px, ink " + floor(aM[2] * 1000) + " per-mille, smear " +
			floor(aM[3] * 1000) + " per-mille"
	next

	chk("face-on, the glyphs ink the texture", aInk[1] > 0.005)
	chk("at a hard graze they still do", aInk[4] > 0.005)
	# THE ANSWER TO CRITERION 3: the distribution barely moves. What the
	# angle costs is SIZE, not sharpness.
	chk("the ink fraction is within 20% of face-on at every angle",
	    aInk[2] > aInk[1] * 0.8 and aInk[2] < aInk[1] * 1.2 and
	    aInk[3] > aInk[1] * 0.8 and aInk[3] < aInk[1] * 1.2 and
	    aInk[4] > aInk[1] * 0.8 and aInk[4] < aInk[1] * 1.2)
	chk("...and so is the smear fraction -- no blurring with angle",
	    aSmear[4] < aSmear[1] * 1.5)
	# The negative sibling, and it is what stops the two assertions above
	# being a tautology: the angles ARE different renders. If the camera
	# had not moved, coverage would not have collapsed.
	chk("coverage falls steeply with the angle (the quad really tilted)",
	    aCov[4] < aCov[1] / 3)
	chk("...monotonically", aCov[1] > aCov[2] and aCov[2] > aCov[3] and aCov[3] > aCov[4])

	StzEngineGpuTextureFree(hTex)
	oFont.Free()
ok

oP.Free()

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------

# Draw the text texture on a quad at a given elevation and answer
# [ coveredPixels, inkFraction, smearFraction ].
#
# Fractions are OF THE COVERED PIXELS, which is what makes them
# comparable across angles: the quad shrinks as it tilts, so any absolute
# count falls for a reason that says nothing about legibility.
func _SharpnessAt oMat, hTex, nElevDeg
	_nRad_ = nElevDeg * 3.141592653589793 / 180
	_nD_ = 2.6
	_oSc_ = new stzScene(480, 480)
	_oSc_.SetBackgroundQ("#000000")
	_oSc_.SetCamera(0, _nD_ * sin(_nRad_), _nD_ * cos(_nRad_), 0, 0, 0)
	_oSc_.SetLight(0, -1, 0, "#FFFFFF", "#FFFFFF")
	_oSc_.AddMesh(new stzMesh([ :Plane, 2 ]), 0, 0, 0)
	_oSc_.SetMaterial(oMat, [ :skin = hTex ])
	_cP_ = _oSc_.ToPixels()
	if len(_cP_) = 0
		return [ 0, 0, 0 ]
	ok
	_nCovered_ = 0
	_nInk_ = 0
	_nSmear_ = 0
	_nL_ = len(_cP_)
	for _i_ = 1 to _nL_ - 3 step 4
		_r_ = ascii(substr(_cP_, _i_, 1))
		_g_ = ascii(substr(_cP_, _i_ + 1, 1))
		_b_ = ascii(substr(_cP_, _i_ + 2, 1))
		_lum_ = (_r_ * 3 + _g_ * 6 + _b_) / 10
		# the scene background is pure black, so anything the quad covers
		# reads above it -- that is the coverage test
		if _lum_ < 8
			loop
		ok
		_nCovered_++
		# measured buckets: paper lands around 64..95, ink above 224.
		# Anything in between is a texel the sampler could not resolve
		# into one or the other.
		if _lum_ > 200
			_nInk_++
		but _lum_ > 110
			_nSmear_++
		ok
	next
	if _nCovered_ = 0
		return [ 0, 0, 0 ]
	ok
	return [ _nCovered_, _nInk_ / _nCovered_, _nSmear_ / _nCovered_ ]


func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
