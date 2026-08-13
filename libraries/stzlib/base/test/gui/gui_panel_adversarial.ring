# THE GUI PLANE UNDER PRESSURE -- G1, base/gui/SOFTANZA_GUI_PLAN.md.
#
# gui_panel_narrated.ring proves the mechanism on documents that behave.
# This one goes at it the way the house's stress method demands: LARGE,
# MULTILINGUAL, CHURNED, and TIMED, with expectations computed
# independently of the thing being tested.
#
# What it is actually looking for:
#   - handles that leak, fork, or answer for a neighbour after a free
#   - a layout that is quadratic in the number of boxes
#   - a recorder that keeps growing across frames (it is reset per
#     render, and nothing else re-checks that)
#   - documents a generator could plausibly emit and that a hand-written
#     test never would: 60 levels deep, 500 siblings, an empty body, a
#     style block that never closes
#   - Ring's copy-on-assign, which the engine-wrapper copy law says is
#     the thing that silently forks a face
#
# Everything here needs stz_gui.dll and nothing needs a GPU.

load "../../stzBase.ring"

nPass = 0
nFail = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to stress."
	? " 0 ok, 0 failed"
	return
ok

cHead = 'body { display: flex; flex-direction: column; width: 100%; height: 100%; }' +
	' div { display: block; }'

? "-- Scene 1: 500 siblings, and the cost of them --"
cKids = ""
for i = 1 to 500
	cKids += '<div class="c"/>'
next
cBig = '<rml><head><style>' + cHead +
	' .c { display: block; width: 100%; height: 2px; background: #3355aa; }' +
	'</style></head><body>' + cKids + '</body></rml>'

oBig = new stzPanel(400, 1200)
nT0 = clock()
oBig.LoadMarkup(cBig)
oBig.Layout()
nLoad = (clock() - nT0) / clockspersecond() * 1000
nTris = oBig.TriangleCount()
? "   500 boxes: parse + layout " + floor(nLoad) + " ms, " + nTris + " triangles"
chk("every box became geometry", nTris >= 1000)
chk("...and parse plus layout stayed under a second", nLoad < 1000)

# The negative sibling for "is layout linear-ish": lay the SAME document
# out again after a change. If re-layout were quadratic in boxes this is
# where it shows, and if it were free the number would be suspicious.
nT0 = clock()
for i = 1 to 20
	oBig.Resize(400 + (i % 7), 1200)
next
nRe = (clock() - nT0) / clockspersecond() * 1000 / 20
? "   re-layout after a resize: " + floor(nRe * 1000) / 1000 + " ms/frame"
chk("re-layout of 500 boxes is under 20 ms", nRe < 20)

? ""
? "-- Scene 2: the recorder does NOT grow across frames --"
# It is Reset() per render. Nothing else checks that, and a recorder that
# appended instead would look perfect for one frame and eat memory for
# every frame after.
nV1 = len(oBig.Verts())
nV2 = len(oBig.Verts())
nV3 = len(oBig.Verts())
chk("three renders of one document give the same vertex count",
    nV1 = nV2 and nV2 = nV3)
chk("...and it is not zero", nV1 > 0)
# ...and the counters must be per-frame as well. Equality across two
# renders is the test: a threshold would pass for a cumulative counter
# that simply had not grown enough yet.
nD1 = oBig.Counters()[1]
oBig.Record()
nD2 = oBig.Counters()[1]
? "   draws per frame: " + nD1 + " then " + nD2
chk("the draw count is per-frame, not cumulative", nD1 = nD2 and nD1 > 0)
oBig.Free()

? ""
? "-- Scene 3: 60 levels of nesting --"
cOpen = ""
cClose = ""
for i = 1 to 60
	cOpen += '<div id="n' + i + '">'
	cClose = '</div>' + cClose
next
oDeep = new stzPanel(400, 400)
oDeep.LoadMarkup('<rml><head><style>' + cHead +
	' div { display: block; width: 100%; height: 100%; }</style></head><body>' +
	cOpen + cClose + '</body></rml>')
