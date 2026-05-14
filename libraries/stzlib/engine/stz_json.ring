# Softanza Engine -- Base JSON Ring Bridge
#
# Loads stz_json.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/file/stzJson.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzJsonLib = $cEngineDir + "/zig-out/bin/stz_json.dll"
but isLinux()
    $cStzJsonLib = $cEngineDir + "/zig-out/lib/libstz_json.so"
but isMacOS()
    $cStzJsonLib = $cEngineDir + "/zig-out/lib/libstz_json.dylib"
ok

if fexists($cStzJsonLib)
    $pStzJsonHandle = LoadLib($cStzJsonLib)
else
    ? "WARNING: stz_json not found at: " + $cStzJsonLib
    $pStzJsonHandle = NULL
ok
