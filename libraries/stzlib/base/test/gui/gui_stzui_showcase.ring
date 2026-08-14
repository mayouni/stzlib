# A .stzui FILE, ON SCREEN -- §4b of SOFTANZA_GUI_PLAN.md.
#
#     showcase.stzui  ->  stzUiDocument (parse + court)  ->  RML  ->
#     stzPanel (layout)  ->  stzCanvas  ->  a window, or a PNG
#
# The point over gui_showcase_window.ring: THERE the markup was emitted by
# Ring code; HERE the interface is a text file a person wrote, judged by
# the court before a single triangle moves. Change the file, run again,
# see the change -- no Ring edited.
#
# The labels still come from TextsToPaint + BoxOf, painted by the
# graphics plane's own text pipeline, because G1's font engine is a stub.
# That bridge disappears when G2 lands.
#
#     ring gui_stzui_showcase.ring          window if possible, else PNG
#     ring gui_stzui_showcase.ring shot     always the PNG + SVG

load "../../stzBase.ring"

if NOT StzGuiAvailable()
	? "No layout engine here (stz_gui.dll absent) -- nothing to show."
	return
ok

func main
	bShot = 0
	if len(sysargv) >= 3 and lower("" + sysargv[3]) = "shot"
		bShot = 1
	ok

	oU = new stzUiDocument("showcase.stzui")
	if NOT oU.IsClean()
		? "showcase.stzui did not pass the court:"
		? oU.Report()
		return
	ok

	oFont = PickFont()
	if oFont = NULL
		? "No font found -- the labels need one."
		return
	ok

	oP = oU.ToPanel()
	nW = oP.Width()
	nH = oP.Height()
	oC = new stzCanvas(nW, nH)

	if bShot or NOT (StzWindowingAvailable() and oC.CanDrawPixels())
		Paint(oU, oP, oC, oFont)
		oC.ToPNG("gui_stzui_showcase.png")
		write("gui_stzui_showcase.svg", oC.ToSVG())
		? "Wrote gui_stzui_showcase.png and .svg from showcase.stzui (" +
			oP.TriangleCount() + " triangles, " + len(oU.Declarations()) +
			" declarations)."
		oP.Free()
		return
	ok

	oWin = new stzWindow(nW, nH, "Softanza -- showcase.stzui, live")
	if NOT oWin.CanDraw()
		? "The window opened but cannot draw."
		return
	ok
	? "  R  re-read showcase.stzui from disk     ESC  quit"
	? "  (edit the file in another window and press R -- the court runs first)"

	nLastW = 0
	nLastH = 0
	while oWin.IsOpen()
		oWin.Poll()
		if oWin.KeyPressed(:Escape)
			oWin.Close()
			exit
		ok

		# THE point of a text format: the interface reloads from disk,
		# through the court, without touching a line of Ring.
		if oWin.KeyPressed("R")
			oNew = new stzUiDocument("showcase.stzui")
			if oNew.IsClean()
				oP.Free()
				oU = oNew
				oP = oU.ToPanel()
				oP.Resize(oWin.Width(), oWin.Height())
				? "  reloaded: " + len(oU.Declarations()) + " declarations"
			else
				? "  refused -- the court says:"
				? oNew.Report()
			ok
		ok

		if oWin.Width() != nLastW or oWin.Height() != nLastH
			nLastW = oWin.Width()
			nLastH = oWin.Height()
			oP.Resize(nLastW, nLastH)
		ok

		Paint(oU, oP, oC, oFont)
		oWin.Draw(oC)
	end

	? "  " + oWin.FrameCount() + " frames drawn."
	oWin.Free()
	oP.Free()
	oFont.Free()

func Paint oU, oP, oC, oFont
	oC.Clear()
	oC.SetBackground("#0f1419")
	oP.DrawInto(oC)
	# every TEXT declaration, painted inside the box RmlUi gave it
	_aT_ = oU.TextsToPaint()
	_n_ = len(_aT_)
	for _i_ = 1 to _n_
		_a_ = oP.BoxOf(_aT_[_i_][1])
		if len(_a_) != 4 or _a_[3] < 10
			loop
		ok
		_nSz_ = _aT_[_i_][3]
		oC.AddTextQ(_aT_[_i_][2], _a_[1] + 4, _a_[2] + _nSz_ + 4).
			SetFontQ(oFont, _nSz_).ColorQ(_aT_[_i_][4])
	next

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