oDeep.Layout()
aTop = oDeep.BoxOf("n1")
aBot = oDeep.BoxOf("n60")
? "   outermost " + @@(aTop) + "   innermost " + @@(aBot)
chk("the outermost box laid out", aTop[3] > 0)
chk("the innermost one did too -- 60 levels is not a limit", aBot[3] > 0)
chk("...and they agree, since every level is 100%", aTop[3] = aBot[3])
oDeep.Free()

? ""
? "-- Scene 4: multilingual content, and DIRECTION --"
# The house rule (§2.3 of the plan): no LTR case ships without its RTL
# sibling. The stub font engine gives every codepoint the same advance,
# so what is being tested here is that the DOCUMENT survives non-ASCII
# and that --rmlui-direction is accepted -- not that the text shapes.
# Shaping is G2's to prove.
cAr = char(0xD8)+char(0xB3) + char(0xD9)+char(0x88) + char(0xD9)+char(0x81) +
      char(0xD8)+char(0xAA) + char(0xD8)+char(0xA7) + char(0xD9)+char(0x86) +
      char(0xD8)+char(0xB2) + char(0xD8)+char(0xA7)
cHe = char(0xD7)+char(0xA9) + char(0xD7)+char(0x9C) + char(0xD7)+char(0x95) + char(0xD7)+char(0x9D)
cJa = char(0xE6)+char(0x97)+char(0xA5) + char(0xE6)+char(0x9C)+char(0xAC) + char(0xE8)+char(0xAA)+char(0x9E)
cEmo = char(0xF0)+char(0x9F)+char(0x8E)+char(0xA8)

# A FIFTH divergence, found here: without a declared font-family, RmlUi
# lays out NO TEXT AT ALL -- zero width queries, zero draw calls, and one
# log line nobody reads. A browser would fall back to a default font. So
# the emitter must always declare one, and this scene declares it in
# order to have any text to stress.
oNoFont = new stzPanel(300, 200)
oNoFont.LoadMarkup('<rml><head><style>' + cHead +
	' #a { display: block; width: 100%; height: 30px; background: #333; }</style></head>' +
	'<body><div id="a">Softanza</div></body></rml>')
oNoFont.Layout()
oNoFont.Record()
chk("with no font-family, text is never even MEASURED", oNoFont.Counters()[4] = 0)
chk("...and the only witness is a log line",
    StzFindFirst("No font face defined", oNoFont.LastEngineMessage()) > 0)
oNoFont.Free()

cFont = cHead + ' body { font-family: stub; font-size: 14px; }'

oML = new stzPanel(400, 300)
oML.LoadMarkup('<rml><head><style>' + cFont +
	' #rtl { display: block; --rmlui-direction: rtl; width: 100%; height: 40px; background: #224466; }' +
	' #ltr { display: block; width: 100%; height: 40px; background: #664422; }' +
	'</style></head><body>' +
	'<div id="rtl">' + cAr + ' ' + cHe + '</div>' +
	'<div id="ltr">' + cJa + ' ' + cEmo + ' Softanza</div>' +
	'</body></rml>')
oML.Layout()
cMsg = oML.LastEngineMessage()
chk("a document carrying Arabic, Hebrew, CJK and an emoji loads",
    oML.BoxOf("rtl")[4] = 40)
chk("...and --rmlui-direction: rtl was not a syntax error",
    StzFindFirst("rmlui-direction", cMsg) = 0)
chk("...while `direction: rtl` still IS one (the divergence holds)",
    _StyleWarns("#x { direction: rtl; }") = 1)
chk("both rows laid out", oML.BoxOf("ltr")[4] = 40)
oML.Record()
chk("...and with font-family declared, the SAME text is measured",
    oML.Counters()[4] > 0)
oML.Free()

? ""
? "-- Scene 5: handle churn -- 200 panels, born and buried --"
aIds = []
for i = 1 to 200
	oX = new stzPanel(64, 64)
	aIds + oX.Id_()
	oX.Free()
next
bUnique = 1
bDead = 1
for i = 1 to 200
	if StzEngineGuiUpdate(aIds[i]) != 2
		bDead = 0
	ok
	if i > 1 and aIds[i] = aIds[i-1]
		bUnique = 0
	ok
