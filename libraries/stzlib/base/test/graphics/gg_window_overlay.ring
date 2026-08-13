load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	ONE FRAME, TWO PASSES -- a HUD over a 3D scene

	stzWindow.Draw acquires a swapchain frame, draws ONE thing and presents.
	Calling it twice presents twice, and the second frame has already wiped
	the first -- so a HUD was not expressible at all.

	The engine gained a pass that PRESERVES its target (LoadOp.Load rather
	than Clear), the 2D scene gained sceneDrawOverTarget, and the window
	gained DrawXT(thing, overlay): one acquired frame carrying two passes.
	That is the frame graph's idea at the window's own scale.

	The property that matters: after the overlay, BOTH are on the target.
	An overlay that cleared would leave only itself, and would look
	perfectly fine in a screenshot of the panel.

	Run:  ring gg_window_overlay.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " ONE FRAME, TWO PASSES"
? "=============================================================="

if NOT StzGraphicsDevice()
	? "   (no device -- this is entirely a rendered property; UNJUDGED)"
	return
ok

W = 400  H = 300

# a 3D frame: a big sphere filling the middle
oS = new stzScene(W, H)
oS.SetBackgroundQ("#101820").SetCamera(0, 0, 3.4, 0, 0, 0)
oS.SetLight(-0.4, -0.8, -0.4, "#FFFFFF", "#202020")
oS.AddMeshQ(new stzMesh([ :Sphere, 1.5, 32, 24 ]), 0, 0, 0).Color(:Danger)

# a 2D overlay: a panel in the TOP-LEFT only
oH = new stzCanvas(W, H)
oH.SetBackground("#00000000")
oH.Flush()
oH.FillQ(:Success).AddRect(10, 10, 120, 60)

hT = StzEngineGpuTextureNew(W, H, 0)
chk("a render target was made", hT > 0)

chk("the 3D pass drew", StzEngineGpuScene3dDrawToTarget(oS.Id_(), hT, 0, W, H) = 1)
oH.Flush()
chk("the overlay pass drew", StzEngineGpuSceneDrawOverTarget(oH.Id_(), hT, 0, W, H) = 1)

cPx = StzEngineGpuTargetRead(hT)
chk("the target read back", len(cPx) = W * H * 4)

aPanel = _At(cPx, W, 60, 40)      # inside the overlay panel
aBall  = _At(cPx, W, 200, 150)    # the sphere, far from the panel
aWant  = StzHexToRGB(StzResolveColor(:Success))
aBallW = StzHexToRGB(StzResolveColor(:Danger))

? "   panel pixel : " + aPanel[1] + "," + aPanel[2] + "," + aPanel[3] +
  "   wanted :Success " + aWant[1] + "," + aWant[2] + "," + aWant[3]
? "   ball  pixel : " + aBall[1] + "," + aBall[2] + "," + aBall[3] +
  "   the 3D must have SURVIVED"

chk("the overlay landed", _Near(aPanel, aWant, 14))
chk("and the 3D SURVIVED under it -- the pass preserved",
    aBall[1] > 40 and aBall[1] > aBall[3])

# THE NEGATIVE SIBLING: a CLEARING pass in the same place must destroy the
# 3D, or the check above is satisfied by a target nothing ever cleared.
hT2 = StzEngineGpuTextureNew(W, H, 0)
StzEngineGpuScene3dDrawToTarget(oS.Id_(), hT2, 0, W, H)
oH2 = new stzCanvas(W, H)
oH2.SetBackgroundQ("#000000")
oH2.Flush()
oH2.FillQ(:Success).AddRect(10, 10, 120, 60)
oH2.Flush()
StzEngineGpuSceneDrawToTarget(oH2.Id_(), hT2, 0, W, H)
cPx2 = StzEngineGpuTargetRead(hT2)
aBall2 = _At(cPx2, W, 200, 150)
? "   with a CLEARING pass the same pixel is : " +
  aBall2[1] + "," + aBall2[2] + "," + aBall2[3]
chk("a clearing pass DOES destroy it (so the check discriminates)",
    aBall2[1] < 30)

write("gg_window_overlay.png", StzEngineGpuPngEncode(W, H, cPx, 1))
? "   wrote gg_window_overlay.png"

? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func _At cPx, nW, nX, nY
	_i_ = (nY * nW + nX) * 4 + 1
	if _i_ + 2 > len(cPx)  return [ 0, 0, 0 ]  ok
	return [ ascii(substr(cPx, _i_, 1)), ascii(substr(cPx, _i_ + 1, 1)),
	         ascii(substr(cPx, _i_ + 2, 1)) ]

func _Near aGot, aWant, nTol
	return fabs(aGot[1] - aWant[1]) + fabs(aGot[2] - aWant[2]) +
	       fabs(aGot[3] - aWant[3]) <= nTol
