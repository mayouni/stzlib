# Softanza Engine -- Reaxis Ring Bridge
#
# Loads stz_reaxis.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineReaxis*

if isWindows()
    $cStzReaxisLib = $cEngineDir + "/zig-out/bin/stz_reaxis.dll"
but isLinux()
    $cStzReaxisLib = $cEngineDir + "/zig-out/lib/libstz_reaxis.so"
but isMacOS()
    $cStzReaxisLib = $cEngineDir + "/zig-out/lib/libstz_reaxis.dylib"
ok

if fexists($cStzReaxisLib)
    $pStzReaxisHandle = LoadLib($cStzReaxisLib)
else
    ? "WARNING: stz_reaxis not found at: " + $cStzReaxisLib
    $pStzReaxisHandle = NULL
ok
