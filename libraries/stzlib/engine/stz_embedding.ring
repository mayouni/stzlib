# Softanza Engine -- Embedding Store
#
# Loads stz_embedding.dll for embedding store.
#
# Function prefix: StzEngineEmbedding*

if isWindows()
    $cStzEmbeddingLib = $cEngineDir + "/zig-out/bin/stz_embedding.dll"
but isLinux()
    $cStzEmbeddingLib = $cEngineDir + "/zig-out/lib/libstz_embedding.so"
but isMacOS()
    $cStzEmbeddingLib = $cEngineDir + "/zig-out/lib/libstz_embedding.dylib"
ok
if fexists($cStzEmbeddingLib)
    $pStzEmbeddingHandle = LoadLib($cStzEmbeddingLib)
else
    ? "WARNING: stz_embedding not found at: " + $cStzEmbeddingLib
    $pStzEmbeddingHandle = NULL
ok
