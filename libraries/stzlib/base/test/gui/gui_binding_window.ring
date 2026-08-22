# G5 LIVE -- a screen whose values move, and a screen that gets rebuilt.
#
#     bound.panel   ->  stzUiDocument  ->  stzPanel  ->  a window
#                             |
#     oB.Set(:bearing, ...)  ->  the element changes, the document lives
#
# THE WHOLE POINT IS VISIBLE HERE, and it is not speed.
#
#     TAB     move focus between FIRE and ABORT -- watch the ring
#     SPACE   pause / resume the moving numbers
#     R       REBUILD the screen the old way, as a reload would
#     ESC     quit
#
# The numbers move continuously by BINDING. Put focus on a button with
# TAB and keep watching: the values keep changing and THE FOCUS RING
# STAYS WHERE YOU PUT IT.
#
# Now press R. That rebuilds the document exactly as the showcase
# viewer's reload and stzScenePanel.Shows do -- and the focus ring
# VANISHES, because a rebuild throws away the panel the user was
# standing in. The status line counts how many times each has happened.
#
# That is the difference G5 bought, stated as something you can watch
# rather than something the guard asserts on your behalf.

load "../../stzBase.ring"

if NOT StzGuiAvailable()
	? "No layout engine here (stz_gui.dll absent)."
	return
ok

decimals(1)

# Declared BEFORE main, because a global first assigned inside a func is
# not visible to another one that runs earlier in the same frame.
$oFont = NULL

func main
	nBudget = 0
	if len(sysargv) >= 4 and lower("" + sysargv[3]) = "frames"
		nBudget = 0 + sysargv[4]
	ok

	oU = new stzUiDocument("bound.panel")
	if NOT oU.IsClean()
		? oU.Report()
		return
	ok
	oU.UseFont(FontPath())
	oP = oU.ToPanel()
	oB = new stzUiBindings(oU, oP)

	? "declared bindings: " + ListJoin(oB.Names())
	? ""
	? "  TAB    move focus        SPACE  pause the numbers"
	? "  R      REBUILD (the old way -- watch the focus ring go)"
	? "  ESC    quit"
	? ""

	if NOT StzWindowingAvailable()
		Fill(oB, 137.4, 8.2, 98)
		oC = new stzCanvas(oP.Width(), oP.Height())
		oC.Clear()
		oP.DrawInto(oC)
		oC.ToPNG("gui_binding_window.png")
		? "No windowing here -- wrote gui_binding_window.png instead."
		return
	ok

	oWin = new stzWindow(oP.Width(), oP.Height() + 40,
		"Softanza -- G5, a value changes and the screen follows")
	oC = new stzCanvas(oWin.Width(), oWin.Height())

	nBearing = 137.4
	nRange = 8.2
	nHull = 98
	nBinds = 0
	nRebuilds = 0
	bRun = TRUE
	oP.FocusOn("fire")

	while oWin.IsOpen()
		oWin.Poll()
		if oWin.KeyPressed(:Escape)
			exit
		ok
		if oWin.KeyPressed(:Space)
			bRun = NOT bRun
		ok
		if oWin.KeyPressed(:Tab)
			oP.FocusNext()
		ok

		# THE OLD WAY, on demand, so the two can be compared in one sitting.
		if oWin.KeyPressed("R")
			oP.Free()
			oU = new stzUiDocument("bound.panel")
			oU.UseFont(FontPath())
			oP = oU.ToPanel()
			oB = new stzUiBindings(oU, oP)
			Fill(oB, nBearing, nRange, nHull)
			nRebuilds++
			? "  REBUILT -- focus is now [" + oP.Focused() + "]"
		ok

		#-- the binding, every frame ---------------------------------
		if bRun
			nBearing += 0.7
			if nBearing >= 360
				nBearing -= 360
			ok
			nRange -= 0.004
			if nRange < 0.2
				nRange = 8.2
			ok
			nHull -= 0.02
			if nHull < 40
				nHull = 98
			ok
			# ONE call, several values, each element touched once.
			Fill(oB, nBearing, nRange, nHull)
			nBinds++
		ok

		oC.Clear()
		oC.SetBackground("#05080c")
		oP.DrawInto(oC)

		# The status line is drawn by the graphics plane, deliberately
		# OUTSIDE the panel -- it is commentary on the panel, not part of
		# the interface being demonstrated.
		cF = oP.Focused()
		if cF = ""
			cF = "(nothing -- a rebuild took it)"
		ok
		oC.AddTextQ("focus: " + cF + "    bound updates: " + nBinds +
			"    rebuilds: " + nRebuilds, 14, oWin.Height() - 14).
			SetFontQ($oFont, 13).ColorQ("#7d93a8")

		oWin.Draw(oC)

		if nBudget > 0 and oWin.FrameCount() >= nBudget
			exit
		ok
	end

	? ""
	? "closed after " + oWin.FrameCount() + " frames: " +
	  nBinds + " bound updates, " + nRebuilds + " rebuilds"
	oP.Free()
	oWin.Free()

# One call, several values -- so a line built from three of them is set
# ONCE rather than three times. A reader watching a status line would
# otherwise hear two states that never existed.
func Fill oB, nBearing, nRange, nHull
	cMode = "CRUISE"
	if nRange < 3
		cMode = "TERMINAL"
	but nRange < 6
		cMode = "APPROACH"
	ok
	cDrift = "nominal"
	if nHull < 70
		cDrift = "high"
	ok
	oB.SetMany([
		:bearing = "" + nBearing,
		:range = "" + nRange,
		:hull = "" + floor(nHull),
		:mode = cMode,
		:drift = cDrift ])

	# STYLE IS THE SURGICAL HALF, and this is what it is for: the readout
	# turns amber as the hull falls. A colour re-shapes one string; the
	# values above re-shape the document. Two verbs, two costs.
	if nHull < 70
		oB.SetStyle("line_two", "color", "#e0a030")
	else
		oB.ClearStyle("line_two", "color")
	ok

func ListJoin aList
	_c_ = ""
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if _i_ > 1
			_c_ += ", "
		ok
		_c_ += aList[_i_]
	next
	return _c_

func FontPath
	_a_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf" ]
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if fexists(_a_[_i_])
			$oFont = new stzFont(_a_[_i_])
			return _a_[_i_]
		ok
	next
	return ""
