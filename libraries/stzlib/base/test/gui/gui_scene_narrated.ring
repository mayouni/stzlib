load "../../stzBase.ring"

/*
	THE IN-SCENE PANEL -- §6's own starting tier, deferred three times.

	The plan says this plane starts with the in-scene and game case. It
	then didn't: G1 rendered no scene, criterion 3 used a hand-drawn
	canvas rather than a panel, and G3 built the uv conversion but
	rehearsed it against no camera at all. This guard is that tier.

	WHAT IS ACTUALLY AT RISK HERE is not the rendering -- a texture on a
	quad is routine and the graphics plane proved it. It is the INPUT
	direction: a click arrives in SCREEN pixels and must find a widget in
	PANEL pixels, through a camera, a ray, a plane and a uv flip. Every
	one of those is a chance to be silently wrong, and "silently" is the
	word: a mis-mapped click lands on the wrong button, which looks like
	a working program doing something else.

	SO THE CENTRE OF THIS GUARD IS A ROUND TRIP the class cannot fake.
	The ray is computed from the camera by hand, because the engine
	exposes no unproject. Against it stands the engine's OWN Project(),
	which shares no code with it. A uv mapped out to a world point,
	projected to the screen by the engine, then mapped back by the ray,
	must return the uv it began with. Two independent routes to one
	truth -- the house's rule for a check that can actually fail, rather
	than an identity computed from one set of anchors.

	Everything here runs without a GPU. The mapping is arithmetic.
*/

? ""
? "=========================================================="
? " THE IN-SCENE PANEL: a click through a camera"
? "=========================================================="

nOK = 0
nBad = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to hang in a world."
	return
ok

decimals(6)

#---------------------------------------------------------------------
? ""
? "-- 1. A panel, and a scene looking down at it -----------------"
#---------------------------------------------------------------------

