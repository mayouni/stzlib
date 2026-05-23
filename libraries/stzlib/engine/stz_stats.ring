# Softanza Engine -- Stats Ring Bridge
#
# Loads stz_stats.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineStats*

if isWindows()
    $cStzStatsLib = $cEngineDir + "/zig-out/bin/stz_stats.dll"
but isLinux()
    $cStzStatsLib = $cEngineDir + "/zig-out/lib/libstz_stats.so"
but isMacOS()
    $cStzStatsLib = $cEngineDir + "/zig-out/lib/libstz_stats.dylib"
ok

if fexists($cStzStatsLib)
    $pStzStatsHandle = LoadLib($cStzStatsLib)
else
    ? "WARNING: stz_stats not found at: " + $cStzStatsLib
    $pStzStatsHandle = NULL
ok
