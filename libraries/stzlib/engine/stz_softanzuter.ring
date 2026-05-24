# Softanza Engine -- Softanzuter Ring Bridge
#
# Loads stz_softanzuter.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineZuter*

if isWindows()
    $cStzSoftanzuterLib = $cEngineDir + "/zig-out/bin/stz_softanzuter.dll"
but isLinux()
    $cStzSoftanzuterLib = $cEngineDir + "/zig-out/lib/libstz_softanzuter.so"
but isMacOS()
    $cStzSoftanzuterLib = $cEngineDir + "/zig-out/lib/libstz_softanzuter.dylib"
ok

if fexists($cStzSoftanzuterLib)
    $pStzSoftanzuterHandle = LoadLib($cStzSoftanzuterLib)
else
    ? "WARNING: stz_softanzuter not found at: " + $cStzSoftanzuterLib
    $pStzSoftanzuterHandle = NULL
ok
