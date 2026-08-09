load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	SOFTANZA GRAPHICS -- THE GALLERY

	Five animated scenes on one canvas, cycling by themselves. Everything
	here is built from the primitives the plane actually ships -- circles,
	polygons, polylines, gradients, shaped text -- and coloured through
	stzColor's computed forms. Nothing is a texture, an image, or a shader
	trick; it is all display list.

	    1 / SPACE      next scene           P      pause
	    LEFT / RIGHT   previous / next      G      toggle the grid
	    V              vsync on/off         ESC    quit

	It auto-advances every 14 seconds if you leave it alone.

	Run it:  ring showcase_gallery.ring
	Or:      ring showcase_gallery.ring shots
	         -- render each scene headless and save a PNG of it, so the
	            gallery can be checked without a human watching it.

	WHAT A FRAME ACTUALLY COSTS, measured rather than assumed -- and the
	first measurement was misleading, so both are here.

	Probing circles alone suggested a simple story: colour per shape cost
	10.93 ms per 600 circles, a lookup 5.47 ms, a constant 5.51 ms. So
	StzColorFromHSL was exactly half the frame, and the palette below is
	built ONCE at startup and indexed. That part held.

	The other half of that story -- "cost is shape count" -- did not
	survive the finished scenes:

	    scene          shapes   ms    ->  shapes   ms    fps
	    BLOOM              93   2.7          93   2.6    383
	    RIBBONS            19   6.6          19   6.7    149
	    ORRERY            563   9.8         563   9.9    101
	    HARMONOGRAPH       17  17.2          16   9.9    101
	    FLOW FIELD       1810  21.3        1250  15.2     66

	HARMONOGRAPH drew SEVENTEEN shapes and was the second most expensive
	scene in the set. The cost is not the shapes and not the GPU: it is
	the interpreted Ring loop APPENDING POINTS -- six thousand of them per
	frame for those seventeen polylines. A polyline is one cheap call
	carrying an expensive list.

	So the budget rule for this plane is: count the POINTS your Ring code
	touches per frame, not the shapes it emits. HARMONOGRAPH went from 58
	to 101 fps by dropping ONE curve and coarsening the step -- a change
	of one shape. FLOW FIELD needed real particles removed, because there
	the shapes and the points are the same thing. Every scene now clears
	60 fps with vsync off, which is the only way to see what a frame
	actually costs.
---------------------------------------------------------------------------*/

if NOT StzWindowingAvailable()
	? "No windowing on this machine -- nothing to show."
	return
ok

decimals(1)

bShots = FALSE
if len(sysargv) >= 3 and sysargv[3] = "shots"
	bShots = TRUE
ok

# ---- responsive layout ---------------------------------------------------
#
# THE REFERENCE DESIGN. Every radius and amplitude below was sized against
# these numbers, so they are kept as the thing to SCALE FROM rather than
# scattered through the scenes as magic constants.
REF_W = 1100
REF_H = 660
REF_BAR = 62
REF_CX = REF_W / 2
REF_CY = (REF_H - REF_BAR) / 2

# The live layout, recomputed EVERY FRAME from the window (Layout() below).
# Computing it once at startup is what made the first gallery drift off
# centre the moment anybody dragged an edge.
nW = REF_W
nH = REF_H
nBar = REF_BAR
nDrawH = nH - nBar
nCX = nW / 2
nCY = nDrawH / 2           # centre of what the eye reads as the picture,
                           # NOT of the canvas -- otherwise every scene sits
                           # low and the biggest ones run under the caption
nScale = 1                 # uniform, from whichever axis is tighter
nBarFont = 26
nBarSub = 15

TWO_PI = 6.283185307179586
DEG = 3.141592653589793 / 180

#-- the palette, built ONCE ------------------------------------------------
#
# 360 hues x 3 lightness bands. Building this costs about 4 ms at startup
# and saves half of every frame afterwards.

aPal = []       # vivid
aPalSoft = []   # pastel, for washes and glows
aPalDeep = []   # deep, for shadows and fills
for h = 0 to 359
	aPal     + StzColorFromHSL(h, 78, 58)
	aPalSoft + StzColorFromHSL(h, 55, 72)
	aPalDeep + StzColorFromHSL(h, 65, 32)
next

#-- the window -------------------------------------------------------------

oWin = new stzWindow(nW, nH, "Softanza Graphics -- the gallery")
if NOT oWin.CanDraw()
	? "A window opened but there is no GPU device to draw with."
	oWin.Free()
	return
