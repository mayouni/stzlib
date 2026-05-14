# Softanza Engine -- Base URL Ring Bridge
#
# Loads stz_url.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/network/stzUrl.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzUrlLib = $cEngineDir + "/zig-out/bin/stz_url.dll"
but isLinux()
    $cStzUrlLib = $cEngineDir + "/zig-out/lib/libstz_url.so"
but isMacOS()
    $cStzUrlLib = $cEngineDir + "/zig-out/lib/libstz_url.dylib"
ok

if fexists($cStzUrlLib)
    $pStzUrlHandle = LoadLib($cStzUrlLib)
else
    ? "WARNING: stz_url not found at: " + $cStzUrlLib
    $pStzUrlHandle = NULL
ok
