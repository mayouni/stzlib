# Softanza Engine -- GridNav Ring Bridge
#
# Loads stz_gridnav.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineGrid*

if isWindows()
    $cStzGridnavLib = $cEngineDir + "/zig-out/bin/stz_gridnav.dll"
but isLinux()
    $cStzGridnavLib = $cEngineDir + "/zig-out/lib/libstz_gridnav.so"
but isMacOS()
    $cStzGridnavLib = $cEngineDir + "/zig-out/lib/libstz_gridnav.dylib"
ok

if fexists($cStzGridnavLib)
    $pStzGridnavHandle = LoadLib($cStzGridnavLib)
else
    ? "WARNING: stz_gridnav not found at: " + $cStzGridnavLib
    $pStzGridnavHandle = NULL
ok
