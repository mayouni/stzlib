# Softanza Engine -- Value Ring Bridge
#
# Loads stz_value.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/list/stzList.ring (for Reduce)
# Function prefix: StzEngineValue*

if isWindows()
    $cStzValueLib = $cEngineDir + "/zig-out/bin/stz_value.dll"
but isLinux()
    $cStzValueLib = $cEngineDir + "/zig-out/lib/libstz_value.so"
but isMacOS()
    $cStzValueLib = $cEngineDir + "/zig-out/lib/libstz_value.dylib"
ok

if fexists($cStzValueLib)
    $pStzValueHandle = LoadLib($cStzValueLib)
else
    ? "WARNING: stz_value not found at: " + $cStzValueLib
    $pStzValueHandle = NULL
ok
