# Softanza Engine -- Quantifiers
#
# Loads stz_quantifier.dll for named quantifiers with configurable thresholds.
#
# Function prefix: StzEngineQuantifier*

if isWindows()
    $cStzQuantifierLib = $cEngineDir + "/zig-out/bin/stz_quantifier.dll"
but isLinux()
    $cStzQuantifierLib = $cEngineDir + "/zig-out/lib/libstz_quantifier.so"
but isMacOS()
    $cStzQuantifierLib = $cEngineDir + "/zig-out/lib/libstz_quantifier.dylib"
ok
if fexists($cStzQuantifierLib)
    $pStzQuantifierHandle = LoadLib($cStzQuantifierLib)
else
    ? "WARNING: stz_quantifier not found at: " + $cStzQuantifierLib
    $pStzQuantifierHandle = NULL
ok
