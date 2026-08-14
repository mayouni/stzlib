# G3 LIVE -- a form you can actually operate.
#
#     form.stzui  ->  stzUiDocument  ->  stzPanel  ->  stzCanvas  ->  window
#     mouse and keyboard  ->  panel pixels  ->  routed events  ->  drained
#
# The whole of G3 in one loop: the window reports raw input, FromWindow
# converts it once at the boundary (the coordinate-space frame, dissolved
# rather than surfaced), the panel routes it, and the frame drains the
# events it produced. Nothing polls; nothing guesses which element was
# hit.
#
#     mouse       hover, press, click
#     TAB         next stop        SHIFT+TAB   previous
#     ARROWS      move within the action row
#     ENTER       activate the focused stop (synthetic, and it says so)
#     ESC         quit
#
# The status line shows what the last event was, who it targeted, and
# WHICH SOURCE it came from -- which is the §7 frame made visible.

load "../../stzBase.ring"

if NOT StzGuiAvailable()
	? "No layout engine here (stz_gui.dll absent) -- nothing to operate."
	return
ok

decimals(2)

cLastEvent = "ready"
nClicks = 0
$oFormFont = NULL

func main
	bShot = 0
	if len(sysargv) >= 3 and lower("" + sysargv[3]) = "shot"
		bShot = 1
	ok

	oU = new stzUiDocument("form.stzui")
	if NOT oU.IsClean()
		? "form.stzui did not pass the court:"
		? oU.Report()
		return
	ok
	oU.UseFont(FontPath())
	oP = oU.ToPanel()
	oC = new stzCanvas(oP.Width(), oP.Height())

	if bShot or NOT (StzWindowingAvailable() and oC.CanDrawPixels())
		# the ring BEFORE touching focus: it is a cycle entered wherever
		# focus sits, so asking first is what gives document order
		cRing = ListToText(oP.TabRing())
		oP.FocusOn("confirm")
		Paint(oP, oC, "focused: confirm   |   tab ring: " + cRing)
		oC.ToPNG("gui_form.png")
		? "Wrote gui_form.png (ring: " + cRing + ")"
		oP.Free()
		return
	ok

	oWin = new stzWindow(oP.Width(), oP.Height(), "Softanza -- form.stzui, live")
	if NOT oWin.CanDraw()
		? "The window opened but cannot draw."
		return
	ok
	? "  TAB / SHIFT+TAB  stops     ARROWS  within the row"
	? "  ENTER activates     mouse works     ESC quits"

	nPrevX = -1
	nPrevY = -1
	while oWin.IsOpen()
		oWin.Poll()
		if oWin.KeyPressed(:Escape)
			oWin.Close()
			exit
		ok

		# THE BOUNDARY, and the only place a coordinate space changes.
		aPt = oP.FromWindow(oWin, oWin.MouseX(), oWin.MouseY())
		if aPt[1] != nPrevX or aPt[2] != nPrevY
			oP.PointerMovedTo(aPt[1], aPt[2])
			nPrevX = aPt[1]
			nPrevY = aPt[2]
		ok
		if oWin.MouseClicked(1)
			oP.ClickAt(aPt[1], aPt[2])
		ok

		if oWin.KeyPressed("TAB")
			if oWin.KeyDown("LEFTSHIFT")
				oP.FocusPrevious()
			else
				oP.FocusNext()
			ok
		ok
		if oWin.KeyPressed("LEFT")   oP.FocusLeft()  ok
		if oWin.KeyPressed("RIGHT")  oP.FocusRight() ok
		if oWin.KeyPressed("UP")     oP.FocusUp()    ok
		if oWin.KeyPressed("DOWN")   oP.FocusDown()  ok

		# ENTER activates the focused stop. It is stamped SYNTHETIC on
		# purpose: a dispatched activation must be tellable from a real
		# pointer one, or Rule 80's guard could not fail.
		if oWin.KeyPressed("ENTER")
			cF = oP.Focused()
			if cF != ""
				StzEngineGuiSetInputSource(3)
				aB = oP.BoxOf(cF)
				if len(aB) = 4
					oP.ClickAt(aB[1] + aB[3] / 2, aB[2] + aB[4] / 2)
				ok
				StzEngineGuiSetInputSource(0)
			ok
		ok

		# DRAIN. Nothing is dispatched into Ring; the frame takes what
		# arrived and decides what it means.
		aE = oP.Events()
		nN = len(aE)
		for i = 1 to nN
			if aE[i][1] = 1        # a click
				nClicks++
				cLastEvent = "click on '" + aE[i][8] + "' via " + SourceName(aE[i][2])
			but aE[i][1] = 6       # focus
				cLastEvent = "focus '" + aE[i][8] + "'"
			ok
		next
		oP.ClearEvents()

		Paint(oP, oC, cLastEvent + "   |   clicks " + nClicks +
			"   |   focus '" + oP.Focused() + "'")
		oWin.Draw(oC)
	end

	? "  " + oWin.FrameCount() + " frames, " + nClicks + " clicks."
	oWin.Free()
	oP.Free()

# The panel paints itself; the status line is drawn over it, because it
# reports on the panel rather than being part of it.
func Paint oPanel, oCanvas, cStatus
	oCanvas.Clear()
	oCanvas.SetBackground("#12161c")
	oPanel.DrawInto(oCanvas)
	# a ring around whatever holds focus, so a keyboard user can SEE
	# where they are -- which is the point of Rule 80, not a decoration
	cF = oPanel.Focused()
	if cF != ""
		aB = oPanel.BoxOf(cF)
		if len(aB) = 4
			oCanvas.AddRectQ(aB[1] - 3, aB[2] - 3, aB[3] + 6, aB[4] + 6).
				StrokeQ("#e6b45c", 2)
		ok
	ok
	oCanvas.AddTextQ(cStatus, 18, oPanel.Height() - 12).
		SetFontQ(TheFont(), 13).ColorQ("#7c9cbf")

func TheFont
	if $oFormFont = NULL
		$oFormFont = new stzFont(FontPath())
	ok
	return $oFormFont

func SourceName n
	aN = [ "pointer", "keyboard", "gamepad", "synthetic", "assistive" ]
	if n >= 0 and n < len(aN)
		return aN[n + 1]
	ok
	return "?"

func ListToText a
	c = ""
	for i = 1 to len(a)
		if i > 1  c += " -> " ok
		c += a[i]
	next
	return c

func FontPath
	a = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
	      "../gpu/fixtures/amiri_arabic_subset.ttf" ]
	for i = 1 to len(a)
		if fexists(a[i])
			return a[i]
		ok
	next
	return ""
