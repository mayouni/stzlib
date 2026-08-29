# §6 LIVE -- an interface hanging in a 3D world, in a real window.
#
#     console.panel -> stzPanel -> stzCanvas -> a texture -> a quad
#                                                              |
#     the mouse -> a ray through the camera -> a uv -> panel pixels
#
# THIS IS THE WHOLE OF §6's TIER, MOVING. The scene panel guard proves
# the mapping is arithmetically right; this proves it is right against a
# camera the user is dragging, in a window the user can resize, at
# whatever frame rate the machine gives.
#
#     DRAG        orbit the camera around the console
#     WHEEL-ish   W / S move in and out
#     MOVE        hover -- the panel lights the element under the ray
#     CLICK       activate it, THROUGH the camera
#     TAB         focus the next stop (the panel's own ring, unchanged)
#     R           reload console.panel from disk, through the court
#     ESC         quit
#
# WHAT TO WATCH FOR, because it is the point: the console reacts to a
# mouse that never touches it. The pointer is somewhere on a 900x600
# window; the button it lights is at some pixel of a 512x320 interface
# painted onto a quad seen at an angle. Nothing about the panel knows
# any of that -- §7's coordinate frame is dissolved, and stzScenePanel
# is the named conversion at the boundary.
#
#     ring gui_scene_window.ring          # the window
#     ring gui_scene_window.ring shot     # one PNG, no window

load "../../stzBase.ring"

if NOT StzGuiAvailable()
	? "No layout engine here (stz_gui.dll absent)."
	return
ok

decimals(2)

$cStatus = "drag to orbit - click the console through the camera"
$nHits = 0

