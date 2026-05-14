# Softanza Engine -- Core DateTime Ring Bridge
#
# Loads stk_datetime.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: core/datetime/stkDate.ring, stkTime.ring
# Function prefix: StkEngine* (distinct from Base StzEngine*)

if isWindows()
    $cStkDateTimeLib = $cEngineDir + "/zig-out/bin/stk_datetime.dll"
but isLinux()
    $cStkDateTimeLib = $cEngineDir + "/zig-out/lib/libstk_datetime.so"
but isMacOS()
    $cStkDateTimeLib = $cEngineDir + "/zig-out/lib/libstk_datetime.dylib"
ok

if fexists($cStkDateTimeLib)
    $pStkDateTimeHandle = LoadLib($cStkDateTimeLib)
else
    ? "WARNING: stk_datetime not found at: " + $cStkDateTimeLib
    $pStkDateTimeHandle = NULL
ok
