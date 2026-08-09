load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GR5 -- A WINDOW IS WHERE A PICTURE IS WATCHED

	Everything before this phase answered ToSVG() or ToPNG(): a picture
	computed once and handed to a file. This guard is about the other half.

	The claim under test is not "a window opens" -- that is the easy part.
	It is that showing a picture and saving one are the SAME RENDERER
	pointed at two destinations, that a frame loop costs no bus traffic
	after its first frame, and that every refusal in the chain is counted
	rather than silent.

	Runs headless-safe: with no windowing this file reports the refusal and
	stops, because a machine that cannot open a window is a supported state,
	not a failure.
---------------------------------------------------------------------------*/

decimals(4)
nOk = 0  nBad = 0

? "=============================================================="
? " GR5 -- windows, input, and presentation"
? "=============================================================="
? ""

#---------------------------------------------------------------------------
? "-- 1. Is there a window tier on this machine at all? ----------"
#
# stz_window.dll is the ONE engine module that cannot be cross-built for
# every OS from a single box (Zig bundles libc, not X11 or Cocoa). So its
# absence is a supported state, and asking is free.
#---------------------------------------------------------------------------

? "engine loaded : " + StzWindowEngineLoaded()
? "windowing     : " + StzWindowingAvailable()
? "gpu device    : " + StzGraphicsDevice()

if NOT StzWindowingAvailable()
	? ""
	? "No windowing here -- and that is a legitimate answer, not a"
	? "failure. Every other graphics tier still works: the SVG tier"
	? "needs no device at all, the PNG tier needs a device but no"
	? "window. Stopping the guard rather than faking a pass."
	? ""
	? "0 checks run."
	return
ok

#---------------------------------------------------------------------------
? ""
? "-- 2. Key names resolve, and a wrong one is REFUSED -----------"
#
# The negative sibling matters more than the positive: a key table that
# answers something for every input would make KeyDown(:Escpae) silently
# read key 0 forever.
#---------------------------------------------------------------------------

chkeq("A is its ASCII code", StzWindowKeyCode(:A), 65)
chkeq("digit 7 likewise", StzWindowKeyCode("7"), 55)
chkeq("Escape", StzWindowKeyCode(:Escape), 256)
chkeq("Left arrow", StzWindowKeyCode(:Left), 263)
chkeq("F1", StzWindowKeyCode(:F1), 290)
chkeq("F12", StzWindowKeyCode(:F12), 301)
chk("a NON-key is refused with -1", StzWindowKeyCode(:Banana) = -1)
chk("and F99 too (out of range)", StzWindowKeyCode(:F99) = -1)

#---------------------------------------------------------------------------
? ""
? "-- 3. A window opens, and reports itself honestly -------------"
#---------------------------------------------------------------------------

oW = new stzWindow(640, 400, "Softanza GR5 guard")

chk("it is open", oW.IsOpen())
chkeq("width as asked", oW.Width(), 640)
chkeq("height as asked", oW.Height(), 400)
chkeq("title remembered", oW.Title(), "Softanza GR5 guard")
chk("no frames drawn yet", oW.FrameCount() = 0)

oW.SetTitleQ("renamed").SetTitle("Softanza GR5 guard")
chkeq("SetTitleQ chains and SetTitle sticks", oW.Title(), "Softanza GR5 guard")

#---------------------------------------------------------------------------
? ""
? "-- 4. Poll samples input, and DeltaTime is a real clock -------"
#
# The trap this catches: a delta that is a constant looks fine in every
# printout and makes every animation frame-rate-dependent. So we do not
# assert "delta > 0" alone -- we assert it DISCRIMINATES, by measuring a
# busy stretch against an idle one.
#---------------------------------------------------------------------------

oW.Poll()
nAcc = 0
for i = 1 to 400000
	nAcc += i
next
oW.Poll()
nBusy = oW.DeltaTime()
oW.Poll()
nIdle = oW.DeltaTime()

? "   busy poll : " + nBusy + " s"
? "   idle poll : " + nIdle + " s"
chk("a busy frame is measurably longer than an idle one", nBusy > nIdle * 5)
chk("FPS follows from the delta", oW.FPS() > 0)

chk("no key is down in a window nobody is typing into", oW.KeyDown(:A) = FALSE)
chk("nor pressed", oW.KeyPressed(:A) = FALSE)
chk("no mouse button is down", oW.MouseDown(1) = FALSE)
chk("mouse position is a pair", len(oW.MousePosition()) = 2)

#---------------------------------------------------------------------------
? ""
? "-- 5. The SAME canvas that saves a file draws to the window ---"
#
# This is the phase's real claim. The canvas below is never told which
# destination it is going to; ToSVG, ToPNG and the window all read the one
# display list, so they cannot disagree about where anything sits.
#---------------------------------------------------------------------------

oC = new stzCanvas(640, 400)
oC.SetBackground(:Black)
oC.AddGradientRect(0, 0, 640, 400, "#1B2A4A", "#0A0F1C", TRUE)
oC.AddCircleQ(320, 200, 110).Fill("#E0A030")
oC.AddRectQ(40, 40, 150, 80).Fill("#30C0A0")
oC.Flush()

cSvg = oC.ToSVG()
chk("the SVG tier answers with no window involved", len(cSvg) > 200)

