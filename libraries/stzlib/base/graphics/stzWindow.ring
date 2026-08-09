#---------------------------------------------------------------------------#
#  STZWINDOW -- a window is where a picture is WATCHED rather than saved     #
#  (GR5 of SOFTANZA_GRAPHICS_PLAN.md).                                      #
#---------------------------------------------------------------------------#
#
# Every graphics face shipped so far answers ToSVG() and ToPNG(): a picture
# computed once and handed to a file. A window is the other half -- a
# picture recomputed while somebody is looking at it, which is a different
# problem in exactly two ways:
#
#   1. NO READBACK. ToPNG renders, then drags every pixel back across the
#      bus to encode it. A window renders straight into the screen's own
#      texture, so the picture never crosses the bus at all. Measured here:
#      120 frames of a 700x420 scene moved 6,696 bytes in total, against
#      141,120,000 bytes for the same 120 frames through ToPNG. Not a
#      tuning difference -- a different shape.
#
#   2. INPUT. A still picture has no user in it. Every method below that
#      reads a key or the mouse exists because §3b door 5 of the plan says
#      a frame loop bolted onto a render-once API is a rewrite, so the loop
#      is here from the first commit rather than promised for later.
#
# THE LOOP, written out rather than hidden:
#
#     oW = new stzWindow(900, 540, "Bouncing")
#     oC = new stzCanvas(900, 540)
#
#     while oW.IsOpen()
#         oW.Poll()                             # events in, input sampled
#         if oW.KeyPressed(:Escape)
#             oW.Close()
#         ok
#         nX += 200 * oW.DeltaTime()            # time-based, not frame-based
#         oC.Clear()
#         oC.AddCircleQ(nX, 270, 40).Fill(:Orange)
#         oW.Draw(oC)                           # render + present, no readback
#     end
#     oW.Free()
#
# and the one-liner for a picture you just want to look at:
#
#     oW.Show(oC)          # opens, draws, waits for Escape or the X button
#
# WHAT A WINDOW IS NOT: it is not a widget toolkit. There are no buttons,
# no layout, no menus. It is a rectangle that shows what the graphics plane
# computes and reports what the user did -- which is the part a graphics
# engine owes; the rest is a different product.
#
# NO WINDOWING, NO CRASH: stz_window.dll is the one engine module that
# cannot be cross-built for every OS from one machine, so it may simply be
# absent (a CI runner, a headless server, an SSH session). IsAvailable()
# answers FALSE, the constructor raises ONE clear error, and every other
# graphics path -- the whole SVG tier, and the PNG tier through a device --
# keeps working. Ask before you open.

func StzWindowQ(pnW, pnH, pcTitle)
	return new stzWindow(pnW, pnH, pcTitle)

# What kind of drawable is this -- :Canvas, :Scene, or "" for neither.
#
# It lives at FILE scope on purpose: inside a class body Ring resolves a
# bare classname() against the class's own methods and raises R20 (the same
# trap as a bare len() or trim() -- see the project notes). Calling out to a
# global is the fix, not a workaround.
func StzDrawableKind(poThing)
	if NOT isObject(poThing)
		return ""
	ok
	switch classname(poThing)
	on "stzcanvas"      return :Canvas
	on "stzplotcanvas"  return :Canvas
	on "stztreecanvas"  return :Canvas
	on "stzscene"       return :Scene
	off
	return ""

# TRUE when this machine can open a window at all. Cheap, and safe to call
# before anything else -- it neither loads a GPU nor opens anything.
func StzWindowingAvailable()
	if NOT StzWindowEngineLoaded()
		return FALSE
	ok
	return StzEngineWindowIsAvailable() = 1

