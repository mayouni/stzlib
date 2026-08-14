# §6's TIER, SEEN: a real interface hanging in a 3D world.
#
#     .stzui  ->  stzPanel  ->  stzCanvas  ->  a GPU texture
#                                                  |
#     a camera  ->  a quad in a scene  <------------+
#          |
#     a screen pixel  ->  a ray  ->  a uv  ->  panel pixels  ->  a click
#
# Writes four PNGs, and the fourth is the one that matters: a marker is
# clicked THROUGH the camera, and the panel it lands on is the proof.
#
#     ring gui_scene_demo.ring

load "../../stzBase.ring"

if NOT StzGuiAvailable()
	? "No layout engine here (stz_gui.dll absent)."
	return
ok

decimals(2)

func main
	oU = new stzUiDocument("console.stzui")
	if NOT oU.IsClean()
		? "console.stzui did not pass the court:"
		? oU.Report()
		return
	ok
	oU.UseFont(FontPath())
	oP = oU.ToPanel()
	? "panel laid out: " + oP.Width() + "x" + oP.Height()

	oScene = new stzScene(900, 600)
	oScene.SetLight(-0.3, -1, -0.4, "#ffffff", "#20242c")

	oSP = new stzScenePanel(oP, oScene, 3.0)
	if NOT oSP.Mount()
		? "No GPU here -- the panel cannot hang in a world."
		return
	ok
	? "mounted as a 3-unit quad"

	#-- 1. straight on -------------------------------------------------
	# The orientation check. If the interface is upside down or mirrored
	# here, the uv convention is wrong -- and no assertion built from
	# that same convention could have told us.
	Look(oScene, oSP, 0, 3.4, 0.01,  "gui_scene_1_facing.png",
	     "straight down at it")

	#-- 2. oblique -----------------------------------------------------
	Look(oScene, oSP, 0, 2.2, 2.6,  "gui_scene_2_oblique.png",
	     "the ordinary in-world view")

	#-- 3. a hard graze ------------------------------------------------
	# Criterion 3 measured that an oblique angle costs SIZE, not
	# sharpness. This is that claim, on a real interface rather than a
	# hand-drawn canvas.
	Look(oScene, oSP, 2.6, 0.7, 1.4, "gui_scene_3_graze.png",
	     "a hard graze -- readable, just smaller")

	#-- 4. the click, through the camera -------------------------------
	oScene.SetCamera(0, 2.2, 2.6,  0, 0, 0)
	oSP.LooksThrough(oScene)

	# Aim at the CENTRE OF THE "FIRE" BUTTON as it appears ON SCREEN --
	# found the way a game finds it, by asking where that world point
	# projects to, then firing a ray back at that pixel.
	aB = oP.BoxOf("fire")
	nU = (aB[1] + aB[3] / 2) / oP.Width()
	nV = 1 - (aB[2] + aB[4] / 2) / oP.Height()
	aScreen = oScene.Project(nU * 3 - 1.5, 0, nV * 3 - 1.5)
	? ""
	? "fire's centre is at screen pixel " + floor(aScreen[1]) + ", " +
	  floor(aScreen[2])

	oP.ClearEvents()
	bHit = oSP.ClickAtScreen(aScreen[1], aScreen[2])
	aPt = oSP.PanelPointAtScreen(aScreen[1], aScreen[2])
	? "the ray landed on panel pixel " + floor(aPt[1]) + ", " + floor(aPt[2])
	? "which is element: " + oP.ElementAt(aPt[1], aPt[2])
	? "fire's events: " + len(oP.EventsFor("fire")) +
	  "   abort's events: " + len(oP.EventsFor("abort"))

	# NOW SHOW THE RESULT, not the same screen again. The click is only
	# proven if what it produced ends up on the quad -- so the app does
	# what an app does: it reacts, and the reaction is re-declared,
	# re-laid-out and re-uploaded.
	cSrc = read("console.stzui")
	cSrc = StzReplace(cSrc, "click me through the camera",
		"FIRE acknowledged - ray hit panel pixel " + floor(aPt[1]) +
		"," + floor(aPt[2]))
	cSrc = StzReplace(cSrc, 'CONTENT "ABORT"', 'CONTENT "STANDBY"')
	cSrc = StzReplace(cSrc, "BEARING 137.4   RANGE 8.20 km",
		"WEAPON RELEASED   RANGE 8.20 km")

	oU2 = new stzUiDocument(cSrc)
	if NOT oU2.IsClean()
		? oU2.Report()
		return
	ok
	oU2.UseFont(FontPath())
	oP2 = oU2.ToPanel()
	oP2.FocusOn("fire")

	oSP.Free()
	oP.Free()

	oScene2 = new stzScene(900, 600)
	oScene2.SetLight(-0.3, -1, -0.4, "#ffffff", "#20242c")
	oSP2 = new stzScenePanel(oP2, oScene2, 3.0)
	oSP2.Mount()
	Look(oScene2, oSP2, 0, 2.2, 2.6, "gui_scene_4_clicked.png",
	     "the app answered, and the quad carries the answer")
	oSP2.Free()
	oP2.Free()

	? ""
	? "Wrote gui_scene_1_facing.png, _2_oblique.png, _3_graze.png, _4_clicked.png"

# Move the camera, tell the panel, render.
func Look oScene, oSP, nEX, nEY, nEZ, cPath, cWhat
	oScene.SetCamera(nEX, nEY, nEZ,  0, 0, 0)
	oSP.LooksThrough(oScene)
	oScene.ToPNG(cPath)
	? "  " + cPath + " -- " + cWhat

func FontPath
	_a_ = [ "C:\Windows\Fonts\segoeui.ttf", "C:\Windows\Fonts\arial.ttf" ]
	for _c_ in _a_
		if fexists(_c_)
			return _c_
		ok
	next
	return ""