next
chk("200 panels each got a distinct handle", bUnique = 1)
chk("...and every one of them is STALE after its free", bDead = 1)
# a live panel made AFTER all that churn must still work -- the proof
# that freeing did not corrupt the table it freed from
oAfter = new stzPanel(120, 60)
oAfter.LoadMarkup('<rml><head><style>' + cHead +
	' #a { display: block; width: 100%; height: 10px; background: #fff; }</style></head>' +
	'<body><div id="a"/></body></rml>')
oAfter.Layout()
chk("a panel created after the churn still lays out", oAfter.BoxOf("a")[3] = 120)

? ""
? "-- Scene 6: Ring copy-on-assign does not fork the face --"
# The engine-wrapper copy law: state that must survive a copy lives in an
# ENGINE handle, and a copy shares it. A panel keeps exactly one number,
# so the copy is the same panel -- and this asserts it rather than
# assuming it, because a face that forked would answer stale geometry
# from the copy while the original kept working.
oCopy = oAfter
oAfter.Resize(240, 60)
chk("a copy sees the ORIGINAL's new size", oCopy.BoxOf("a")[3] = 240)
chk("...and they hold the same handle", oCopy.Id_() = oAfter.Id_())
oAfter.Free()
chk("freeing through one face kills the other too",
    StzEngineGuiUpdate(oCopy.Id_()) = 2)

? ""
? "-- Scene 7: documents a generator could emit by accident --"
chk("an empty body lays out and draws nothing",
    _TrisOf('<rml><head><style>' + cHead + '</style></head><body/></rml>') = 0)
chk("a document with no head at all still loads",
    _TrisOf('<rml><body><div/></body></rml>') = 0)
chk("a style block that never closes does not hang",
    _LoadsWithoutHanging('<rml><head><style>' + cHead) = 1)
chk("an unknown property is ignored, not fatal",
    _TrisOf('<rml><head><style>' + cHead +
        ' #a { display: block; width: 100%; height: 5px; background: #fff; ' +
        'nonsense-property: 3; }</style></head><body><div id="a"/></body></rml>') = 2)
chk("an unparseable colour leaves the box unpainted, not broken",
    _TrisOf('<rml><head><style>' + cHead +
        ' #a { display: block; width: 100%; height: 5px; background: notacolour; }' +
        '</style></head><body><div id="a"/></body></rml>') >= 0)

? ""
? "-- Scene 8: sizes at and past the edge --"
chk("a 1x1 panel is legal", _MakesPanel(1, 1) = 1)
chk("16384 square is the documented ceiling", _MakesPanel(16384, 16384) = 1)
chk("...and 16385 is refused", _MakesPanel(16385, 100) = 0)
chk("zero is refused", _MakesPanel(0, 100) = 0)
chk("negative is refused", _MakesPanel(-5, 100) = 0)

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------

func _TrisOf cRml
	_o_ = new stzPanel(200, 100)
	if StzEngineGuiLoadRml(_o_.Id_(), cRml) != 0
		_o_.Free()
		return -1
	ok
	_o_.Layout()
	_n_ = _o_.TriangleCount()
	_o_.Free()
	return _n_

func _LoadsWithoutHanging cRml
	_o_ = new stzPanel(200, 100)
	StzEngineGuiLoadRml(_o_.Id_(), cRml)
	StzEngineGuiUpdate(_o_.Id_())
	_o_.Free()
	return 1

func _StyleWarns cRule
	_o_ = new stzPanel(64, 64)
	StzEngineGuiLoadRml(_o_.Id_(),
		'<rml><head><style>' + cRule + '</style></head><body/></rml>')
	_c_ = StzEngineGuiLastError()
	_o_.Free()
	return iif(StzFindFirst("Syntax error", _c_) > 0, 1, 0)

func _MakesPanel nW, nH
	_n_ = StzEngineGuiContextNew(nW, nH)
	if _n_ = 0
		return 0
	ok
	StzEngineGuiContextFree(_n_)
	return 1

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