ok

oCanvas = new stzCanvas(nW, nH)

# Shaped text, through the GR2 pipeline (bidi -> HarfBuzz -> stb). Optional:
# the gallery draws fine without it, it just loses its captions.
oFont = NULL
cFontPath = "C:/Windows/Fonts/segoeui.ttf"
if NOT fexists(cFontPath)
	cFontPath = "C:/Windows/Fonts/arial.ttf"
ok
if fexists(cFontPath)
	try
		oFont = new stzFont(cFontPath)
	catch
		oFont = NULL
	done
ok

#-- scenes -----------------------------------------------------------------

aScenes = [
	[ :Flow,      "FLOW FIELD",     "620 particles reading a field of angles" ],
	[ :Harmonic,  "HARMONOGRAPH",   "decaying pendulums, one polyline each" ],
	[ :Bloom,     "BLOOM",          "nested polygons, rotating out of phase" ],
	[ :Orrery,    "ORRERY",         "nested orbits, each carrying the next" ],
	[ :Ribbons,   "RIBBONS",        "rose curves under a moving phase" ]
]
# The orrery's positions are computed ONCE per frame into these, and both
# the trail and the drawing read them. They used to be computed TWICE --
# in StepOrrery (which knew nothing of nScale) and again in DrawOrrery
# (which did) -- and the two silently disagreed the moment a scale existed:
# bodies drew inside a 173 px system while their trails swept 432 px and
# flew off the window. Duplicated logic does not stay equal; it only looks
# equal until something changes on one side.
aPos = []       # [x, y] of each body, this frame
aParent = []    # [x, y] of whatever it orbits

nScene = 1
nSceneTime = 0
nHold = 14           # seconds before it advances by itself
bPaused = FALSE
bGrid = FALSE
nClock = 0           # the one animation clock, in seconds

#-- flow-field particles ---------------------------------------------------

# Particles need FINITE LIVES. Left alone, a flow field does exactly what
# a flow field is supposed to do -- every particle converges onto an
# attracting curve and the rest of the frame empties out. Beautiful for
# about four seconds, then it is three lines on a black field. Respawning
# on a staggered lifetime keeps the whole field populated and is what
# makes the STRUCTURE visible rather than just its limit set.
nParticles = 620
aPx = []  aPy = []  aPh = []  aPl = []
for i = 1 to nParticles
	aPx + (random(1000) / 1000 * nW)
	aPy + (random(1000) / 1000 * nH)
	aPh + (random(359))
	aPl + (30 + random(150))        # staggered, so they do not all die at once
next

#-- orrery bodies ----------------------------------------------------------
#     [ orbit radius, angular speed, body radius, hue, trail ]
# Nested, so the radii ADD UP -- body 4 can reach the SUM of all four from
# the centre. That sum is the number to size against, not any one radius:
# 132+152+92+56 = 432 across, x0.55 tilt = 238 down, against nCY = 269.
# Sized once from that arithmetic; guessing gave a system that either ran
# off the bottom or floated tiny in the middle of an empty frame.
aBodies = [
	[ 132, 0.62, 15,  35, [] ],
	[ 152, 0.38, 10, 190, [] ],
	[  92, 1.05, 12, 285, [] ],
	[  56, 1.90,  7,  95, [] ]
]

#-- the loop ---------------------------------------------------------------

if bShots
	# headless-ish: draw each scene for a fixed time and save it
	nS = len(aScenes)
	for k = 1 to nS
		nScene = k
		# long enough for trails and particle structure to reach steady
		# state -- a still taken at frame 90 shows a scene still filling up
		nClock = 3.5
		for f = 1 to 260
			oWin.Poll()
			Layout()
			nClock += 1.0 / 60
			StepFlow(1.0 / 60)
			StepOrrery(1.0 / 60)
			DrawScene()
			oWin.Draw(oCanvas)
		next
		cName = "gallery_" + k + "_" + lower("" + aScenes[k][1]) + ".png"
		cB = oCanvas.ToPNG(cName)
		? "" + cName + "  (" + len(cB) + " bytes)"
	next
	oWin.Free()
	return
ok

