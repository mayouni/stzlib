# Softanza Engine -- Core File Ring Bridge
#
# Loads stk_file.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: core/file/stkFile.ring
# Function prefix: StkEngine* (distinct from Base StzEngine*)

if isWindows()
    $cStkFileLib = $cEngineDir + "/zig-out/bin/stk_file.dll"
but isLinux()
    $cStkFileLib = $cEngineDir + "/zig-out/lib/libstk_file.so"
but isMacOS()
    $cStkFileLib = $cEngineDir + "/zig-out/lib/libstk_file.dylib"
ok

if fexists($cStkFileLib)
    $pStkFileHandle = LoadLib($cStkFileLib)
else
    ? "WARNING: stk_file not found at: " + $cStkFileLib
    $pStkFileHandle = NULL
ok
