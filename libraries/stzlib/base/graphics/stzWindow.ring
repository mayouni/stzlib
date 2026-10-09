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
		return 0
	ok
	return StzEngineWindowIsAvailable() = 1

# Opens a window where a canvas or a 3D scene is watched live, with a frame loop, keys, mouse and time built in.
#
# A picture saved with ToSVG or ToPNG is computed once; a window recomputes it while somebody looks,
# and it reports what the user did. The loop is explicit: while IsOpen, call Poll, read DeltaTime,
# KeyPressed or the mouse, update the picture, and call Draw. The picture goes to the screen's own
# texture, so no pixels travel back across the bus. Show does the whole loop for a still picture,
# and EachFrame runs a function once per frame. It is not a widget toolkit: it has no buttons,
# layout or menus. The windowing module may be absent on a headless machine, in which case building
# a window raises one clear error; ask StzWindowingAvailable() first, and call Free when done. This
# block has no run example because a window needs a screen.
#
#   receiver   o1 = new stzWindow(320, 200, "Demo")
#   see        stzCanvas, stzScene, StzWindowingAvailable, StzDrawableKind
class stzWindow from stzObject

	@nId = 0
	@nSurf = 0
	@cTitle = ""
	@nFramesDrawn = 0
	@bVSync = 1

	# Opens a window of the given size and title on the screen, and prepares a drawing surface on it when a graphics device exists.
	#
	#   pnW        the width in pixels, at least 1
	#   pnH        the height in pixels, at least 1
	#   pcTitle    the title text, and Softanza when it is not a text
	#   returns    nothing; the object is built
	#   note       without a graphics device the window opens but CanDraw is 0 and Draw does nothing
	#   warning    Raises an error when the width or height is not a positive number, when this
	#              build has no windowing (the windowing module is absent) and when the machine
	#              cannot open a window, such as a headless one; ask StzWindowingAvailable first
	#              when a window is optional
	#   see        StzWindowingAvailable, Draw, Free
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

	# Returns the engine's number for this window, or 0 when it was freed.
	#
	#   returns    a number
	#   see        NativeHandle, Free
	def Id_()
		return @nId

	# Returns the operating system's own handle of the window, which accessibility tools attach to.
	#
	#   returns    a number: the window handle on Windows, the window object on macOS, the window id
	#              on Linux; 0 once freed
	#   note       it crosses as a floating-point number, exact up to 2 to the power 53
	#   see        NativeDisplay
	#@ aka  -- the platform's own handle -------------------------------------------
	def NativeHandle()
		if @nId = 0
			return 0
		ok
		return StzEngineWindowNativeHandle(@nId)

	# Returns the X11 display pointer that accessibility tools need beside the window id.
	#
	#   returns    a number; 0 on Windows and macOS and once freed
	#   see        NativeHandle
	#@ aka  The X11 Display pointer, which AT-SPI needs alongside the window id. 0 on Windows and macOS, where the handle alone is the whole address.
	def NativeDisplay()
		if @nId = 0
			return 0
		ok
		return StzEngineWindowNativeDisplay(@nId)

	# TRUE if the window is still open, which holds until the user closes it or Close is called, so it is the condition of a frame loop.
	#
	#   returns    1 or 0; 0 once freed
	#   see        Close, Poll
	#@ aka  -- state ---------------------------------------------------------------
	def IsOpen()
		if @nId = 0
			return 0
		ok
		return StzEngineWindowIsOpen(@nId) = 1

	# TRUE if the window has a drawing surface, which needs a usable graphics device.
	#
	#   returns    1 or 0
	#   see        Draw, init
	def CanDraw()
		return @nSurf != 0

	# Returns the current width of the window in pixels.
	#
	#   returns    a number; 0 once freed
	#   see        Height, SetSize
	def Width()
		if @nId = 0 return 0 ok
		return StzEngineWindowWidth(@nId)

	# Returns the current height of the window in pixels.
	#
	#   returns    a number; 0 once freed
	#   see        Width, SetSize
	def Height()
		if @nId = 0 return 0 ok
		return StzEngineWindowHeight(@nId)

	# Returns the title the window was given or last set.
	#
	#   returns    a text
	#   see        SetTitle
	def Title()
		return @cTitle

	# Changes the title shown on the window.
	#
	#   pcTitle    the new title as text
	#   returns    nothing; SetTitleQ returns the window for chaining
	#   warning    ignored when the window was freed or the title is not a text
	#   see        Title
	def SetTitle(pcTitle)
		if @nId = 0 or NOT isString(pcTitle)
			return
		ok
		@cTitle = pcTitle
		StzEngineWindowSetTitle(@nId, pcTitle)

	def SetTitleQ(pcTitle)
		This.SetTitle(pcTitle)
		return This

	# Asks the window to take a new size, which lands at the next Poll and reconfigures the surface there.
	#
	#   pnW        the new width in pixels
	#   pnH        the new height in pixels
	#   returns    1 when the request was accepted, 0 when refused or ignored; SetSizeQ returns the
	#              window
	#   note       it drives the same path as dragging an edge
	#   warning    raises an error for a width or height below 1; numbers that are not numbers are
	#              ignored
	#   see        WasResized, Poll
	#@ aka  Resize from code. The size lands at the next Poll(), which is also where the swapchain reconfigures -- so this drives exactly the path a dragged window edge drives, and that is why it exists: without it the resize path could only ever be tested by a person with a mouse.
	def SetSize(pnW, pnH)
		if @nId = 0 or NOT (isNumber(pnW) and isNumber(pnH))
			return 0
		ok
		if pnW < 1 or pnH < 1
			StzRaise("stzWindow.SetSize: a window needs a positive size.")
		ok
		return StzEngineWindowSetSize(@nId, pnW, pnH) = 0

	def SetSizeQ(pnW, pnH)
		This.SetSize(pnW, pnH)
		return This

	# TRUE if the size changed during the last frame, so the picture can be laid out again before drawing.
	#
	#   returns    1 or 0
	#   see        SetSize, Poll
	#@ aka  TRUE for the frame in which the user finished resizing. The surface is reconfigured HERE rather than in Draw(), so a caller that wants to re-lay-out its picture can do so before anything is drawn at the new size.
	def WasResized()
		if @nId = 0
			return 0
		ok
		return StzEngineWindowWasResized(@nId) = 1

	# Reads the pending events and samples the keys, the mouse, the size and the time of this frame, and reconfigures the surface after a resize.
	#
	#   returns    nothing; PollQ returns the window
	#   note       call it once at the top of every frame so that all reads describe the same
	#              instant
	#   see        DeltaTime, KeyPressed, IsOpen
	#@ aka  -- the frame -----------------------------------------------------------
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

	# Returns the seconds that passed between the last two Poll calls, the number to multiply speeds by.
	#
	#   returns    a number of seconds; 0 once freed
	#   see        FPS, Poll
	#@ aka  Seconds since the previous Poll(). Multiply speeds by this and motion stops depending on how fast the machine happens to be -- the one number that separates an animation from a slideshow.
	def DeltaTime()
		if @nId = 0 return 0 ok
		return StzEngineWindowDeltaTime(@nId)

	# Returns how many frames Draw has put on the screen so far.
	#
	#   returns    a number
	#   see        Draw, FPS
	def FrameCount()
		return @nFramesDrawn

	# Returns the frame rate implied by the last frame alone, one divided by DeltaTime.
	#
	#   returns    a number; 0 when no time has passed
	#   note       it is an instant rate that jitters; average it for a steady figure
	#   see        DeltaTime
	#@ aka  Frames per second implied by the last frame's delta. An INSTANT rate, not an average -- it jitters, and a caller that wants a smooth number should average it themselves rather than be handed a lie.
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
	# ONE FRAME, TWO PASSES: draw poThing, then draw poOverlay ON TOP of it
	# without clearing, then present. This is what a HUD needs -- the plain
	# Draw acquires, draws and presents, so calling it twice would present
	# twice and the second frame would have wiped the first.
	#
	# It is the frame graph's idea at the window's own scale: an acquired
	# frame can carry more than one pass.
	def DrawXT(poThing, poOverlay)
		if @nId = 0 or @nSurf = 0
			return 0
		ok
		_nT_ = StzEngineGpuSurfaceAcquire(@nSurf)
		if _nT_ = 0
			return 0
		ok
		_nFmt_ = 0
		if StzEngineGpuSurfaceFormatName(@nSurf) = "bgra8"
			_nFmt_ = 1
		ok
		_nW_ = StzEngineWindowWidth(@nId)
		_nH_ = StzEngineWindowHeight(@nId)

		_bOk_ = 0
		_cKind_ = StzDrawableKind(poThing)
		if _cKind_ = :Canvas
			if poThing.Width() != _nW_ or poThing.Height() != _nH_
				poThing.Resize(_nW_, _nH_)
			ok
			poThing.Flush()
			_bOk_ = StzEngineGpuSceneDrawToTarget(poThing.Id_(), _nT_, _nFmt_, _nW_, _nH_) = 1
		but _cKind_ = :Scene
			# Same reason as the canvas above, and it was missing here.
			# The engine retargets a 3D scene by itself, so the picture
			# was always right -- but the FACE went on reporting its
			# construction size, and both `Project()` and the GUI plane's
			# in-scene raycast divide by it. In a resized window every
			# click would land somewhere else, silently.
			if poThing.Width() != _nW_ or poThing.Height() != _nH_
				poThing.Resize(_nW_, _nH_)
			ok
			_bOk_ = StzEngineGpuScene3dDrawToTarget(poThing.Id_(), _nT_, _nFmt_, _nW_, _nH_) = 1
		ok

		# the overlay is a CANVAS, drawn over whatever landed above
		if isObject(poOverlay) and StzDrawableKind(poOverlay) = :Canvas
			if poOverlay.Width() != _nW_ or poOverlay.Height() != _nH_
				poOverlay.Resize(_nW_, _nH_)
			ok
			poOverlay.Flush()
			StzEngineGpuSceneDrawOverTarget(poOverlay.Id_(), _nT_, _nFmt_, _nW_, _nH_)
		ok

		StzEngineGpuSurfacePresent(@nSurf)
		if _bOk_
			@nFramesDrawn++
		ok
		return _bOk_

	# Draws a canvas or a 3D scene into the window and shows it, resizing the drawable to the window if their sizes differ.
	#
	#   poThing    a stzCanvas or a stzScene to render
	#   returns    1 when a frame reached the screen, 0 when the swapchain refused it, there is no
	#              surface or the object is neither a canvas nor a scene
	#   note       the frame is presented even if drawing failed, as the swapchain needs it
	#   warning    a refused frame is a normal event in a loop (a minimised window) and raises
	#              nothing; to put a second canvas over the first in one frame, use the extended
	#              form with an overlay
	#   see        EachFrame, Show, CanDraw
	def Draw(poThing)
		if @nId = 0 or @nSurf = 0
			return 0
		ok

		_nT_ = StzEngineGpuSurfaceAcquire(@nSurf)
		if _nT_ = 0
			return 0
		ok

		_nFmt_ = 0
		if StzEngineGpuSurfaceFormatName(@nSurf) = "bgra8"
			_nFmt_ = 1
		ok
		_nW_ = StzEngineWindowWidth(@nId)
		_nH_ = StzEngineWindowHeight(@nId)

		_bOk_ = 0
		_cKind_ = StzDrawableKind(poThing)
		if _cKind_ = :Canvas
			# Keep the FACE's idea of its size equal to the engine's. The
			# engine retargets either way; without this the canvas would
			# keep reporting the size it was constructed with.
			if poThing.Width() != _nW_ or poThing.Height() != _nH_
				poThing.Resize(_nW_, _nH_)
			ok
			# the canvas keeps ONE pending shape so FillQ can reach it;
			# post it before drawing or the last shape is invisible
			poThing.Flush()
			_bOk_ = StzEngineGpuSceneDrawToTarget(poThing.Id_(), _nT_, _nFmt_, _nW_, _nH_) = 1
		but _cKind_ = :Scene
			# Same reason as the canvas above, and it was missing here.
			# The engine retargets a 3D scene by itself, so the picture
			# was always right -- but the FACE went on reporting its
			# construction size, and both `Project()` and the GUI plane's
			# in-scene raycast divide by it. In a resized window every
			# click would land somewhere else, silently.
			if poThing.Width() != _nW_ or poThing.Height() != _nH_
				poThing.Resize(_nW_, _nH_)
			ok
			_bOk_ = StzEngineGpuScene3dDrawToTarget(poThing.Id_(), _nT_, _nFmt_, _nW_, _nH_) = 1
		ok

		# Present regardless: an acquired frame MUST be presented or the
		# swapchain runs out of images and every later frame is refused.
		StzEngineGpuSurfacePresent(@nSurf)
		if _bOk_
			@nFramesDrawn++
		ok
		return _bOk_

	# TRUE if the key is held down, on every frame of the hold, which suits movement.
	#
	#   pKey       a key name such as :Escape or :Space, or a GLFW key code
	#   returns    1 or 0
	#   warning    raises an error naming a key it does not know; returns 0 once freed
	#   see        KeyPressed
	#@ aka  -- input ---------------------------------------------------------------
	def KeyDown(pKey)
		return This._Key(pKey, 0)

	# TRUE if the key went down during the last frame, once for each physical press, which suits commands.
	#
	#   pKey       a key name such as :Escape or :Space, or a GLFW key code
	#   returns    1 or 0
	#   warning    raises an error naming a key it does not know; returns 0 once freed
	#   see        KeyDown
	def KeyPressed(pKey)
		return This._Key(pKey, 1)

	def _Key(pKey, pbEdge)
		if @nId = 0
			return 0
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

	# Returns the horizontal position of the mouse in the window, in pixels, as sampled at the last Poll.
	#
	#   returns    a number; 0 once freed
	#   see        MouseY, MousePosition
	def MouseX()
		if @nId = 0 return 0 ok
		return StzEngineWindowMouseX(@nId)

	# Returns the vertical position of the mouse in the window, in pixels, as sampled at the last Poll.
	#
	#   returns    a number; 0 once freed
	#   see        MouseX, MousePosition
	def MouseY()
		if @nId = 0 return 0 ok
		return StzEngineWindowMouseY(@nId)

	# Returns the mouse position as a pair, sampled at the last Poll.
	#
	#   returns    a list [ x, y ]
	#   see        MouseX, MouseY
	def MousePosition()
		return [ This.MouseX(), This.MouseY() ]

	# TRUE if the mouse button is held down, counting the buttons the way a person does.
	#
	#   pnButton   1 for left, 2 for right, 3 for middle
	#   returns    1 or 0
	#   warning    a value that is not a number, or below 1, is read as the left button
	#   see        MouseClicked
	#@ aka  button: 1 = left, 2 = right, 3 = middle (as a person counts them, not as the C API indexes them)
	def MouseDown(pnButton)
		if @nId = 0 return 0 ok
		return StzEngineWindowMouseDown(@nId, This._Btn(pnButton)) = 1

	# TRUE if the mouse button went down during the last frame.
	#
	#   pnButton   1 for left, 2 for right, 3 for middle
	#   returns    1 or 0
	#   see        MouseDown
	def MouseClicked(pnButton)
		if @nId = 0 return 0 ok
		return StzEngineWindowMouseClicked(@nId, This._Btn(pnButton)) = 1

	def _Btn(pnButton)
		if NOT isNumber(pnButton)
			return 0
		ok
		if pnButton < 1
			return 0
		ok
		return pnButton - 1

	# Turns synchronisation with the screen refresh on or off, off being the way to measure the true cost of a frame.
	#
	#   pbOn       1 to cap the loop at the screen refresh, 0 to run as fast as the card allows
	#   returns    1 when the mode changed, 0 when the card refused or there is no surface
	#   warning    the setting is kept only when the card accepted it
	#   see        VSync
	#@ aka  -- presentation knobs --------------------------------------------------
	def SetVSync(pbOn)
		if @nSurf = 0
			return 0
		ok
		_nMode_ = 0
		if pbOn = 0
			_nMode_ = 1
		ok
		if StzEngineGpuSurfaceSetPresentMode(@nSurf, _nMode_) != 0
			return 0
		ok
		@bVSync = pbOn
		return 1

	# Returns whether synchronisation with the screen refresh is on.
	#
	#   returns    1 or 0; 1 on a new window
	#   see        SetVSync
	def VSync()
		return @bVSync

	# Returns the pixel format name of the drawing surface.
	#
	#   returns    a text such as bgra8; empty text when there is no surface
	#   see        Stats, CanDraw
	def SurfaceFormat()
		if @nSurf = 0
			return ""
		ok
		return StzEngineGpuSurfaceFormatName(@nSurf)

	# Returns the surface's counters: width, height, frames presented, reconfigurations, frame held and present mode.
	#
	#   returns    a list of six numbers; [ ] when there is no surface
	#   see        SurfaceFormat, FrameCount
	#@ aka  [ width, height, framesPresented, reconfigures, frameHeld, presentMode ]
	def Stats()
		if @nSurf = 0
			return []
		ok
		_a_ = []
		for _i_ = 0 to 5
			_a_ + StzEngineGpuSurfaceStat(@nSurf, _i_)
		next
		return _a_

	# Shows a still picture in the window and waits until Escape is pressed or the window is closed.
	#
	#   poThing    a stzCanvas or a stzScene to show
	#   returns    the number of frames drawn
	#   warning    blocks until the user closes the window
	#   see        Draw, EachFrame
	#@ aka  -- the two convenience loops -------------------------------------------
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

	# Runs a frame loop that polls, then calls a function with this window, until the window closes; Escape closes it.
	#
	#   pFunc      a function taking the window, which updates and draws one frame
	#   returns    the number of frames drawn
	#   note       blocks until the user closes the window
	#   warning    raises an error when the argument is not a function
	#   see        Show, Poll, Draw
	#@ aka  Run a frame loop, calling pFunc(This) once per frame until the window closes. The anonymous function does the updating and the drawing; this only owns the pump. Escape closes, because a window with no way out is a bug in every program that ever shipped one.
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

	# Asks the window to close, which makes IsOpen answer 0 at the next check.
	#
	#   returns    nothing
	#   note       it does not release the window; call Free for that
	#   see        IsOpen, Free
	#@ aka  -- lifetime ------------------------------------------------------------
	def Close()
		if @nId != 0
			StzEngineWindowRequestClose(@nId)
		ok

	# Releases the drawing surface and the window, after which every query answers 0 or empty.
	#
	#   returns    nothing
	#   note       call it when done, as the engine holds the window until then
	#   see        Close
	def Free()
		if @nSurf != 0
			StzEngineGpuSurfaceFree(@nSurf)
			@nSurf = 0
		ok
		if @nId != 0
			StzEngineWindowFree(@nId)
			@nId = 0
		ok