while oWin.IsOpen()

	oWin.Poll()

	if oWin.KeyPressed(:Escape)
		oWin.Close()
		exit
	ok
	if oWin.KeyPressed(:P)
		bPaused = NOT bPaused
	ok
	if oWin.KeyPressed(:G)
		bGrid = NOT bGrid
	ok
	if oWin.KeyPressed(:V)
		oWin.SetVSync(NOT oWin.VSync())
	ok

	nAdvance = 0
	if oWin.KeyPressed(:Space) or oWin.KeyPressed("1") or oWin.KeyPressed(:Right)
		nAdvance = 1
	ok
	if oWin.KeyPressed(:Left)
		nAdvance = -1
	ok
	if nAdvance != 0
		nScene += nAdvance
		if nScene > len(aScenes)  nScene = 1  ok
		if nScene < 1             nScene = len(aScenes)  ok
		nSceneTime = 0
	ok

	nDt = oWin.DeltaTime()
	if nDt > 0.1         # a dragged window must not teleport everything
		nDt = 0.1
	ok
	if bPaused
		nDt = 0
	ok

	nClock += nDt
	nSceneTime += nDt
	if nSceneTime > nHold
		nSceneTime = 0
		nScene++
		if nScene > len(aScenes)  nScene = 1  ok
	ok

	Layout()
	StepFlow(nDt)
	StepOrrery(nDt)
	DrawScene()
	oWin.Draw(oCanvas)

	if oWin.FrameCount() % 20 = 0
		oWin.SetTitle("Softanza Gallery   " + aScenes[nScene][2] +
			"   " + oWin.FPS() + " fps   vsync " + oWin.VSync() +
			"   [SPACE next, P pause, G grid, V vsync, ESC quit]")
	ok
end

? ""
? "frames drawn : " + oWin.FrameCount()
? "surface      : " + @@(oWin.Stats())
oWin.Free()
? "closed cleanly."

#===========================================================================
# Ring runs a file top-down until the first func definition and never comes
# back, so everything below here is called from the loop above.
#===========================================================================

#-- layout -----------------------------------------------------------------

# Recompute everything geometric from the CURRENT window. Called once per
# frame, before any stepping or drawing, so a frame is laid out and drawn
# at one consistent size -- reading the window twice in a frame is how a
# resize produces one torn picture.
func Layout
	_pw_ = nW
	_ph_ = nH
	nW = oWin.Width()
	nH = oWin.Height()
	if nW < 1  nW = 1  ok
	if nH < 1  nH = 1  ok

	# Chrome shrinks with the window but has a floor: a 62 px bar on a
	# 200 px window is not a caption, it is the window.
	nBar = nH * 0.094
	if nBar > REF_BAR  nBar = REF_BAR  ok
	if nBar < 34       nBar = 34       ok
	if nBar > nH * 0.5  nBar = nH * 0.5  ok

	nDrawH = nH - nBar
	nCX = nW / 2
	nCY = nDrawH / 2

	# ONE uniform scale, so circles stay circles -- scaling x and y
	# independently would stretch every scene into an ellipse the moment the
	# window stopped being 5:3.
	#
	# And it is measured RADIALLY, against the shorter half-axis, because
	# every scene here is centred and roughly circular. Treating the design
	# as a 1100-wide BOX instead made a portrait window scale by its width
	# (0.47) and leave half the height empty; measured radially the same
	# window scales 0.87 and fills it, with no distortion either way. The
	# reference is REF_CY because that is the axis the design was actually
	# sized against.
	nScale = nCX
	if nCY < nScale  nScale = nCY  ok
	nScale = nScale / REF_CY
	if nScale < 0.12  nScale = 0.12  ok

	nBarFont = 26 * nBar / REF_BAR
	nBarSub = 15 * nBar / REF_BAR
	if nBarFont < 11  nBarFont = 11  ok
	if nBarSub < 9    nBarSub = 9    ok

	# POSITION HISTORY DOES NOT SURVIVE A RESIZE. Trails hold ABSOLUTE
	# coordinates recorded at the old scale, so after a resize they hang in
	# the frame as arcs that belong to a window that no longer exists --
	# clearly visible as streaks flying off the edge. Particles self-heal
	# because they wrap; trails have no such mechanism, so they are dropped.
	if nW != _pw_ or nH != _ph_
		Reflow()
	ok

# Called by Layout when the window actually changed size.
func Reflow
	nB = len(aBodies)
	for i = 1 to nB
		aBodies[i][5] = []
	next
	# pull any particle that is now far outside back into view, so a shrink
	# does not leave most of the field parked off-screen waiting to expire
	for i = 1 to nParticles
		if aPx[i] < -20 or aPx[i] > nW + 20 or aPy[i] < -20 or aPy[i] > nH + 20
			aPx[i] = random(1000) / 1000 * nW
			aPy[i] = random(1000) / 1000 * nH
		ok
	next

