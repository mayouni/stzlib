# Softanza Engine -- Display Engine
#
# Loads stz_display.dll for number/percent/bytes formatting, bar charts, trees.
#
# Function prefix: StzEngineDisplay*

if isWindows()
    $cStzDisplayLib = $cEngineDir + "/zig-out/bin/stz_display.dll"
but isLinux()
    $cStzDisplayLib = $cEngineDir + "/zig-out/lib/libstz_display.so"
but isMacOS()
    $cStzDisplayLib = $cEngineDir + "/zig-out/lib/libstz_display.dylib"
ok

if fexists($cStzDisplayLib)
    $pStzDisplayHandle = LoadLib($cStzDisplayLib)
else
    ? "WARNING: stz_display not found at: " + $cStzDisplayLib
    $pStzDisplayHandle = NULL
ok
