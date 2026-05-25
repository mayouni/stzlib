# Softanza Engine -- Similarity Metrics
#
# Loads stz_similarity.dll for similarity metrics.
#
# Function prefix: StzEngineSimilarity*

if isWindows()
    $cStzSimilarityLib = $cEngineDir + "/zig-out/bin/stz_similarity.dll"
but isLinux()
    $cStzSimilarityLib = $cEngineDir + "/zig-out/lib/libstz_similarity.so"
but isMacOS()
    $cStzSimilarityLib = $cEngineDir + "/zig-out/lib/libstz_similarity.dylib"
ok
if fexists($cStzSimilarityLib)
    $pStzSimilarityHandle = LoadLib($cStzSimilarityLib)
else
    ? "WARNING: stz_similarity not found at: " + $cStzSimilarityLib
    $pStzSimilarityHandle = NULL
ok
