# THE GUI PLANE, LIVE -- G1 of base/gui/SOFTANZA_GUI_PLAN.md.
#
#     RmlUi (layout)  ->  stzPanel (triangles)  ->  stzCanvas  ->  stzWindow
#
# Nothing here is a demo shortcut. The markup is emitted by the code
# below, RmlUi lays it out for real, the triangles come back across the
# C ABI, and the window draws them through the same canvas every other
# graphics face uses. Resize the window and the whole thing re-lays out
# at the new size, because it is layout and not a picture.
#
# THE LABELS ARE THE POINT, and they are drawn by the GRAPHICS plane, not
# by RmlUi. G1's font engine is a monospace stub, so a panel has chrome
# and no glyphs until G2 fuses them. Rather than hide that, this asks the
# panel WHERE each box landed (BoxOf) and draws the text there with the
# house's own SheenBidi -> HarfBuzz -> stb_truetype pipeline. Every label
# sitting exactly inside its box is the proof that the layout is
# queryable -- which is what G3's hit-testing and the court's paint-time
# audit will both need.
#
#     1 2 3   sidebar left / sidebar right / stacked
#     T       theme
#     S       save a PNG of exactly what you are looking at
#     ESC     quit

load "../../stzBase.ring"

if NOT StzGuiAvailable()
	? "No layout engine here (stz_gui.dll absent) -- nothing to show."
	return
ok

decimals(2)

# ---------------------------------------------------------------- state
nLayout = 1          # 1 = sidebar left, 2 = sidebar right, 3 = stacked
nTheme = 1
bDirty = 1

aThemes = [
	[ "#0f1419", "#1a2028", "#2b6cb0", "#243040", "#e8eef5", "#7c9cbf" ],
	[ "#f5f2ec", "#e6e0d6", "#a0522d", "#d9d2c5", "#2a2420", "#7a6a58" ]
]

aCards = [ "Graphics", "Sound", "GPU", "Locale", "Graph", "Perf" ]

# Ring calls `main` itself once the file is loaded, so there is no call
# here -- adding one runs the whole showcase twice, which is exactly what
# the first version of this file did.
#
# `ring gui_showcase_window.ring shot` renders one frame to a PNG and an
# SVG and exits, for a machine with no window and for a session that
# wants the picture rather than the pane.

# ------------------------------------------------------- markup emitter
#
# The markup is EMITTED, never authored (§4 of the plan). This function
# is a crude stand-in for the real emitter G5 will build, and it already
# has to obey the four divergences G1 found the hard way: declare
# `display` on every box (RML defaults to inline), give the root an
# explicit width, declare a font-family or no text is measured at all,
# and close every tag because RML is XML.

func BuildMarkup nLay, aT, nW, nH
	_cRow_ = "row"
	if nLay = 3
		_cRow_ = "column"
	ok
	_cCards_ = ""
	_nC_ = len(aCards)
	for _i_ = 1 to _nC_
		_cCards_ += '<div class="card" id="card' + _i_ + '"/>'
	next

	_cSide_ = '<div id="side"/>'
	_cMain_ = '<div id="main">' + _cCards_ + '</div>'
	_cBody_ = _cSide_ + _cMain_
	if nLay = 2
		_cBody_ = _cMain_ + _cSide_
	ok

	return '<rml><head><style>' +
		'body { display: flex; flex-direction: column; width: 100%; height: 100%;' +
		'       font-family: stub; font-size: 14px; background: ' + aT[1] + '; }' +
		'div { display: block; }' +
		# flex-shrink: 0 is NOT decoration. A declared size on a flex item
		# is a BASIS, not a floor -- G0 recorded that for width and it is
		# just as true for height in a column. Without it this bar and the
		# footer below are squeezed to ZERO height to feed #work's
		# flex: 1 1 auto, and their children overflow into the panel.
		'#bar { display: flex; flex-direction: row; width: 100%; height: 52px;' +
		'       flex-shrink: 0; background: ' + aT[3] + '; }' +
		'#bar .tab { display: block; flex: 1 1 auto; height: 52px; }' +
		'#work { display: flex; flex-direction: ' + _cRow_ + '; width: 100%;' +
		'        flex: 1 1 auto; background: ' + aT[1] + '; }' +
		'#side { display: block; width: 210px; height: 100%; flex-shrink: 0;' +
		'        background: ' + aT[2] + '; }' +
		# align-content: flex-start, or a wrapped row's LINES are spread
		# down the whole container and the second row of cards lands at
		# the bottom of the screen.
		'#main { display: flex; flex-direction: row; flex-wrap: wrap;' +
		'        align-content: flex-start; flex: 1 1 auto; padding: 18px; }' +
		'.card { display: block; width: 30%; height: 92px; margin: 9px;' +
		'        background: ' + aT[4] + '; }' +
		'#foot { display: block; width: 100%; height: 30px; flex-shrink: 0;' +
		'        background: ' + aT[2] + '; }' +
		'</style></head><body>' +
		'<div id="bar"><div class="tab" id="t1"/><div class="tab" id="t2"/>' +
		'<div class="tab" id="t3"/><div class="tab" id="t4"/></div>' +
		'<div id="work">' + _cBody_ + '</div>' +
		'<div id="foot"/>' +
		'</body></rml>'

