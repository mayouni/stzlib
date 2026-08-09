load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GR5 SHOWCASE -- an interactive window.

	Not a guard. This is the thing a person can actually use: a window that
	responds to the keyboard and the mouse, animates in real time, and
	redraws with no pixel ever crossing the bus.

	Controls
	    arrows / WASD   move the ship
	    SPACE           drop a marker where you are
	    C               clear the markers
	    V               toggle vsync (watch the FPS number)
	    ESCAPE          quit

	Run it:  ring showcase_window.ring
	Or:      ring showcase_window.ring 180
	         -- run 180 frames, save the last one as a PNG, and quit. An
	            interactive demo that cannot be checked without a human is
	            a demo nobody ever checks.
---------------------------------------------------------------------------*/

if NOT StzWindowingAvailable()
	? "No windowing on this machine -- nothing to show."
	return
ok

decimals(1)

# frame budget: 0 = run until the user quits
nMaxFrames = 0
if len(sysargv) >= 3
	nMaxFrames = number(sysargv[3])
ok

nW = 900  nH = 560

oWin = new stzWindow(nW, nH, "Softanza GR5 -- move with the arrows, SPACE to mark")
if NOT oWin.CanDraw()
	? "A window opened but there is no GPU device to draw with."
	oWin.Free()
	return
ok

oCanvas = new stzCanvas(nW, nH)

# ship state, in pixels and pixels-per-SECOND (never per frame)
nX = nW / 2
nY = nH / 2
nSpeed = 420
aMarks = []
nHue = 0

# a soft trail: the last N positions, so movement leaves a wake
aTrail = []
nTrailMax = 40

while oWin.IsOpen()

	oWin.Poll()

	#-- input ---------------------------------------------------------
	if oWin.KeyPressed(:Escape)
		oWin.Close()
		exit
	ok
	if nMaxFrames > 0 and oWin.FrameCount() >= nMaxFrames
		exit
	ok

	nDt = oWin.DeltaTime()
	nStep = nSpeed * nDt          # time-based: the same speed on any machine

	if oWin.KeyDown(:Left)  or oWin.KeyDown(:A)  nX -= nStep  ok
	if oWin.KeyDown(:Right) or oWin.KeyDown(:D)  nX += nStep  ok
	if oWin.KeyDown(:Up)    or oWin.KeyDown(:W)  nY -= nStep  ok
	if oWin.KeyDown(:Down)  or oWin.KeyDown(:S)  nY += nStep  ok

	# In frame-budget mode nobody is at the keyboard, so fly the ship on a
	# lissajous curve and drop a marker now and then. A self-check that
	# exercises nothing proves nothing -- the saved frame has to show the
	# trail and the markers, or it is only testing that a circle draws.
	if nMaxFrames > 0
		nT = oWin.FrameCount() / 30
		nX = oWin.Width()  / 2 + 300 * sin(nT)
		nY = oWin.Height() / 2 + 170 * sin(nT * 1.7)
		if oWin.FrameCount() % 25 = 0
			aMarks + [ nX, nY, nHue ]
		ok
	ok

	# held keys move; PRESSED keys command -- one press, one marker
	if oWin.KeyPressed(:Space)
		aMarks + [ nX, nY, nHue ]
	ok
	if oWin.KeyPressed(:C)
		aMarks = []
	ok
	if oWin.KeyPressed(:V)
		oWin.SetVSync(NOT oWin.VSync())
	ok

	# clicking places a marker too
	if oWin.MouseClicked(1)
		aMarks + [ oWin.MouseX(), oWin.MouseY(), nHue ]
	ok

	# stay on screen
	if nX < 20  nX = 20  ok
	if nY < 20  nY = 20  ok
	if nX > oWin.Width() - 20   nX = oWin.Width() - 20   ok
	if nY > oWin.Height() - 20  nY = oWin.Height() - 20  ok

	aTrail + [ nX, nY ]
	if len(aTrail) > nTrailMax
		del(aTrail, 1)
	ok
	nHue = (nHue + 90 * nDt) % 360

	#-- the picture ---------------------------------------------------
	#
	# Rebuilt from scratch every frame. Clear() is what keeps the display
	# list flat instead of growing by a frame's worth of shapes forever.

	oCanvas.Clear()
	oCanvas.AddGradientRect(0, 0, oWin.Width(), oWin.Height(),
				"#0B1020", "#1B2A4A", TRUE)

	# markers, oldest first
	nM = len(aMarks)
	for i = 1 to nM
		oCanvas.AddCircleQ(aMarks[i][1], aMarks[i][2], 9).
			Fill(StzColorFromHSL(aMarks[i][3], 70, 55))
	next

	# the wake: older points smaller and dimmer
	nT = len(aTrail)
	for i = 1 to nT
		nF = i / nT
		oCanvas.AddCircleQ(aTrail[i][1], aTrail[i][2], 2 + 10 * nF).
			Fill(StzColorWithAlpha("#60A0FF", 10 + 60 * nF))
	next

	# the ship
	oCanvas.AddCircleQ(nX, nY, 18).
		StrokeQ("#FFFFFF", 2).Fill(StzColorFromHSL(nHue, 80, 60))

	# a HUD bar
	oCanvas.AddRectQ(0, 0, oWin.Width(), 34).Fill(StzColorWithAlpha("#000000", 110))

	oWin.Draw(oCanvas)

	# the title is the readout -- no text pipeline needed for a demo
	if oWin.FrameCount() % 15 = 0
		oWin.SetTitle("Softanza GR5   " + oWin.FPS() + " fps" +
			"   vsync " + oWin.VSync() +
			"   marks " + len(aMarks) +
			"   [arrows/WASD move, SPACE mark, C clear, V vsync, ESC quit]")
	ok

end

? ""
? "frames drawn : " + oWin.FrameCount()
? "surface      : " + @@(oWin.Stats())
? "markers left : " + len(aMarks)

# The SAME canvas that was on screen a moment ago, written to a file. Not a
# re-draw and not a second code path -- one display list, two destinations.
if nMaxFrames > 0
	cPng = oCanvas.ToPNG("showcase_window.png")     # returns the BYTES
	? "last frame   : showcase_window.png (" + len(cPng) + " bytes)"
ok

oWin.Free()
? "closed cleanly."
