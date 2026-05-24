# Softanza Engine -- String Art
#
# Loads stz_stringart.dll for pad/center/box/indent/truncate.
#
# Function prefix: StzEngineStringArt*

if isWindows()
    $cStzStringartLib = $cEngineDir + "/zig-out/bin/stz_stringart.dll"
but isLinux()
    $cStzStringartLib = $cEngineDir + "/zig-out/lib/libstz_stringart.so"
but isMacOS()
    $cStzStringartLib = $cEngineDir + "/zig-out/lib/libstz_stringart.dylib"
ok

if fexists($cStzStringartLib)
    $pStzStringartHandle = LoadLib($cStzStringartLib)
else
    ? "WARNING: stz_stringart not found at: " + $cStzStringartLib
    $pStzStringartHandle = NULL
ok