#-- simulation -------------------------------------------------------------

# A flow field with no noise table: three sine terms of different period
# make a field that never repeats visibly and costs three sines to sample.
func FieldAngle x, y, t
	return (sin(x * 0.0055 + t * 0.30) +
	        sin(y * 0.0071 - t * 0.21) +
	        sin((x + y) * 0.0031 + t * 0.14)) * 2.1

func StepFlow dt
	if dt = 0 or aScenes[nScene][1] != :Flow
		return
	ok
	for i = 1 to nParticles
		nA = FieldAngle(aPx[i], aPy[i], nClock)
		aPx[i] += cos(nA) * 62 * nScale * dt
		aPy[i] += sin(nA) * 62 * nScale * dt
		# hue follows heading, so colour MEANS direction rather than decorating it
		aPh[i] = floor((nA / TWO_PI * 360) % 360)
		if aPh[i] < 0  aPh[i] += 360  ok
		# wrap, with a margin so nothing pops at the edge
		if aPx[i] < -20      aPx[i] = nW + 20  ok
		if aPx[i] > nW + 20  aPx[i] = -20      ok
		if aPy[i] < -20      aPy[i] = nH + 20  ok
		if aPy[i] > nH + 20  aPy[i] = -20      ok
		aPl[i]--
		if aPl[i] <= 0
			aPx[i] = random(1000) / 1000 * nW
			aPy[i] = random(1000) / 1000 * nH
			aPl[i] = 30 + random(150)
		ok
	next

# Positions are computed here and NOWHERE ELSE. Runs every frame the orrery
# is on screen, INCLUDING while paused (dt = 0) -- a paused scene still has
# to know where its bodies are; it just stops recording history.
func StepOrrery dt
	if aScenes[nScene][1] != :Orrery
		return
	ok
	nB = len(aBodies)
	aPos = []
	aParent = []
	nPx = nCX  nPy = nCY
	for i = 1 to nB
		aParent + [ nPx, nPy ]
		nOrb = aBodies[i][1] * nScale
		nAng = nClock * aBodies[i][2]
		nPx += cos(nAng) * nOrb
		nPy += sin(nAng) * nOrb * 0.55      # tilted, so it reads as an orbit
		aPos + [ nPx, nPy ]
		if dt > 0
			aBodies[i][5] + [ nPx, nPy ]
			if len(aBodies[i][5]) > 260
				del(aBodies[i][5], 1)
			ok
		ok
	next

#-- drawing ----------------------------------------------------------------

func DrawScene
	oCanvas.Clear()
	cKind = aScenes[nScene][1]

	# every scene sits on the same deep vertical wash
	oCanvas.AddGradientRect(0, 0, nW, nH, "#070A14", "#141C33", TRUE)
	if bGrid
		DrawGrid()
	ok

	switch cKind
	on :Flow      DrawFlow()
	on :Harmonic  DrawHarmonograph()
	on :Bloom     DrawBloom()
	on :Orrery    DrawOrrery()
	on :Ribbons   DrawRibbons()
	off

	DrawFrame()

# ---- scene 1: a field of angles made visible ----
func DrawFlow
	nHalo = 7 * nScale
	nCore = 2.4 * nScale
	if nHalo < 2    nHalo = 2    ok
	if nCore < 0.9  nCore = 0.9  ok
	for i = 1 to nParticles
		nH2 = aPh[i] + 1
		# a soft halo under a bright core: two circles is the cheapest glow
		# that still reads as light rather than as a dot
		oCanvas.AddCircleQ(aPx[i], aPy[i], nHalo).
			Fill(StzColorWithAlpha(aPalSoft[nH2], 34))
		oCanvas.AddCircleQ(aPx[i], aPy[i], nCore).Fill(aPal[nH2])
	next