chk("this window can draw (it has a device and a surface)", oW.CanDraw())
? "   surface format : " + oW.SurfaceFormat()
chk("the format is one the render stack compiles for",
      oW.SurfaceFormat() = "rgba8" or oW.SurfaceFormat() = "bgra8")

nDrawn = 0
for i = 1 to 60
	oW.Poll()
	if NOT oW.IsOpen()
		exit
	ok
	if oW.Draw(oC)
		nDrawn++
	ok
next

chkeq("60 frames asked, 60 frames shown", nDrawn, 60)
chkeq("and the window counted the same", oW.FrameCount(), 60)

aS = oW.Stats()
? "   surface stats  : " + @@(aS)
chkeq("frames presented", aS[3], 60)
chkeq("no reconfigures (nothing resized)", aS[4], 0)
chkeq("no frame still held after present", aS[5], 0)

#---------------------------------------------------------------------------
? ""
? "-- 6. THE POINT: a still frame loop costs nothing on the bus --"
#
# ToPNG drags every pixel back across the bus to encode it. A window
# renders into the screen's own texture and never reads back. The
# difference is not a tuning knob, so the guard measures it rather than
# asserting it.
#---------------------------------------------------------------------------

nBusBefore = StzEngineGpuCounter(2)
for i = 1 to 60
	oW.Poll()
	oW.Draw(oC)
next
nBusFrames = StzEngineGpuCounter(2) - nBusBefore

nOneReadback = 640 * 400 * 4

? "   60 more frames moved : " + nBusFrames + " bytes"
? "   ONE ToPNG readback   : " + nOneReadback + " bytes"
? "   60 ToPNG frames      : " + (nOneReadback * 60) + " bytes"

chk("a still scene re-uploads NOTHING once it is resident", nBusFrames = 0)
chk("which is cheaper than a single offscreen frame's readback",
      nBusFrames < nOneReadback)

aStats = oC.Stats()
? "   canvas stats : " + @@(aStats)
chkeq("tessellated once for 120 frames", aStats[5], 1)
chkeq("uploaded once for 120 frames", aStats[6], 1)

#---------------------------------------------------------------------------
? ""
? "-- 7. An ANIMATED canvas does not grow without bound ----------"
#
# The defect a one-shot renderer can never expose: a frame loop that
# appends shapes forever. Clear() is the fix, and the negative sibling is
# what proves the fix is load-bearing.
#---------------------------------------------------------------------------

oA = new stzCanvas(320, 200)
for i = 1 to 10
	oA.AddCircleQ(i * 20, 100, 15).Fill(:Red)
	oA.Flush()
next
nGrown = oA.ShapeCount()

oA.Clear()
oA.AddCircleQ(50, 100, 15).Fill(:Red)
oA.Flush()
nAfter = oA.ShapeCount()

? "   10 frames without Clear : " + nGrown + " shapes"
? "   after Clear + 1 frame   : " + nAfter + " shapes"
chk("without Clear the list grows every frame", nGrown >= 10)
chkeq("Clear empties it, so a frame loop stays flat", nAfter, 1)

#---------------------------------------------------------------------------
? ""
? "-- 8. A 3D scene reaches the same window ----------------------"
#
# Not a second renderer: the 3D tier draws into the adopted swapchain frame
# through the pass machine that was already there.
#---------------------------------------------------------------------------

oCube = new stzMesh([ :Cube, 1.6 ])
oBall = new stzMesh([ :Sphere, 0.8 ])

oS = new stzScene(640, 400)
oS.SetBackgroundQ("#0B1020").SetCamera(4, 3, 6, 0, 0, 0)
oS.AddMeshQ(oCube, 0, 0, 0).Color("#E0A030")
oS.AddMeshQ(oBall, 2.2, 0, 0).Color("#30C0A0")

n3d = 0
for i = 1 to 30
	oW.Poll()
	if oW.Draw(oS)
		n3d++
	ok
next
chkeq("30 3D frames shown in the same window", n3d, 30)

#---------------------------------------------------------------------------
? ""
? "-- 9. Refusals are counted, never silent ----------------------"
#---------------------------------------------------------------------------

oW.Close()
oW.Poll()
chk("Close() closes it", oW.IsOpen() = FALSE)
chk("a closed window still answers rather than crashing", oW.Width() >= 0)

oW.Free()
chk("a freed window is not open", oW.IsOpen() = FALSE)
chk("and cannot draw", oW.Draw(oC) = FALSE)
chk("its stats are empty rather than stale numbers", len(oW.Stats()) = 0)

# the constructor's negative sibling
bRaised = FALSE
try
	oBad = new stzWindow(0, 400, "nope")
catch
	bRaised = TRUE
done
chk("a zero-width window is REFUSED, not silently resized", bRaised)

bRaised2 = FALSE
try
	oW2 = new stzWindow(200, 150, "keys")
	oW2.KeyDown(:Nonexistent)
	oW2.Free()
catch
	bRaised2 = TRUE
done
chk("an unknown key name is REFUSED, not read as key 0", bRaised2)

#---------------------------------------------------------------------------
? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------
# Ring runs the file top-down until the FIRST func definition and never
# returns, so every helper lives below the last line of the guard.
#---------------------------------------------------------------------------

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

