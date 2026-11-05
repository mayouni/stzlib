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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("display")
    $pStzDisplayHandle = NULL
but fexists($cStzDisplayLib)
    $pStzDisplayHandle = LoadLib($cStzDisplayLib)
else
    ? "WARNING: stz_display not found at: " + $cStzDisplayLib
    $pStzDisplayHandle = NULL
ok
