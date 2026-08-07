# Softanza Engine -- GPU Plane Lifecycle (G1, SOFTANZA_GPU_PLAN.md)
#
# Loads stz_gpu.dll: device/buffer/kernel handles, WGSL compile-cache,
# bounded VRAM cache, TDR-safe tiling, calibration store, instruments.
#
# The wgpu runtime (wgpu_native.dll) is NOT a load-time dependency: it is
# resolved when StzEngineGpuInit(cPath) is called. On machines without a
# GPU (or without the runtime) every GPU function answers the fallback
# way and gpu.fallback.count increments -- nothing crashes.
#
# Function prefix: StzEngineGpu*
#
# Status codes (returned by buffer/dispatch/sync functions):
#   0 = OK   1 = FALLBACK (no device)   2 = STALE (buffer evicted/freed)
#   3 = BAD_ARG   4 = TOO_LARGE   5 = GPU_ERROR
#
# Counter indices for StzEngineGpuCounter(n):
#   0 dispatch count    1 dispatch ms (total)   2 transfer bytes
#   3 fallback count    4 kernel compiles       5 compile-cache hits
#   6 queue submits     7 evictions             8 live buffers
#   9 device errors
#
# The G2 op library (all ops take BUFFER IDS -- upload once, chain,
# read back once; every op is submit-only except the reductions):
#   StzEngineGpuOpMatmul(hA, hB, hC, m, k, n)        C = A*B, row-major f32
#   StzEngineGpuOpPairDist(hA, hB, hD, m, n, d)      squared L2, rows x rows
#   StzEngineGpuOpAxpby(alpha, hA, beta, hB, hOut, n)
#   StzEngineGpuOpMul(hA, hB, hOut, n)               Hadamard
#   StzEngineGpuOpScaleInPlace(hV, alpha, n)
#   StzEngineGpuOpSoftmax(hIn, hOut, n)              max-shifted, 3 passes
#   StzEngineGpuOpSum(hA, n)  -> [status, value]     f64 fold of partials
#   StzEngineGpuOpDot(hA, hB, n) -> [status, value]
# OUT buffers must be distinct from inputs (WebGPU aliasing validation).
#
# Kernel binding contract (every kernel compiled through this layer):
#   @group(0) @binding(0)  var<uniform> tile : StzTile   -- layer-owned
#       struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
#       xoff = this tile's x-offset IN WORKGROUPS (TDR tiling); a kernel
#       computes its element index as gid.x + tile.xoff * WORKGROUP_X.
#   @group(0) @binding(1..) = the dispatch call's buffers, in list order.

if isWindows()
    $cStzGpuLib = $cEngineDir + "/zig-out/bin/stz_gpu.dll"
    $cStzGpuRuntime = $cEngineDir + "/zig-out/bin/wgpu_native.dll"
but isLinux()
    $cStzGpuLib = $cEngineDir + "/zig-out/lib/libstz_gpu.so"
    $cStzGpuRuntime = $cEngineDir + "/zig-out/lib/libwgpu_native.so"
but isMacOS()
    $cStzGpuLib = $cEngineDir + "/zig-out/lib/libstz_gpu.dylib"
    $cStzGpuRuntime = $cEngineDir + "/zig-out/lib/libwgpu_native.dylib"
ok

if fexists($cStzGpuLib)
    $pStzGpuHandle = LoadLib($cStzGpuLib)
else
    ? "WARNING: stz_gpu not found at: " + $cStzGpuLib
    $pStzGpuHandle = NULL
ok
