# Softanza Engine -- Confidence Scoring
#
# Loads stz_confidence.dll for confidence scoring.
#
# Function prefix: StzEngineConfidence*

if isWindows()
    $cStzConfidenceLib = $cEngineDir + "/zig-out/bin/stz_confidence.dll"
but isLinux()
    $cStzConfidenceLib = $cEngineDir + "/zig-out/lib/libstz_confidence.so"
but isMacOS()
    $cStzConfidenceLib = $cEngineDir + "/zig-out/lib/libstz_confidence.dylib"
ok
if fexists($cStzConfidenceLib)
    $pStzConfidenceHandle = LoadLib($cStzConfidenceLib)
else
    ? "WARNING: stz_confidence not found at: " + $cStzConfidenceLib
    $pStzConfidenceHandle = NULL
ok