# ---- scene 2: pendulums drawing each other ----
#
# Each curve is ONE polyline of 900 points -- one Ring call for the whole
# figure, which is why this scene is far denser than the particle one and
# costs less.
func DrawHarmonograph
	nCurves = 6
	for c = 1 to nCurves
		nPhase = nClock * 0.11 + c * 0.42
		nF1 = 2 + c * 0.011
		nF2 = 3 + c * 0.014
		nF3 = 2.99 + c * 0.008
		nF4 = 1.99 + c * 0.006
		nDecay = 0.0022 + c * 0.00012

		aPts = []
		for k = 0 to 720
			nT = k * 0.039
			nD = exp(-nDecay * k)
			nX = nCX + (sin(nT * nF1 + nPhase) * 250 +
			            sin(nT * nF2 + nPhase * 1.7) * 115) * nD * nScale
			nY = nCY + (sin(nT * nF3 + nPhase * 0.6) * 160 +
			            sin(nT * nF4 - nPhase) * 78) * nD * nScale
			aPts + nX
			aPts + nY
		next
		nHue = floor((196 + c * 17 + nClock * 9) % 360) + 1
		oCanvas.AddPolylineQ(aPts).
			Stroke(StzColorWithAlpha(aPal[nHue], 120), Wid(1.6))
	next

# ---- scene 3: nested polygons out of phase ----
func DrawBloom
	nRings = 26
	for r = nRings to 1 step -1
		nSides = 3 + (r % 10)
		nRad = (24 + r * 8.6) * nScale        # 26th ring = 248 at scale 1
		# each ring turns at its own rate: the pattern never repeats exactly
		nRot = nClock * (0.45 - r * 0.011) + r * 0.22
		aPts = []
		for s = 0 to nSides - 1
			nA = nRot + s * TWO_PI / nSides
			# breathe: the radius modulates per ring
			nRR = nRad * (1 + 0.055 * sin(nClock * 1.1 + r * 0.5))
			aPts + (nCX + cos(nA) * nRR)
			aPts + (nCY + sin(nA) * nRR * 0.92)
		next
		nHue = floor((r * 13 + nClock * 26) % 360) + 1
		oCanvas.AddPolygonQ(aPts).
			Fill(StzColorWithAlpha(aPalDeep[nHue], 26))
		oCanvas.AddPolygonQ(aPts).
			Stroke(StzColorWithAlpha(aPal[nHue], 165), Wid(1.7))
	next
	# a lit core
	Glow(nCX, nCY, 26 * nScale, floor((nClock * 26) % 360) + 1)

# ---- scene 4: orbits carrying orbits ----
func DrawOrrery
	Glow(nCX, nCY, 34 * nScale, 45)      # the sun
	if len(aPos) = 0
		return
	ok

	nB = len(aBodies)
	for i = 1 to nB
		nOrb = aBodies[i][1] * nScale

		# the orbit this body travels, drawn around its PARENT
		aRing = []
		for s = 0 to 96
			nA = s * TWO_PI / 96
			aRing + (aParent[i][1] + cos(nA) * nOrb)
			aRing + (aParent[i][2] + sin(nA) * nOrb * 0.55)
		next
		oCanvas.AddPolygonQ(aRing).Stroke("#46567F", Wid(1))

		# the trail, fading with age
		nT = len(aBodies[i][5])
		for k = 1 to nT step 2
			nFade = k / nT
			oCanvas.AddCircleQ(aBodies[i][5][k][1], aBodies[i][5][k][2],
					   (1 + 2.5 * nFade) * nScale).
				Fill(StzColorWithAlpha(aPalSoft[aBodies[i][4] + 1],
						      8 + 70 * nFade))
		next

		Glow(aPos[i][1], aPos[i][2], aBodies[i][3] * nScale, aBodies[i][4] + 1)
	next

# ---- scene 5: rose curves under a moving phase ----
func DrawRibbons
	nBands = 9
	for b = 1 to nBands
		nK = 2 + b * 0.5                      # petal count
		nAmp = (42 + b * 21) * nScale         # max 231 at scale 1
		nPhase = nClock * (0.25 + b * 0.045)
		aPts = []
		for s = 0 to 260
			nA = s * TWO_PI / 260
			nR = nAmp * sin(nK * nA + nPhase) +
			     nAmp * 0.55 * sin(nA * 3 - nPhase * 1.3)
			aPts + (nCX + cos(nA) * nR)
			aPts + (nCY + sin(nA) * nR * 0.8)
		next
		# 40 degrees of hue per band spreads the set across a wide arc
		# instead of nine shades of the same green
		nHue = floor((b * 40 + nClock * 14) % 360) + 1
		oCanvas.AddPolylineQ(aPts).
			Stroke(StzColorWithAlpha(aPal[nHue], 95 + b * 8), Wid(2.2))
	next

#-- shared pieces ----------------------------------------------------------

