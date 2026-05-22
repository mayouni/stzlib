# Softanza Engine -- Number Ring Bridge
#
# Loads stz_number.dll as a Ring extension.
# ringlib_init registers all functions natively -- no CallCFunc needed.
# Ring code calls them directly by name (case-insensitive).
#
# Function prefix: StzEngineBigInt*, StzEngineNumber*

if isWindows()
    $cStzNumberLib = $cEngineDir + "/zig-out/bin/stz_number.dll"
but isLinux()
    $cStzNumberLib = $cEngineDir + "/zig-out/lib/libstz_number.so"
but isMacOS()
    $cStzNumberLib = $cEngineDir + "/zig-out/lib/libstz_number.dylib"
ok

if fexists($cStzNumberLib)
    $pStzNumberHandle = LoadLib($cStzNumberLib)
else
    ? "WARNING: stz_number not found at: " + $cStzNumberLib
    $pStzNumberHandle = NULL
ok