# --------------------------------------------------------------- render
#
# Chrome from the panel, labels from the graphics plane, both into ONE
# canvas -- so the window, a PNG and an SVG are the same picture.

func Paint oPanel, oCanvas, oFont, aT, nW, nH, cStatus
	oCanvas.Clear()
	oCanvas.SetBackground(aT[1])
	oPanel.DrawInto(oCanvas)

	# every label is placed from the box RmlUi computed for it
	Label(oCanvas, oFont, oPanel, "t1", "Softanza", 20, aT[5], 20, 33)
	Label(oCanvas, oFont, oPanel, "t2", "Graphics", 16, aT[5], 14, 32)
	Label(oCanvas, oFont, oPanel, "t3", "Sound",    16, aT[5], 14, 32)
	Label(oCanvas, oFont, oPanel, "t4", "GUI",      16, aT[5], 14, 32)

	Label(oCanvas, oFont, oPanel, "side", "PLANES", 13, aT[6], 22, 36)
	_aS_ = oPanel.BoxOf("side")
	if len(_aS_) = 4 and _aS_[3] > 60
		_aN_ = [ "graphics", "sound", "gpu", "locale", "graph", "perf", "gui" ]
		_nN_ = len(_aN_)
		for _i_ = 1 to _nN_
			_nY_ = _aS_[2] + 62 + (_i_ - 1) * 30
			if _nY_ < _aS_[2] + _aS_[4] - 8
				# AddText FIRST, then style it. stzCanvas remembers the
				# pending shape so Fill/Color/SetFont can still reach it --
				# calling SetFont first retargets the PREVIOUS label and
				# every size comes out one behind.
				oCanvas.AddTextQ(_aN_[_i_], _aS_[1] + 22, _nY_).
					SetFontQ(oFont, 15).ColorQ(aT[5])
			ok
		next
	ok

	_nC_ = len(aCards)
	for _i_ = 1 to _nC_
		Label(oCanvas, oFont, oPanel, "card" + _i_, aCards[_i_], 16, aT[5], 14, 30)
	next

	Label(oCanvas, oFont, oPanel, "foot", cStatus, 13, aT[6], 14, 20)

# Draw one label INSIDE the box the panel says an element occupies. If
# the layout were not queryable, or the boxes were stale, the text would
# land somewhere else -- which is exactly what makes this a proof and not
# a decoration.
func Label oCanvas, oFont, oPanel, cId, cText, nSize, cCol, nDx, nDy
	_a_ = oPanel.BoxOf(cId)
	if len(_a_) != 4 or _a_[3] < 24 or _a_[4] < 14
		return
	ok
	if oFont.WidthOf(cText, nSize) > _a_[3] - nDx
		return          # it would overflow its own box: say nothing
	ok
	oCanvas.AddTextQ(cText, _a_[1] + nDx, _a_[2] + nDy).
		SetFontQ(oFont, nSize).ColorQ(cCol)

