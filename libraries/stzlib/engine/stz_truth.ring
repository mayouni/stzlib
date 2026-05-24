# Softanza Engine -- Truth Domains
#
# Loads stz_truth.dll for domain-configurable truth values.
#
# Function prefix: StzEngineTruth*

if isWindows()
    $cStzTruthLib = $cEngineDir + "/zig-out/bin/stz_truth.dll"
but isLinux()
    $cStzTruthLib = $cEngineDir + "/zig-out/lib/libstz_truth.so"
but isMacOS()
    $cStzTruthLib = $cEngineDir + "/zig-out/lib/libstz_truth.dylib"
ok
if fexists($cStzTruthLib)
    $pStzTruthHandle = LoadLib($cStzTruthLib)
else
    ? "WARNING: stz_truth not found at: " + $cStzTruthLib
    $pStzTruthHandle = NULL
ok
