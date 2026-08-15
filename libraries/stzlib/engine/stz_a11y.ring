# Softanza Engine -- the accessibility bridge (G4b, base/gui/SOFTANZA_GUI_PLAN.md)
#
# Loads stz_a11y.dll: the accessibility tree, handed to the operating
# system's own assistive-technology API by way of AccessKit.
#
# WHY THIS IS A SEPARATE DLL, and not part of stz_gui: AccessKit is
# per-OS. It talks to UI Automation on Windows, NSAccessibility on macOS
# and AT-SPI on Linux, which is exactly the property that made GR5 put
# windows in stz_window and the sound plan put devices in stz_audiodev.
# The portable half of a plane does not carry a per-OS dependency.
#
# THE RUNTIME IS LOADED BY NAME, NEVER LINKED -- the same arrangement
# stz_gpu has with wgpu_native.dll, and it buys the same thing: this DLL
# always loads, and a machine without accesskit.dll simply has no
# screen-reader bridge. That is a state, not an error. See
# engine/vendor/accesskit/VERSION for why a prebuilt binary is the
# house's shape rather than a new kind of decision.
#
# Function prefix: StzEngineA11y*
#
#   StzEngineA11yLoad(cPath)      -- 1 when the runtime opened
#   StzEngineA11yIsAvailable()
#   StzEngineA11yLastError()
#   StzEngineA11yAttach(nNativeWindowHandle) -> id, or a negative status
#       The handle comes from StzEngineWindowNativeHandle. Attaching
#       HIDES and RE-SHOWS the window, because AccessKit's subclassing
#       adapter refuses a window that is already visible -- do it right
#       after creating the window and nothing flickers.
#   StzEngineA11yUpdate(id, cTreeJson) -> status
#       The JSON is stzAccessibilityTree.ToJSON() unchanged.
#   StzEngineA11yDetach(id) / StzEngineA11yIsLive(id)
#   StzEngineA11yStats(id) -> [ updates, activations, nodes ]
#       ACTIVATIONS is the number that matters: it counts the times an
#       assistive technology actually ASKED for the tree. `updates` only
#       says we pushed one, and a bridge reporting pushes alone would
#       look identical with and without a screen reader running.
#
# Statuses: 0 = OK  -1 = BAD_ARG  -2 = UNAVAILABLE  -3 = REFUSED

if isWindows()
	$cStzA11yLib = $cEngineDir + "/zig-out/bin/stz_a11y.dll"
	$cStzA11yRuntime = $cEngineDir + "/zig-out/bin/accesskit.dll"
but isLinux()
	$cStzA11yLib = $cEngineDir + "/zig-out/lib/libstz_a11y.so"
	$cStzA11yRuntime = $cEngineDir + "/zig-out/lib/libaccesskit.so"
but isMacOS()
	$cStzA11yLib = $cEngineDir + "/zig-out/lib/libstz_a11y.dylib"
	$cStzA11yRuntime = $cEngineDir + "/zig-out/lib/libaccesskit.dylib"
ok

if fexists($cStzA11yLib)
	$pStzA11yHandle = LoadLib($cStzA11yLib)
else
	$pStzA11yHandle = NULL
ok

# Open the runtime once, lazily. A caller never has to know where the
# vendored DLL lives -- which is the whole reason this function exists
# rather than making every face pass a path.
$bStzA11yTried_ = FALSE

func StzA11yReady()
	if $pStzA11yHandle = NULL
		return FALSE
	ok
	if StzEngineA11yIsAvailable() = 1
		return TRUE
	ok
	if $bStzA11yTried_
		return FALSE          # tried once, failed; do not retry per call
	ok
	$bStzA11yTried_ = TRUE
	if NOT fexists($cStzA11yRuntime)
		return FALSE
	ok
	return StzEngineA11yLoad($cStzA11yRuntime) = 1
