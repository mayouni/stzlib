load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG3 LIVE -- watch a chain behave like a chain

	An orrery where every body is PARENTED to the one it orbits. Nothing
	computes a moon's absolute position: the moon knows only where it sits
	relative to its planet, the planet only where it sits relative to the
	sun. The engine composes.

	    SPACE   pause / resume
	    P       detach every planet from the sun  <- THE demonstration
	    M       detach the moon from its planet
	    R       re-attach everything
	    ARROWS  move the SUN -- and watch what follows
	    ESC     quit

	P is the one to press. Detached, the planets keep their own LOCAL
	transforms and immediately collapse toward the origin, because those
	transforms were never absolute -- they only ever meant "relative to the
	sun". Press R and the system reassembles.
---------------------------------------------------------------------------*/

if NOT StzWindowingAvailable()
	? "No windowing here -- run gg3_hierarchy.ring for the file version."
	return
ok

decimals(2)

oSunMesh    = new stzMesh([ :Sphere, 1.5 ])
oPlanetMesh = new stzMesh([ :Sphere, 0.55 ])
oMoonMesh   = new stzMesh([ :Sphere, 0.26 ])

oScene = new stzScene(1100, 660)
oScene.SetBackgroundQ("#05080F").SetCamera(0, 9, 22, 0, 0, 0)
oScene.SetLight(-0.4, -1, -0.3, "#FFF4DC", "#1B2138")

oScene.AddMeshQ(oSunMesh, 0, 0, 0).Color("#FFC53D")
nSun = oScene.LastIndex()

aOrbit = [ 5.0, 8.0, 11.5 ]
aCol   = [ "#4FA3E0", "#E06C4F", "#7FD8A0" ]
aSpeed = [ 0.9, 0.55, 0.35 ]
aPlanet = []
for i = 1 to 3
	oScene.AddMeshQ(oPlanetMesh, aOrbit[i], 0, 0).Color(aCol[i])
	aPlanet + oScene.LastIndex()
	oScene.SetParent(aPlanet[i], nSun)
next

oScene.AddMeshQ(oMoonMesh, 1.4, 0, 0).Color("#DCDCEC")
nMoon = oScene.LastIndex()
oScene.SetParent(nMoon, aPlanet[2])

oWin = new stzWindow(1100, 660, "GG3 -- a chain behaves like a chain")
if NOT oWin.CanDraw()
	? "no device."
	oWin.Free()
	return
ok

nClock = 0
bPaused = FALSE
nSunX = 0
nSunZ = 0

while oWin.IsOpen()
	oWin.Poll()
	if oWin.Width() < 1 or oWin.Height() < 1
		loop
	ok

	if oWin.KeyPressed(:Escape)
		oWin.Close()
		exit
	ok
	if oWin.KeyPressed(:Space)  bPaused = NOT bPaused  ok

	if oWin.KeyPressed(:P)
		for i = 1 to 3
			oScene.ClearParent(aPlanet[i])
		next
	ok
	if oWin.KeyPressed(:M)
		oScene.ClearParent(nMoon)
	ok
	if oWin.KeyPressed(:R)
		for i = 1 to 3
			oScene.SetParent(aPlanet[i], nSun)
		next
		oScene.SetParent(nMoon, aPlanet[2])
	ok

	nDt = oWin.DeltaTime()
	if nDt > 0.1  nDt = 0.1  ok
	if bPaused    nDt = 0    ok
	nClock += nDt

	# the SUN is the only thing the arrows move
	nSpd = 6 * nDt
	if oWin.KeyDown(:Left)   nSunX -= nSpd  ok
	if oWin.KeyDown(:Right)  nSunX += nSpd  ok
	if oWin.KeyDown(:Up)     nSunZ -= nSpd  ok
	if oWin.KeyDown(:Down)   nSunZ += nSpd  ok
	oScene.MoveTo(nSun, nSunX, 0, nSunZ)

	# every body is placed in its PARENT's frame -- no absolute positions
	# are computed anywhere in this loop
	for i = 1 to 3
		nA = nClock * aSpeed[i]
		oScene.MoveTo(aPlanet[i], cos(nA) * aOrbit[i], 0, sin(nA) * aOrbit[i])
	next
	nAM = nClock * 2.4
	oScene.MoveTo(nMoon, cos(nAM) * 1.4, 0, sin(nAM) * 1.4)

	oWin.Draw(oScene)

	if oWin.FrameCount() % 20 = 0
		aW = oScene.WorldPosition(nMoon)
		oWin.SetTitle("GG3   depth " + oScene.HierarchyDepth() +
			"   moon world x " + aW[1] +
			"   " + oWin.FPS() + " fps" +
			"   [P detach planets, M moon, R restore, arrows move sun]")
	ok
end

? ""
? "frames : " + oWin.FrameCount()
? "depth  : " + oScene.HierarchyDepth()
oWin.Free()
? "closed cleanly."
