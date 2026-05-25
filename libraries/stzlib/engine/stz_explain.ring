# Softanza Engine -- Explanation Engine
#
# Loads stz_explain.dll for explanation engine.
#
# Function prefix: StzEngineExplain*

if isWindows()
    $cStzExplainLib = $cEngineDir + "/zig-out/bin/stz_explain.dll"
but isLinux()
    $cStzExplainLib = $cEngineDir + "/zig-out/lib/libstz_explain.so"
but isMacOS()
    $cStzExplainLib = $cEngineDir + "/zig-out/lib/libstz_explain.dylib"
ok
if fexists($cStzExplainLib)
    $pStzExplainHandle = LoadLib($cStzExplainLib)
else
    ? "WARNING: stz_explain not found at: " + $cStzExplainLib
    $pStzExplainHandle = NULL
ok