func PickFont
	_a_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
	        "../gpu/fixtures/amiri_arabic_subset.ttf" ]
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if fexists(_a_[_i_])
			return new stzFont(_a_[_i_])
		ok
	next
	return NULL

# ----------------------------------------------------------------- main

func main
	bShot = 0
	cOut = "gui_showcase"
	if len(sysargv) >= 3 and lower("" + sysargv[3]) = "shot"
		bShot = 1
		# shot [layout] [theme] [name] -- so the variants can be captured
		# without editing the file
		if len(sysargv) >= 4 nLayout = 0 + sysargv[4] ok
		if len(sysargv) >= 5 nTheme  = 0 + sysargv[5] ok
		if len(sysargv) >= 6 cOut    = "" + sysargv[6] ok
	ok

	oFont = PickFont()
	if oFont = NULL
		? "No font found -- the labels need one."
		return
	ok

	nW = 1000
	nH = 640
	oPanel = new stzPanel(nW, nH)
	oCanvas = new stzCanvas(nW, nH)

	if bShot or NOT (StzWindowingAvailable() and oCanvas.CanDrawPixels())
		# Asked for, or no window on this box: produce the picture anyway,
		# so the phase is inspectable on a headless runner.
		oPanel.LoadMarkup(BuildMarkup(nLayout, aThemes[nTheme], nW, nH))
		oPanel.Layout()
		Paint(oPanel, oCanvas, oFont, aThemes[nTheme], nW, nH,
			"layout " + nLayout + " / theme " + nTheme + " / " +
			oPanel.TriangleCount() + " triangles")
		oCanvas.ToPNG(cOut + ".png")
		write(cOut + ".svg", oCanvas.ToSVG())
		? "Wrote " + cOut + ".png and .svg (" +
			oPanel.TriangleCount() + " triangles)."
		return
	ok

	oWin = new stzWindow(nW, nH, "Softanza -- the GUI plane, live")
	if NOT oWin.CanDraw()
		? "The window opened but cannot draw."
		return
	ok

	? "  1 2 3  layout     T  theme     S  save PNG     ESC  quit"

	nLastW = 0
	nLastH = 0
	while oWin.IsOpen()
		oWin.Poll()
		if oWin.KeyPressed(:Escape)
			oWin.Close()
			exit
		ok

		if oWin.KeyPressed("1") nLayout = 1  bDirty = 1 ok
		if oWin.KeyPressed("2") nLayout = 2  bDirty = 1 ok
		if oWin.KeyPressed("3") nLayout = 3  bDirty = 1 ok
		if oWin.KeyPressed("T")
			nTheme = 3 - nTheme
			bDirty = 1
		ok

		if oWin.Width() != nLastW or oWin.Height() != nLastH
			nLastW = oWin.Width()
			nLastH = oWin.Height()
			oPanel.Resize(nLastW, nLastH)
			bDirty = 1
		ok

		if bDirty
			# The markup is re-EMITTED, not patched: the layout comes
			# from the declaration every time, which is the whole point
			# of §4 and the reason a theme change is one line here.
			oPanel.LoadMarkup(BuildMarkup(nLayout, aThemes[nTheme], nLastW, nLastH))
			oPanel.Layout()
			bDirty = 0
		ok

		cStat = "" + oPanel.TriangleCount() + " triangles   " +
			oWin.Width() + "x" + oWin.Height() + "   " +
			floor(oWin.FPS()) + " fps   layout " + nLayout
		Paint(oPanel, oCanvas, oFont, aThemes[nTheme], nLastW, nLastH, cStat)

		if oWin.KeyPressed("S")
			oCanvas.ToPNG("gui_showcase.png")
			? "  saved gui_showcase.png (" + oWin.Width() + "x" + oWin.Height() + ")"
		ok

		oWin.Draw(oCanvas)
	end

	? "  " + oWin.FrameCount() + " frames drawn."
	oWin.Free()
	oPanel.Free()
	oFont.Free()