# Four concentric circles of falling alpha. Cheaper than any blur and it
# reads as light because the falloff is what an eye actually looks for.
# r arrives ALREADY SCALED by the caller -- scaling again here would square
# the factor and make every glow vanish on a small window.
func Glow x, y, r, hue
	if r < 1.5  r = 1.5  ok
	oCanvas.AddCircleQ(x, y, r * 2.6).Fill(StzColorWithAlpha(aPalSoft[hue], 16))
	oCanvas.AddCircleQ(x, y, r * 1.8).Fill(StzColorWithAlpha(aPalSoft[hue], 26))
	oCanvas.AddCircleQ(x, y, r * 1.2).Fill(StzColorWithAlpha(aPal[hue], 60))
	oCanvas.AddCircleQ(x, y, r).Fill(aPal[hue])
	oCanvas.AddCircleQ(x, y, r * 0.42).Fill(StzColorMix(aPal[hue], "#FFFFFF", 0.72))

func DrawGrid
	nStep = 55 * nScale
	if nStep < 18  nStep = 18  ok
	for x = 0 to nW step nStep
		oCanvas.AddLineQ(x, 0, x, nDrawH).Stroke("#FFFFFF12", Wid(1))
	next
	for y = 0 to nDrawH step nStep
		oCanvas.AddLineQ(0, y, nW, y).Stroke("#FFFFFF12", Wid(1))
	next

# The caption bar. Text goes through the same shaping pipeline that draws
# Arabic correctly -- a title is just its easiest case.
func DrawFrame
	oCanvas.AddRectQ(0, nDrawH, nW, nBar).Fill("#05070Fdd")
	oCanvas.AddLineQ(0, nDrawH, nW, nDrawH).Stroke("#2A3358", Wid(1))

	nPad = nBar * 0.42
	nDot = nBar / REF_BAR
	if nDot < 0.55  nDot = 0.55  ok

	# Scene ticks, RIGHT-aligned. They used to sit under the title at the
	# left, which worked only because at the reference size the title had
	# no descenders and the bar was tall enough to stack them. At any other
	# size they landed on the text. Opposite ends cannot collide.
	nS = len(aScenes)
	nGap = 20 * nDot
	nTickY = nDrawH + nBar * 0.5
	nTickR = nW - nPad
	for i = 1 to nS
		nBx = nTickR - (nS - i) * nGap
		if i = nScene
			oCanvas.AddCircleQ(nBx, nTickY, 4.6 * nDot).Fill("#E0A030")
		else
			oCanvas.AddCircleQ(nBx, nTickY, 3.2 * nDot).Fill("#3A4870")
		ok
	next
	nTicksLeft = nTickR - (nS - 1) * nGap - 6 * nDot

	# SetFont INSIDE the chain, not before it. With a text shape pending,
	# SetFont retargets THAT shape -- so `SetFont(25); AddText(title);
	# SetFont(14); AddText(sub)` silently gives the title 14 and the
	# subtitle 25. Naming the size in each chain is unambiguous, and it is
	# the form the class documents.
	if isObject(oFont)
		_nTy_ = nDrawH + nBar * 0.66
		_cTitle_ = aScenes[nScene][2]
		_nTw_ = oFont.WidthOf(_cTitle_, nBarFont)
		oCanvas.AddTextQ(_cTitle_, nPad, _nTy_).
			SetFontQ(oFont, nBarFont).Color("#EAF0FF")

		# The subtitle is the first thing to go. Measuring it with the REAL
		# shaped advance -- not an estimate from character count -- is what
		# lets it disappear exactly when it would have overflowed, instead
		# of a guess that either clips or drops it too early.
		_nSx_ = nPad + _nTw_ + nBar * 0.42
		_nSw_ = oFont.WidthOf(aScenes[nScene][3], nBarSub)
		if _nSx_ + _nSw_ < nTicksLeft - nPad
			oCanvas.AddTextQ(aScenes[nScene][3], _nSx_, _nTy_).
				SetFontQ(oFont, nBarSub).Color("#7E8CB0")
		ok
	ok

# A stroke width that stays VISIBLE when the window shrinks. Scaling a
# 1 px line by 0.3 gives a line the rasterizer can barely find, so widths
# scale only part-way and never below one pixel.
func Wid w
	_w_ = w * nScale
	if _w_ < w * 0.6  _w_ = w * 0.6  ok
	if _w_ < 1        _w_ = 1        ok
	return _w_
