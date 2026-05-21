# Softanza Engine -- Base List Ring Bridge
#
# Loads stz_list.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/list/stzList.ring
# Function prefix: StzEngineList*

if isWindows()
    $cStzListLib = $cEngineDir + "/zig-out/bin/stz_list.dll"
but isLinux()
    $cStzListLib = $cEngineDir + "/zig-out/lib/libstz_list.so"
but isMacOS()
    $cStzListLib = $cEngineDir + "/zig-out/lib/libstz_list.dylib"
ok

if fexists($cStzListLib)
    $pStzListHandle = LoadLib($cStzListLib)
else
    ? "WARNING: stz_list not found at: " + $cStzListLib
    $pStzListHandle = NULL
ok
