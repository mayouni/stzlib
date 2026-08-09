# Softanza Engine -- Windows and Input (GR5, SOFTANZA_GRAPHICS_PLAN.md)
#
# Loads stz_window.dll: native windows, the event pump, keyboard and mouse.
#
# WHY THIS IS A SEPARATE DLL, and not part of stz_gpu -- measured, not
# assumed (see engine/vendor/glfw/VERSION.txt):
#
#     zig cc -target x86_64-linux-gnu  #include <X11/Xlib.h>   -> NOT FOUND
#     zig cc -target aarch64-macos     #import <Cocoa/Cocoa.h>  -> NOT FOUND
#
# Zig bundles libc, not platform GUI SDKs. Every other engine module cross
# compiles from any host; windowing cannot. Linking GLFW into stz_gpu.dll
# would have spent the GPU plane's portability on a window. So the window
# lives alone, is loaded ONLY if present, and its absence is a counted
# refusal -- a headless machine, a CI runner, an SSH session still runs
# every other graphics path (the SVG tier needs no device at all, and the
# PNG tier needs a device but no window).
#
# Function prefix: StzEngineWindow*
#
# Status codes: 0 = OK   1 = FALLBACK (no windowing)   2 = STALE   3 = BAD_ARG
#
#   StzEngineWindowIsAvailable()          -- 1 when a window can be opened
#   StzEngineWindowLastError()
#   StzEngineWindowNew(w, h, cTitle) -> id (0 = refusal)
#   StzEngineWindowFree(id)
#   StzEngineWindowNativeHandle(id)  -- HWND / X11 Window / NSWindow, as a
#       number. An OS handle, NOT an engine handle: it may legitimately
#       cross to stz_gpu, which turns it into a wgpu surface.
#   StzEngineWindowNativeDisplay(id) -- X11 Display*; 0 elsewhere
#   StzEngineWindowIsOpen(id) / RequestClose(id)
#   StzEngineWindowPoll(id)          -- pump events AND sample input
#   StzEngineWindowWidth(id) / Height(id) / WasResized(id)
#   StzEngineWindowDeltaTime(id)     -- seconds since the previous poll
#   StzEngineWindowFrameCount(id)
#   StzEngineWindowKeyDown(id, nKey) / KeyPressed(id, nKey)
#   StzEngineWindowMouseX(id) / MouseY(id)
#   StzEngineWindowMouseDown(id, nBtn) / MouseClicked(id, nBtn)
#   StzEngineWindowSetSize(id, w, h)  -- resize from code; takes effect at
#       the next Poll, exactly as a dragged edge does. It exists so the
#       resize path can be GUARDED: without it, swapchain reconfigure and
#       depth-buffer rebuild can only ever be driven by a human with a mouse.
#   StzEngineWindowSetTitle(id, cTitle) / Shutdown()
#
# HELD vs PRESSED, and why both exist: KeyDown answers "is it down right
# now" (movement -- true for as long as you hold it); KeyPressed answers
# "did it go down since the last poll" (a command -- true exactly once per
# physical press). A loop written with only the first repeats commands 60
# times a second. Poll() computes both, so two reads in one frame agree.

if isWindows()
    $cStzWindowLib = $cEngineDir + "/zig-out/bin/stz_window.dll"
but isLinux()
    $cStzWindowLib = $cEngineDir + "/zig-out/lib/libstz_window.so"
but isMacOS()
    $cStzWindowLib = $cEngineDir + "/zig-out/lib/libstz_window.dylib"
ok

# Absent is a legitimate state here, unlike the other domains: this DLL is
# the one that cannot be cross-built for every machine from one box. Load
# quietly; the face reports the refusal in its own words.
$pStzWindowHandle = NULL
if fexists($cStzWindowLib)
    $pStzWindowHandle = LoadLib($cStzWindowLib)
ok

# Ask THIS before calling any StzEngineWindow* function -- with the DLL
# absent the functions do not exist and a bare call is a Ring error, not a
# graceful FALSE.
func StzWindowEngineLoaded()
	return $pStzWindowHandle != NULL

# ---- key codes (GLFW values; the face exposes them by name) -----------
# Only the ones a graphics loop reaches for. The engine takes any code in
# 0..511, so an unlisted key is a number away.

func StzWindowKeyCode pcName
	switch upper("" + pcName)
	on "SPACE"      return 32
	on "APOSTROPHE" return 39
	on "COMMA"      return 44
	on "MINUS"      return 45
	on "PERIOD"     return 46
	on "SLASH"      return 47
	on "ESCAPE"     return 256
	on "ENTER"      return 257
	on "TAB"        return 258
	on "BACKSPACE"  return 259
	on "RIGHT"      return 262
	on "LEFT"       return 263
	on "DOWN"       return 264
	on "UP"         return 265
	on "PAGEUP"     return 266
	on "PAGEDOWN"   return 267
	on "HOME"       return 268
	on "END"        return 269
	on "LEFTSHIFT"  return 340
	on "LEFTCTRL"   return 341
	on "LEFTALT"    return 342
	off

	_cU_ = upper("" + pcName)
	if len(_cU_) = 1
		_nA_ = ascii(_cU_)
		# digits 0-9 and letters A-Z ARE their ASCII codes in GLFW
		if (_nA_ >= 48 and _nA_ <= 57) or (_nA_ >= 65 and _nA_ <= 90)
			return _nA_
		ok
	ok
	if left(_cU_, 1) = "F" and len(_cU_) <= 3
		_nN_ = 0 + right(_cU_, len(_cU_) - 1)
		if _nN_ >= 1 and _nN_ <= 25
			return 289 + _nN_        # F1 = 290
		ok
	ok
	return -1
