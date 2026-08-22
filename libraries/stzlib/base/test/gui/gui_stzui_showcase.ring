# A .panel FILE, ON SCREEN -- §4b of SOFTANZA_GUI_PLAN.md.
#
#     showcase.panel  ->  stzUiDocument (parse + court)  ->  RML  ->
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

	oU = new stzUiDocument("showcase.panel")
	if NOT oU.IsClean()
		? "showcase.panel did not pass the court:"
		? oU.Report()
		return
	ok

	# G2: bind the face BEFORE the layout, so the document is measured
	# with the glyphs it will be painted with.
	oU.UseFont(FontPath())
	oP = oU.ToPanel()
	nW = oP.Width()
	nH = oP.Height()
	oC = new stzCanvas(nW, nH)

	if bShot or NOT (StzWindowingAvailable() and oC.CanDrawPixels())
		Paint(oU, oP, oC, NULL)
		oC.ToPNG("gui_stzui_showcase.png")
		write("gui_stzui_showcase.svg", oC.ToSVG())
		? "Wrote gui_stzui_showcase.png and .svg from showcase.panel (" +
			oP.TriangleCount() + " triangles, " + len(oU.Declarations()) +
			" declarations)."
		oP.Free()
		return
	ok

	oWin = new stzWindow(nW, nH, "Softanza -- showcase.panel, live")
	if NOT oWin.CanDraw()
		? "The window opened but cannot draw."
		return
	ok
	? "  R  re-read showcase.panel from disk     ESC  quit"
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
			oNew = new stzUiDocument("showcase.panel")
			if oNew.IsClean()
				# THE FONT COMES WITH THE DOCUMENT, and this line was
				# missing. A reloaded document is a NEW document: it
				# knows nothing of the UseFont the first one was given,
				# and RmlUi lays out no text at all for a family it
				# cannot resolve. Pressing R left the boxes in place and
				# took every label away -- found by the author looking at
				# the window, not by any assertion here.
				#
				# ToPanel() now REFUSES this rather than drawing a
				# wordless screen, so the same slip is an error with a
				# sentence on it instead of a silence.
				oNew.UseFont(FontPath())
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

		Paint(oU, oP, oC, NULL)
		oWin.Draw(oC)
	end

	? "  " + oWin.FrameCount() + " frames drawn."
	oWin.Free()
	oP.Free()

# G2 made this one line. The panel now carries its own text: RmlUi asked
# our font engine for every string, the engine recorded a command instead
# of rasterizing it, and DrawInto replays those commands through the same
# shaper that measured them. The G1 bridge -- walk TextsToPaint, look up
# BoxOf, guess a baseline -- is gone, and with it the chance of painting
# a label somewhere the layout did not put it.
func Paint oU, oP, oC, oFont
	oC.Clear()
	oC.SetBackground("#0f1419")
	oP.DrawInto(oC)

func FontPath
	_a_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
	        "../gpu/fixtures/amiri_arabic_subset.ttf" ]
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if fexists(_a_[_i_])
			return _a_[_i_]
		ok
	next
	return ""
