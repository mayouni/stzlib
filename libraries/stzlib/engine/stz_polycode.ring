# Softanza Engine -- Polycode Ring Bridge
#
# Loads stz_polycode.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEnginePolycode*

if isWindows()
    $cStzPolycodeLib = $cEngineDir + "/zig-out/bin/stz_polycode.dll"
but isLinux()
    $cStzPolycodeLib = $cEngineDir + "/zig-out/lib/libstz_polycode.so"
but isMacOS()
    $cStzPolycodeLib = $cEngineDir + "/zig-out/lib/libstz_polycode.dylib"
ok

if fexists($cStzPolycodeLib)
    $pStzPolycodeHandle = LoadLib($cStzPolycodeLib)
else
    ? "WARNING: stz_polycode not found at: " + $cStzPolycodeLib
    $pStzPolycodeHandle = NULL
ok
