# Softanza Engine -- Small Utility Functions
#
# Loads stz_smallfn.dll for min/max/abs/sign/clamp/lerp/rounding/math.
#
# Function prefix: StzEngineSmall*

if isWindows()
    $cStzSmallfnLib = $cEngineDir + "/zig-out/bin/stz_smallfn.dll"
but isLinux()
    $cStzSmallfnLib = $cEngineDir + "/zig-out/lib/libstz_smallfn.so"
but isMacOS()
    $cStzSmallfnLib = $cEngineDir + "/zig-out/lib/libstz_smallfn.dylib"
ok

if fexists($cStzSmallfnLib)
    $pStzSmallfnHandle = LoadLib($cStzSmallfnLib)
else
    ? "WARNING: stz_smallfn not found at: " + $cStzSmallfnLib
    $pStzSmallfnHandle = NULL
ok
