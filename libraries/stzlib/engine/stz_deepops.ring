# Softanza Engine -- DeepOps Ring Bridge
#
# Loads stz_deepops.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineDeep*

if isWindows()
    $cStzDeepopsLib = $cEngineDir + "/zig-out/bin/stz_deepops.dll"
but isLinux()
    $cStzDeepopsLib = $cEngineDir + "/zig-out/lib/libstz_deepops.so"
but isMacOS()
    $cStzDeepopsLib = $cEngineDir + "/zig-out/lib/libstz_deepops.dylib"
ok

if fexists($cStzDeepopsLib)
    $pStzDeepopsHandle = LoadLib($cStzDeepopsLib)
else
    ? "WARNING: stz_deepops not found at: " + $cStzDeepopsLib
    $pStzDeepopsHandle = NULL
ok