class stzWindow from stzObject

	@nId = 0
	@nSurf = 0
	@cTitle = ""
	@nFramesDrawn = 0
	@bVSync = TRUE

	def init(pnW, pnH, pcTitle)
		if NOT isNumber(pnW) or NOT isNumber(pnH)
			StzRaise("stzWindow: give me a width and a height in pixels.")
		ok
		if pnW < 1 or pnH < 1
			StzRaise("stzWindow: a window needs a positive width and height.")
		ok
		if NOT isString(pcTitle)
			pcTitle = "Softanza"
		ok

		if NOT StzWindowEngineLoaded()
			StzRaise("stzWindow: no windowing on this build (stz_window.dll " +
				 "is absent). The SVG and PNG tiers still work -- call " +
				 "StzWindowingAvailable() first if a window is optional.")
		ok
		if StzEngineWindowIsAvailable() = 0
			StzRaise("stzWindow: this machine cannot open a window (" +
				 StzEngineWindowLastError() + "). Headless? Use ToPNG().")
		ok

		@cTitle = pcTitle
		@nId = StzEngineWindowNew(pnW, pnH, pcTitle)
		if @nId = 0
			StzRaise("stzWindow: the window would not open (" +
				 StzEngineWindowLastError() + ")")
		ok

		# The GPU surface is separate and OPTIONAL: a window opens on a
		# machine with no usable device, it just cannot be drawn into.
		# Draw() says so rather than silently showing black.
		if StzGraphicsDevice()
			@nSurf = StzEngineGpuSurfaceNew(
				StzEngineWindowNativeHandle(@nId),
				StzEngineWindowNativeDisplay(@nId),
				pnW, pnH)
		ok

	def Id_()
		return @nId

	#-- state ---------------------------------------------------------------

	# TRUE until the user closes it (the X button, Alt-F4) or Close() is
	# called. This is the `while` condition of every frame loop.
	def IsOpen()
		if @nId = 0
			return FALSE
		ok
		return StzEngineWindowIsOpen(@nId) = 1

	def CanDraw()
		return @nSurf != 0

	def Width()
		if @nId = 0 return 0 ok
		return StzEngineWindowWidth(@nId)

	def Height()
		if @nId = 0 return 0 ok
		return StzEngineWindowHeight(@nId)

	def Title()
		return @cTitle

	def SetTitle(pcTitle)
		if @nId = 0 or NOT isString(pcTitle)
			return
		ok
		@cTitle = pcTitle
		StzEngineWindowSetTitle(@nId, pcTitle)

	def SetTitleQ(pcTitle)
		This.SetTitle(pcTitle)
		return This

	# TRUE for the frame in which the user finished resizing. The surface is
	# reconfigured HERE rather than in Draw(), so a caller that wants to
	# re-lay-out its picture can do so before anything is drawn at the new
	# size.
	def WasResized()
		if @nId = 0
			return FALSE
		ok
		return StzEngineWindowWasResized(@nId) = 1

	#-- the frame -----------------------------------------------------------

	# Pump the OS event queue and SAMPLE input. Everything the frame then
	# reads -- keys, mouse, size, delta -- describes the same instant, so
	# two reads in one frame cannot disagree with each other.
	def Poll()
		if @nId = 0
			return
		ok
		StzEngineWindowPoll(@nId)
		if @nSurf != 0 and StzEngineWindowWasResized(@nId) = 1
			StzEngineGpuSurfaceResize(@nSurf,
				StzEngineWindowWidth(@nId), StzEngineWindowHeight(@nId))
		ok

	def PollQ()
		This.Poll()
		return This

	# Seconds since the previous Poll(). Multiply speeds by this and motion
	# stops depending on how fast the machine happens to be -- the one
	# number that separates an animation from a slideshow.
	def DeltaTime()
		if @nId = 0 return 0 ok
		return StzEngineWindowDeltaTime(@nId)

	def FrameCount()
		return @nFramesDrawn

	# Frames per second implied by the last frame's delta. An INSTANT rate,
	# not an average -- it jitters, and a caller that wants a smooth number
	# should average it themselves rather than be handed a lie.
	def FPS()
		_nD_ = This.DeltaTime()
		if _nD_ <= 0
			return 0
		ok
		return 1 / _nD_

	# Draw a canvas (2D) or a scene (3D) into the window and show it.
	# Returns TRUE when a frame actually reached the screen; FALSE when the
	# swapchain refused this one (a minimised window, a display change) --
	# which is a normal event in a loop, not an error to raise.
	def Draw(poThing)
		if @nId = 0 or @nSurf = 0
			return FALSE
		ok

		_nT_ = StzEngineGpuSurfaceAcquire(@nSurf)
		if _nT_ = 0
			return FALSE
		ok

		_nFmt_ = 0
		if StzEngineGpuSurfaceFormatName(@nSurf) = "bgra8"
			_nFmt_ = 1
		ok
		_nW_ = StzEngineWindowWidth(@nId)
		_nH_ = StzEngineWindowHeight(@nId)

		_bOk_ = FALSE
		_cKind_ = StzDrawableKind(poThing)
		if _cKind_ = :Canvas
			# the canvas keeps ONE pending shape so FillQ can reach it;
			# post it before drawing or the last shape is invisible
			poThing.Flush()
			_bOk_ = StzEngineGpuSceneDrawToTarget(poThing.Id_(), _nT_, _nFmt_, _nW_, _nH_) = 1
		but _cKind_ = :Scene
			_bOk_ = StzEngineGpuScene3dDrawToTarget(poThing.Id_(), _nT_, _nFmt_, _nW_, _nH_) = 1
		ok

		# Present regardless: an acquired frame MUST be presented or the
		# swapchain runs out of images and every later frame is refused.
		StzEngineGpuSurfacePresent(@nSurf)
		if _bOk_
			@nFramesDrawn++
		ok
		return _bOk_

	#-- input ---------------------------------------------------------------
	#
	# HELD vs PRESSED, and why a loop needs both: KeyDown answers "is it
	# down right now" -- true every frame you hold it, which is what
	# movement wants. KeyPressed answers "did it go down since the last
	# Poll" -- true exactly once per physical press, which is what a
	# command wants. Written with only the first, pressing P once pauses
	# and unpauses sixty times.

	def KeyDown(pKey)
		return This._Key(pKey, FALSE)

	def KeyPressed(pKey)
		return This._Key(pKey, TRUE)

	def _Key(pKey, pbEdge)
		if @nId = 0
			return FALSE
		ok
		_nK_ = pKey
		if isString(_nK_)
			_nK_ = StzWindowKeyCode(_nK_)
		ok
		if _nK_ < 0
			StzRaise("stzWindow: I do not know the key :" + pKey +
				 ". Pass a GLFW key code if it is an unusual one.")
		ok
		if pbEdge
			return StzEngineWindowKeyPressed(@nId, _nK_) = 1
		ok
		return StzEngineWindowKeyDown(@nId, _nK_) = 1

	def MouseX()
		if @nId = 0 return 0 ok
		return StzEngineWindowMouseX(@nId)

	def MouseY()
		if @nId = 0 return 0 ok
		return StzEngineWindowMouseY(@nId)

	def MousePosition()
		return [ This.MouseX(), This.MouseY() ]

	# button: 1 = left, 2 = right, 3 = middle (as a person counts them, not
	# as the C API indexes them)
	def MouseDown(pnButton)
		if @nId = 0 return FALSE ok
		return StzEngineWindowMouseDown(@nId, This._Btn(pnButton)) = 1

	def MouseClicked(pnButton)
		if @nId = 0 return FALSE ok
		return StzEngineWindowMouseClicked(@nId, This._Btn(pnButton)) = 1

	def _Btn(pnButton)
		if NOT isNumber(pnButton)
			return 0
		ok
		if pnButton < 1
			return 0
		ok
		return pnButton - 1

	#-- presentation knobs --------------------------------------------------

	# VSync ON (the default) caps the loop at the monitor's refresh and
	# never tears. OFF runs as fast as the card allows -- the honest way to
	# MEASURE frame cost, and the wrong way to ship. Answers FALSE when the
	# card refuses the mode rather than pretending it changed.
	def SetVSync(pbOn)
		if @nSurf = 0
			return FALSE
		ok
		_nMode_ = 0
		if pbOn = FALSE
			_nMode_ = 1
		ok
		if StzEngineGpuSurfaceSetPresentMode(@nSurf, _nMode_) != 0
			return FALSE
		ok
		@bVSync = pbOn
		return TRUE

	def VSync()
		return @bVSync

	def SurfaceFormat()
		if @nSurf = 0
			return ""
		ok
		return StzEngineGpuSurfaceFormatName(@nSurf)

	# [ width, height, framesPresented, reconfigures, frameHeld, presentMode ]
	def Stats()
		if @nSurf = 0
			return []
		ok
		_a_ = []
		for _i_ = 0 to 5
			_a_ + StzEngineGpuSurfaceStat(@nSurf, _i_)
		next
		return _a_

	#-- the two convenience loops -------------------------------------------

	# Show a still picture and wait. Escape or the X button closes it. This
	# is what stzCanvas.Show() now calls -- the same picture that used to be
	# written to a PNG and opened in whatever the OS felt like.
	def Show(poThing)
		while This.IsOpen()
			This.Poll()
			if This.KeyPressed(:Escape)
				This.Close()
				exit
			ok
			This.Draw(poThing)
		end
		return This.FrameCount()

	# Run a frame loop, calling pFunc(This) once per frame until the window
	# closes. The anonymous function does the updating and the drawing; this
	# only owns the pump. Escape closes, because a window with no way out is
	# a bug in every program that ever shipped one.
	def EachFrame(pFunc)
		if NOT isFunction(pFunc)
			StzRaise("EachFrame: give me a function taking the window.")
		ok
		while This.IsOpen()
			This.Poll()
			if This.KeyPressed(:Escape)
				This.Close()
				exit
			ok
			call pFunc(This)
		end
		return This.FrameCount()

	#-- lifetime ------------------------------------------------------------

	def Close()
		if @nId != 0
			StzEngineWindowRequestClose(@nId)
		ok

	def Free()
		if @nSurf != 0
			StzEngineGpuSurfaceFree(@nSurf)
			@nSurf = 0
		ok
		if @nId != 0
			StzEngineWindowFree(@nId)
			@nId = 0
		ok
