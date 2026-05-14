# Softanza Engine -- Base Bytes Ring Bridge
#
# Loads stz_bytes.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Used by: base/number/stzListOfBytes.ring
# Function prefix: StzEngine*

if isWindows()
    $cStzBytesLib = $cEngineDir + "/zig-out/bin/stz_bytes.dll"
but isLinux()
    $cStzBytesLib = $cEngineDir + "/zig-out/lib/libstz_bytes.so"
but isMacOS()
    $cStzBytesLib = $cEngineDir + "/zig-out/lib/libstz_bytes.dylib"
ok

if fexists($cStzBytesLib)
    $pStzBytesHandle = LoadLib($cStzBytesLib)
else
    ? "WARNING: stz_bytes not found at: " + $cStzBytesLib
    $pStzBytesHandle = NULL
ok