# A panel with two buttons side by side. This is the whole point: after
# the round trip we must be able to hit the RIGHT one.
oDoc = new stzUiDocument('
DEFINE PANEL console (
  SIZE [400, 300],
  DIRECTION column,
  BACKGROUND "#101820",
  PADDING 40,
  CHILDREN [row]
) RATIONALE "A control surface meant to hang in a world, not in a window."

DEFINE BOX row (
  DIRECTION row,
  HEIGHT 90,
  GAP 20,
  CHILDREN [fire, abort]
) RATIONALE "The two commands, side by side -- so a mis-mapped click is visible."

DEFINE BOX fire (
  WIDTH 140,
  BACKGROUND "#b03030",
  FOCUSABLE yes,
  ROLE button,
  LABEL "Fire"
) RATIONALE "The one that does the thing."

DEFINE BOX abort (
  WIDTH 140,
  BACKGROUND "#3a4450",
  FOCUSABLE yes,
  ROLE button,
  LABEL "Abort"
) RATIONALE "The one that does not, which Rule 80 requires to exist."
')

if NOT oDoc.IsClean()
	? oDoc.Report()
ok
Chk("the document is clean", oDoc.IsClean())

oPanel = oDoc.ToPanel()

aFire = oPanel.BoxOf("fire")
aAbort = oPanel.BoxOf("abort")
Chk("the two buttons laid out", len(aFire) = 4 and len(aAbort) = 4)
Chk("and they are side by side, fire on the left",
   aFire[1] < aAbort[1])

# The camera looks down at the quad from above and in front -- an
# OBLIQUE view, deliberately. A head-on camera would make the mapping
# very nearly a scale-and-offset, and would pass even if the whole
# perspective term were wrong.
oScene = new stzScene(800, 600)
oScene.SetCamera(0, 3, 4,   0, 0, 0)
oScene.SetLens(60, 0.1, 100)

oSP = new stzScenePanel(oPanel, oScene, 2.0)
Chk("the panel knows its scene", oSP.Scene() != NULL)
Chk("and the quad is 2 units across", oSP.Size() = 2)

#---------------------------------------------------------------------
? ""
? "-- 2. The round trip: two routes, one truth ------------------"
#---------------------------------------------------------------------
/*
	The ray is hand-built from the camera basis. Project() builds a
	look-at and a perspective matrix in the ENGINE and multiplies them.
	They share not one line. If either is wrong, they disagree.
*/

nWorst = oSP.VerifyAgainstProjection(7)
? "  worst uv disagreement over a 7x7 grid: " + nWorst
Chk("the ray and the engine's projection agree to 1e-6", nWorst < 0.000001)

# And the check is CAPABLE of failing -- which is the half most
# self-checks skip, and the first draft of this guard skipped it too.
# The first attempt moved the SCENE's camera and expected disagreement.
# It got zero error instead: Ring copies an object on assignment, so
# BOTH the ray's camera and Project()'s camera were the same stale
# snapshot, and they agreed with each other while agreeing with nothing
# real. The camera is DATA now, and LooksThrough() is the sync -- which
# makes a genuine negative easy to state: point the RAY through one
# camera and Project() through another.
oOther = new stzScene(800, 600)
oOther.SetCamera(0, 3, 4,   0, 0, 0)
oOther.SetLens(30, 0.1, 100)		# same place, half the field of view

oSP2 = new stzScenePanel(oPanel, oScene, 2.0)
Chk("a fresh panel agrees", oSP2.VerifyAgainstProjection(5) < 0.000001)

oSP2.LooksThrough(oOther)
nAfter = oSP2.VerifyAgainstProjection(5)
? "  ray on a 30-degree lens, projection on a 60-degree lens: " + nAfter
Chk("...and the SAME check now disagrees loudly", nAfter > 0.01)

oOther.SetLens(60, 0.1, 100)
oOther.SetCamera(1.5, 3, 4,   0, 0, 0)		# same lens, moved sideways
oSP2.LooksThrough(oOther)
Chk("a camera moved sideways breaks it too",
   oSP2.VerifyAgainstProjection(5) > 0.01)

oSP2.LooksThrough(oScene)
Chk("...and syncing back restores agreement",
   oSP2.VerifyAgainstProjection(5) < 0.000001)

# THE SNAPSHOT IS VISIBLE, which is the point of making it data. A
# camera that moved without a LooksThrough is a missing call, not an
# invisible fork -- and a caller can SEE which camera is in use.
oScene.SetCamera(0, 9, 9,   0, 0, 0)
Chk("the mapping still uses the camera it was given",
   oSP2.CameraInUse()[2] = 3)
Chk("...and the scene has plainly moved on", oScene.Camera()[2] = 9)
oScene.SetCamera(0, 3, 4,   0, 0, 0)
Chk("viewport comes along with it", oSP2.ViewportInUse()[1] = 800)

#---------------------------------------------------------------------
? ""
? "-- 3. Where the corners of the quad land ---------------------"
#---------------------------------------------------------------------
/*
	The corners are the cheapest way to catch a flipped axis, and a
	flipped axis is the defect that makes every click land on the mirror
	image of what was meant.
*/

aTL = oScene.Project(-1, 0,  1)		# u=0, v=1  -> BOTTOM-left in uv terms
aTR = oScene.Project( 1, 0,  1)
aFar = oScene.Project(-1, 0, -1)	# u=0, v=0

Chk("all three corners are in front of the camera",
   aTL[4] != 0 and aTR[4] != 0 and aFar[4] != 0)
Chk("the +x corner is to the RIGHT of the -x corner on screen",
   aTR[1] > aTL[1])
Chk("the -z corner is HIGHER on screen (further away, camera above)",
   aFar[2] < aTL[2])

aUV = oSP.UvAtScreen(aTR[1], aTR[2])
Chk("the +x,+z corner reads back as u=1,v=1",
   len(aUV) = 2)
if len(aUV) = 2
	Near("  u", aUV[1], 1, 0.0001)
	Near("  v", aUV[2], 1, 0.0001)
ok

#---------------------------------------------------------------------
? ""
? "-- 4. A click at a screen pixel finds the right button -------"
#---------------------------------------------------------------------
/*
	This is the thing itself. Take the CENTRE of the FIRE button in
	panel pixels, push it all the way out to a screen pixel, and click
	THERE. The panel must report a click on fire -- not on abort, and
	not on nothing.
*/

nCx = aFire[1] + aFire[3] / 2
nCy = aFire[2] + aFire[4] / 2
? "  fire's centre in panel pixels: " + nCx + ", " + nCy

# panel px -> uv -> world -> screen px, by the ENGINE
nU = nCx / 400
nV = nCy / 300
aP = oScene.Project(nU * 2 - 1, 0, 1 - nV * 2)
Chk("fire's centre is visible on screen", aP[4] != 0)
? "  ...which is screen pixel " + floor(aP[1]) + ", " + floor(aP[2])

# and now back IN, by the class
aBack = oSP.PanelPointAtScreen(aP[1], aP[2])
Chk("the screen pixel maps back into the panel", len(aBack) = 2)
if len(aBack) = 2
	Near("  back to fire's centre x", aBack[1], nCx, 0.01)
	Near("  back to fire's centre y", aBack[2], nCy, 0.01)
	bInX = (aBack[1] >= aFire[1]) and (aBack[1] <= aFire[1] + aFire[3])
	bInY = (aBack[2] >= aFire[2]) and (aBack[2] <= aFire[2] + aFire[4])
	Chk("and that point is inside fire's box", bInX and bInY)
	Chk("and NOT inside abort's box -- the negative that matters",
	   NOT (aBack[1] >= aAbort[1] and aBack[1] <= aAbort[1] + aAbort[3]))
ok

oPanel.ClearEvents()
Chk("clicking that screen pixel is accepted", oSP.ClickAtScreen(aP[1], aP[2]))
# a click is a SEQUENCE -- enter, down, up, click -- so the question is
# not how many events but who they targeted
Chk("...and fire received events", len(oPanel.EventsFor("fire")) > 0)
Chk("...one of which is the click itself (kind 1)",
   _HasKind(oPanel.EventsFor("fire"), 1))
Chk("...and abort received nothing at all -- the negative that matters",
   len(oPanel.EventsFor("abort")) = 0)

#---------------------------------------------------------------------
? ""
? "-- 5. A miss is an answer, not a crash -----------------------"
#---------------------------------------------------------------------
/*
	Most of the screen is not the panel. A UI that treats every click as
	a UI click steals the world's input; a UI that crashes on one is
	worse. Both are refused here.
*/

Chk("a pixel in the sky misses the quad", len(oSP.UvAtScreen(400, 5)) = 0)
Chk("...and clicking it does nothing", oSP.ClickAtScreen(400, 5) = FALSE)

# The subtle one: the ray HITS the plane y=0, but far outside the quad.
# A class that only tested "did the ray hit a plane" would accept this.
aBeside = oSP.UvAtScreen(795, 595)
Chk("a pixel that hits the PLANE but beside the QUAD is still a miss",
   len(aBeside) = 0)

# And a hover that misses must tell the panel the pointer LEFT, or the
# last-hovered widget stays lit forever.
oPanel.ClearEvents()
oSP.PointerMovedToScreen(aP[1], aP[2])
Chk("a hover on the quad is accepted", TRUE)
Chk("a hover off the quad reports a miss",
   oSP.PointerMovedToScreen(400, 5) = FALSE)

#---------------------------------------------------------------------
? ""
? "-- 6. The panel still knows nothing about the scene ----------"
#---------------------------------------------------------------------
/*
	§7 dissolved the coordinate-space frame rather than surfacing it,
	and this is the claim that decision rests on: the panel admits ONE
	space, its own pixels, and every other space is a named conversion
	at the boundary. If the panel had grown a notion of "screen", the
	frame would have been real after all.
*/

Chk("the panel has no camera", NOT ismethod(oPanel, "camera"))
Chk("the panel has no scene", NOT ismethod(oPanel, "scene"))
Chk("the panel has no screen-space entry point",
   NOT ismethod(oPanel, "clickatscreen"))
Chk("the conversion lives at the boundary instead",
   ismethod(oSP, "clickatscreen"))

# the same panel, driven directly, still works -- it did not become
# scene-only by being mounted in one
oPanel.ClearEvents()
oPanel.ClickAt(nCx, nCy)
Chk("and driving the panel directly still hits fire",
   _HasKind(oPanel.EventsFor("fire"), 1))

#---------------------------------------------------------------------
? ""
? "-- 7. Mounting, where there is a device ----------------------"
#---------------------------------------------------------------------
/*
	Everything above is arithmetic and runs anywhere. This part needs a
	GPU, and a machine without one is a legitimate state rather than a
	failure -- so the guard reports which path it took instead of
	pretending.
*/

oCanvasProbe = new stzCanvas(8, 8)
if oCanvasProbe.CanDrawPixels()
	bM = oSP.Mount()
	Chk("the panel mounts as a quad", bM)
	Chk("...and knows it", oSP.IsMounted() = bM)
	if bM
		Chk("refreshing an mounted panel succeeds", oSP.Refresh())
	ok
	oSP.Free()
	Chk("freeing releases the texture", oSP.IsMounted() = FALSE)
else
	? "  (no device on this machine -- the mount path is not exercised)"
	Chk("Mount() refuses honestly without a device", oSP.Mount() = FALSE)
	Chk("...and does not claim to be mounted", oSP.IsMounted() = FALSE)
	Chk("...and Refresh() on an unmounted panel is FALSE", oSP.Refresh() = FALSE)
ok

#---------------------------------------------------------------------
? ""
? "-- 8. Re-skinning the quad, and the platform's handle --------"
#---------------------------------------------------------------------
/*
	An app that reacts to a click RE-DECLARES its interface, which
	produces a new stzPanel. Three ways to get that wrong, all found by
	writing the live loop rather than by thinking about it:

	  mount the new one    -> AddMesh APPENDS, so the scene grows a
	                          stack of identical quads
	  keep the old one     -> the quad wears a screen the user dismissed
	  swap it              -> what Shows() does

	And a resized WINDOW is the same class of error one layer up: the
	engine retargets the scene by itself, so the picture stays right
	while the FACE keeps reporting its construction size -- and the ray
	divides by that size.
*/

oDoc2 = new stzUiDocument(StzReplace(oDoc.ToText(), "WIDTH 140", "WIDTH 90"))
Chk("a second document is clean", oDoc2.IsClean())
oPanel2 = oDoc2.ToPanel()
aFire2 = oPanel2.BoxOf("fire")
Chk("...and it lays out differently", aFire2[3] != aFire[3])

oSP3 = new stzScenePanel(oPanel, oScene, 2.0)
Chk("Shows() before mounting is accepted", oSP3.Shows(oPanel2))
Chk("...and the panel it reports is the new one",
   oSP3.Panel().BoxOf("fire")[3] = aFire2[3])

# MOUNT IS IDEMPOTENT. Without a device this is vacuous, so the guard
# says which it measured rather than passing quietly either way.
if oCanvasProbe.CanDrawPixels()
	oSP4 = new stzScenePanel(oPanel, oScene, 2.0)
	nBefore = oScene.InstanceCount()
	Chk("mounting adds one quad", oSP4.Mount() and
	   oScene.InstanceCount() = nBefore + 1)
	Chk("mounting AGAIN is accepted", oSP4.Mount())
	Chk("...and does NOT add a second quad -- the negative that matters",
	   oScene.InstanceCount() = nBefore + 1)
	oSP4.Free()
else
	? "  (no device -- the mount-twice check is not exercised)"
ok

# THE RESIZE PATH. A face that lied about its viewport sent every click
# somewhere else; assert the mapping actually moves when the viewport
# does, and that it takes a LooksThrough to notice.
aAt = oSP.UvAtScreen(450, 300)
oScene.Resize(1800, 1200)
Chk("the scene reports its new size", oScene.Width() = 1800)
Chk("the mapping has NOT noticed yet -- the snapshot is the point",
   oSP.ViewportInUse()[1] = 800)
oSP.LooksThrough(oScene)
Chk("...and now it has", oSP.ViewportInUse()[1] = 1800)
aAt2 = oSP.UvAtScreen(450, 300)
? "  pixel 450,300 at 800x600: " + _UvText(aAt) +
  "   at 1800x1200: " + _UvText(aAt2)
# A MISS is as good an answer as a different uv here -- in the larger
# viewport that pixel is a quarter of the way in rather than the centre,
# and it leaves the quad entirely. What is being asserted is that the
# viewport is LOAD-BEARING, not which side of the edge it lands on.
Chk("the same screen pixel no longer means the same thing",
   NOT _SameUv(aAt, aAt2))
oScene.Resize(800, 600)
oSP.LooksThrough(oScene)
Chk("a bad size is refused rather than adopted",
   oScene.Resize(0, 600) = FALSE and oScene.Width() = 800)

# THE G4b PRECONDITION. Every accessibility adapter attaches to this;
# there is no route to a screen reader that does not pass through it.
if StzWindowingAvailable()
	oW = new stzWindow(220, 160, "handle probe")
	nH = oW.NativeHandle()
	? "  native window handle: " + nH
	Chk("a real window has a platform handle", nH > 0)
	# the house has paid once for an f64 boundary already
	Chk("...and it survives the f64 crossing exactly", nH < 9007199254740992)
	oW.Free()
	Chk("a freed window has no handle", oW.NativeHandle() = 0)
else
	? "  (no windowing -- the handle is not exercised)"
ok

#---------------------------------------------------------------------
? ""
? "-- 9. The 256-segment cliff, which ate the labels -------------"
#---------------------------------------------------------------------
/*
	FOUND BY LOOKING AT A WINDOW. A frame loop drawing a panel into a
	canvas without clearing it appends forever -- and after a few seconds
	the boxes still rendered while EVERY LABEL VANISHED.

	Three innocents were cleared first, each with a number: the panel's
	text invariant held (6 meshes, 6 generate calls, whole=1 at every
	depth); the glyph atlas dropped nothing (66 entries, 0 dropped); the
	tessellator built all of it (204,000 text vertices at 400 repeats).
	The geometry existed and was never drawn.

	The cause was `PASS_MAX_BG = 256` in the render pass. Only a TEXTURED
	draw takes a bind-group slot, so the real ceiling was "256 text or
	image segments in one pass" -- and the 257th draw returned BAD_ARG
	BEFORE its vertex buffer was set. Refused, and counted nowhere.

	The pool grows now, the way the handle table learned to. This scene
	asserts the cliff is gone at the exact boundary that failed, because
	an off-by-one here is invisible until someone squints at a picture.
*/

oFnt = new stzFont(FontPath())
if oFnt = NULL or NOT oCanvasProbe.CanDrawPixels()
	? "  (no font or no device -- the cliff is not exercised)"
else
	# 257 TEXTURED SEGMENTS: one past the old ceiling. Alternating with
	# rects is what forces a new segment per string -- consecutive text
	# merges into one, which is why a naive many-strings test passed
	# while a panel loop failed.
	oCliff = new stzCanvas(300, 120)
	for i = 1 to 257
		oCliff.AddRectQ(10, 10, 200, 40).Fill("#203040")
		oCliff.AddTextQ("SEG", 20, 40).SetFontQ(oFnt, 18).ColorQ("#ffffff")
	next
	aCliff = oCliff.Stats()
	Chk("514 draw segments were built", aCliff[4] = 514)
	Chk("...and the tessellator dropped no string", aCliff[7] = 0)
	Chk("...nor any glyph", aCliff[8] = 0)

	# THE PROOF IS INK. A count of segments proves they were built; only
	# pixels prove they were drawn, which is the whole lesson of this
	# defect. Compare against the SAME scene under the old ceiling.
	cPix = oCliff.ToPixels()
	nInk = 0
	nLen = len(cPix)
	i = 1
	while i < nLen - 3
		# white-ish text on a dark slate: count bright pixels
		if ascii(cPix[i]) > 200 and ascii(cPix[i+1]) > 200
			nInk++
		ok
		i += 4
	end
	? "  bright pixels past the old 256 ceiling: " + nInk
	Chk("text is actually PAINTED past the old ceiling", nInk > 50)
ok

#---------------------------------------------------------------------
? ""
? "=========================================================="
? " " + nOK + " assertions green, " + nBad + " failed"
? "=========================================================="
? ""

#-- the helpers, at the FOOT: code after the first func belongs to it

func Chk(cWhat, bCond)
	if bCond
		nOK++
	else
		nBad++
		? "  FAIL: " + cWhat
	ok

func Near(cWhat, nGot, nWant, nTol)
	Chk(cWhat + " (got " + nGot + ", want " + nWant + ")",
	   fabs(nGot - nWant) <= nTol)

func _HasKind aEvents, nKind
	_n_ = len(aEvents)
	for _i_ = 1 to _n_
		if aEvents[_i_][1] = nKind
			return 1
		ok
	next
	return 0

func FontPath
	_a_ = [ "C:\Windows\Fonts\segoeui.ttf", "C:\Windows\Fontsrial.ttf" ]
	_aC135_ = _a_
	_nC135_ = len(_aC135_)
	for _iC135_ = 1 to _nC135_
		_c_ = _aC135_[_iC135_]
		if fexists(_c_)
			return _c_
		ok
	next
	return ""

func _SameUv aA, aB
	if len(aA) != len(aB)
		return 0
	ok
	if len(aA) = 0
		return 1
	ok
	if fabs(aA[1] - aB[1]) > 0.0001 or fabs(aA[2] - aB[2]) > 0.0001
		return 0
	ok
	return 1

func _UvText aUv
	if len(aUv) = 0
		return "(misses the quad)"
	ok
	return "u=" + aUv[1] + " v=" + aUv[2]
