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
    # GPU routing (post-G6 constructive route): record WHERE the wgpu runtime
    # lives -- a string store only, zero startup cost. The device initializes
    # lazily at the first matmul big enough to clear the calibrated threshold;
    # machines without a GPU (or without the runtime) stay silently on CPU.
    StzEngineNeuralGpuRuntimePath($cEngineDir + "/zig-out/bin/wgpu_native.dll")
else
    ? "WARNING: stz_neural not found at: " + $cStzNeuralLib
    $pStzNeuralHandle = NULL
ok
