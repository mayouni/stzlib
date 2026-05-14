# Softanza Engine -- Core String + Char Ring Bridge
#
# Loads stk_string.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: core/string/stkString.ring, core/string/stkChar.ring
# Function prefix: StkEngine* (distinct from Base StzEngine*)

if isWindows()
    $cStkStringLib = $cEngineDir + "/zig-out/bin/stk_string.dll"
but isLinux()
    $cStkStringLib = $cEngineDir + "/zig-out/lib/libstk_string.so"
but isMacOS()
    $cStkStringLib = $cEngineDir + "/zig-out/lib/libstk_string.dylib"
ok

if fexists($cStkStringLib)
    $pStkStringHandle = LoadLib($cStkStringLib)
else
    ? "WARNING: stk_string not found at: " + $cStkStringLib
    $pStkStringHandle = NULL
ok
