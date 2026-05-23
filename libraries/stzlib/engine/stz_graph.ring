# Softanza Engine -- Graph Ring Bridge
#
# Loads stz_graph.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineGraph*

if isWindows()
    $cStzGraphLib = $cEngineDir + "/zig-out/bin/stz_graph.dll"
but isLinux()
    $cStzGraphLib = $cEngineDir + "/zig-out/lib/libstz_graph.so"
but isMacOS()
    $cStzGraphLib = $cEngineDir + "/zig-out/lib/libstz_graph.dylib"
ok

if fexists($cStzGraphLib)
    $pStzGraphHandle = LoadLib($cStzGraphLib)
else
    ? "WARNING: stz_graph not found at: " + $cStzGraphLib
    $pStzGraphHandle = NULL
ok
