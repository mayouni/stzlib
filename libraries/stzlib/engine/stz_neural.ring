# Softanza Engine -- Neural / modern tier (ggml)
#
# Loads stz_neural.dll: the vendored ggml (CPU-only) inference runtime for the
# modern NLP tier (embeddings, semantic search, zero-shot, transformer NER).
# Unlike the classical @embedFile'd models, neural models load at RUNTIME.
#
# Function prefix: StzEngineNeural*

if isWindows()
    $cStzNeuralLib = $cEngineDir + "/zig-out/bin/stz_neural.dll"
but isLinux()
    $cStzNeuralLib = $cEngineDir + "/zig-out/lib/libstz_neural.so"
but isMacOS()
    $cStzNeuralLib = $cEngineDir + "/zig-out/lib/libstz_neural.dylib"
ok

if fexists($cStzNeuralLib)
    $pStzNeuralHandle = LoadLib($cStzNeuralLib)
else
    ? "WARNING: stz_neural not found at: " + $cStzNeuralLib
    $pStzNeuralHandle = NULL
ok