func main
	bShot = 0
	nBudget = 0
	if len(sysargv) >= 3 and lower("" + sysargv[3]) = "shot"
		bShot = 1
	ok
	# A FRAME BUDGET, so the loop is checkable without a person in it:
	# the window opens, runs N frames and closes on its own. Not a
	# substitute for driving it by hand -- every visual defect in this
	# plane was found by a person looking -- but it proves the loop
	# builds, draws and tears down.
	if len(sysargv) >= 4 and lower("" + sysargv[3]) = "frames"
		nBudget = 0 + sysargv[4]
	ok

	oP = BuildPanel($cStatus)
	if oP = NULL
		return
	ok

	oScene = new stzScene(900, 600)
	oScene.SetLight(-0.3, -1, -0.4, "#ffffff", "#20242c")

	oSP = new stzScenePanel(oP, oScene, 3.0)
	if NOT oSP.Mount()
		? "No GPU here -- the panel cannot hang in a world."
		return
	ok

	# the camera in POLAR coordinates, which is what a drag actually
	# moves: an angle around, an angle up, and a distance
	nYaw = 0
	nPitch = 0.62
	nDist = 3.4

	if bShot or NOT StzWindowingAvailable()
		AimCamera(oScene, oSP, nYaw, nPitch, nDist)
		oScene.ToPNG("gui_scene_window.png")
		if bShot
			? "Wrote gui_scene_window.png (asked for a shot)."
		else
			? "Wrote gui_scene_window.png (no windowing on this machine)."
		ok
		oSP.Free()
		oP.Free()
		return
	ok

	oWin = new stzWindow(900, 600, "Softanza - a console in a world")

	# THE G4b PRECONDITION, and the reason this session came here at all:
	# every accessibility adapter attaches to the platform's own handle.
	? "native window handle: " + oWin.NativeHandle() +
	  "   (what an AccessKit adapter would subclass)"
	? ""

	nLastX = oWin.MouseX()
	nLastY = oWin.MouseY()
	bWasDown = 0

	while oWin.IsOpen()
		oWin.Poll()
		if oWin.KeyPressed(:Escape)
			exit
		ok

		#-- the camera the user is dragging --------------------------
		nX = oWin.MouseX()
		nY = oWin.MouseY()
		bDown = oWin.MouseDown(1)
		bDragging = 0
		if bDown and bWasDown
			nDX = nX - nLastX
			nDY = nY - nLastY
			if fabs(nDX) > 0 or fabs(nDY) > 0
				bDragging = 1
				nYaw = nYaw - nDX * 0.006
				nPitch = nPitch + nDY * 0.005
				if nPitch < 0.12
					nPitch = 0.12          # never edge-on: nothing to read
				ok
				if nPitch > 1.45
					nPitch = 1.45          # never straight down either
				ok
			ok
		ok
		if oWin.KeyDown(:W)
			nDist = nDist - 0.04
			if nDist < 1.6
				nDist = 1.6
			ok
		ok
		if oWin.KeyDown(:S)
			nDist = nDist + 0.04
			if nDist > 9
				nDist = 9
			ok
		ok

		# THE ONE LINE A GAME LOOP OWES THIS CLASS. The camera moved, so
		# the mapping must be told -- Ring copies an object on assign, so
		# a held scene is a snapshot, and the guard's first negative
		# controls both passed at zero error until this existed.
		AimCamera(oScene, oSP, nYaw, nPitch, nDist)

		#-- the mouse, delivered THROUGH the camera ------------------
		# hover always; click only on the release edge, and never on the
		# frame that ended a drag -- letting go of an orbit is not a
		# click on whatever the pointer happens to be over.
		bOver = oSP.PointerMovedToScreen(nX, nY)

		if oWin.MouseClicked(1) and NOT bDragging
			if oSP.ClickAtScreen(nX, nY)
				aPt = oSP.PanelPointAtScreen(nX, nY)
				cEl = oP.ElementAt(aPt[1], aPt[2])
				aEv = oP.Events()
				oP.ClearEvents()
				if cEl != ""
					$nHits++
					oP = Reacted(oP, cEl, nX, nY, aPt)
					oSP.Shows(oP)
				ok
			ok
		ok

		if oWin.KeyPressed(:Tab)
			oP.FocusNext()
			oSP.Refresh()
		ok

		if oWin.KeyPressed(:R)
			oP2 = BuildPanel("reloaded from disk - " + $nHits + " hits so far")
			if oP2 != NULL
				oP = oP2
				oSP.Shows(oP)
			ok
		ok

		nLastX = nX
		nLastY = nY
		bWasDown = bDown

		oWin.Draw(oScene)

		if nBudget > 0 and oWin.FrameCount() >= nBudget
			? "frame budget reached (" + nBudget + ")"
			exit
		ok
	end

	? "closed after " + oWin.FrameCount() + " frames, " + $nHits + " hits"
	oSP.Free()
	oP.Free()
	oWin.Free()

#-- the camera, and the one line that keeps the mapping honest ----------

func AimCamera oScene, oSP, nYaw, nPitch, nDist
	nEY = nDist * sin(nPitch)
	nR = nDist * cos(nPitch)
	oScene.SetCamera(nR * sin(nYaw), nEY, nR * cos(nYaw),  0, 0, 0)
	oSP.LooksThrough(oScene)

#-- the app reacting, which is what proves the click arrived ------------

func Reacted oP, cEl, nX, nY, aPt
	cWhat = "screen " + floor(nX) + "," + floor(nY) +
		" -> panel " + floor(aPt[1]) + "," + floor(aPt[2]) +
		" -> " + cEl
	oP2 = BuildPanel(cWhat)
	if oP2 = NULL
		return oP
	ok
	? "  hit " + $nHits + ": " + cWhat
	return oP2

func BuildPanel cStatus
	cSrc = read("console.panel")
	cSrc = StzReplace(cSrc, "click me through the camera", cStatus)
	oU = new stzUiDocument(cSrc)
	if NOT oU.IsClean()
		? "console.panel did not pass the court:"
		? oU.Report()
		return NULL
	ok
	oU.UseFont(FontPath())
	return oU.ToPanel()

func FontPath
	_a_ = [ "C:\Windows\Fonts\segoeui.ttf", "C:\Windows\Fonts\arial.ttf" ]
	_aC136_ = _a_
	_nC136_ = len(_aC136_)
	for _iC136_ = 1 to _nC136_
		_c_ = _aC136_[_iC136_]
		if fexists(_c_)
			return _c_
		ok
	next
	return ""
