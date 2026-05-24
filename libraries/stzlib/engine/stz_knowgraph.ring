# Softanza Engine -- Knowledge Graph
#
# Loads stz_knowgraph.dll for triple store (subject-predicate-object).
#
# Function prefix: StzEngineKG*

if isWindows()
    $cStzKnowgraphLib = $cEngineDir + "/zig-out/bin/stz_knowgraph.dll"
but isLinux()
    $cStzKnowgraphLib = $cEngineDir + "/zig-out/lib/libstz_knowgraph.so"
but isMacOS()
    $cStzKnowgraphLib = $cEngineDir + "/zig-out/lib/libstz_knowgraph.dylib"
ok

if fexists($cStzKnowgraphLib)
    $pStzKnowgraphHandle = LoadLib($cStzKnowgraphLib)
else
    ? "WARNING: stz_knowgraph not found at: " + $cStzKnowgraphLib
    $pStzKnowgraphHandle = NULL
ok
