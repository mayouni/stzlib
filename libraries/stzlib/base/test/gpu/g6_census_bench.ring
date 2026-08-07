# G6 measurement -- the ggml-Vulkan decision's numbers, taken AFTER the
# kill criteria were written (see the G6 section of SOFTANZA_GPU_PLAN.md).
#
# Compares the neural tier's ACTUAL compute route (StzEngineMatrixMulGgml:
# ggml's threaded SIMD f32 matmul, as shipped, bridge overhead included --
# that IS what the tier pays today) against the already-shipped wgpu path
# (StzEngineGpuOpMatmul on resident buffers) across the BERT-class shape
# census: attention/projection (k=384,n=384), FFN up/down (384<->1536),
# the batch-embedding shape, and the token-by-token DECODE matvec (m=1).
#
# wgpu here is a fair PROXY CEILING for ggml-Vulkan on this silicon: same
# GPU, same f32; if even the proxy cannot clear the bar, vendoring a
# second GPU stack cannot pay.

load "../../stzBase.ring"

decimals(3)

StzEngineGpuInit($cStzGpuRuntime)
if StzEngineGpuIsAvailable() = 0
    ? "NO GPU -- the measurement needs the proxy device"
    return
ok
? "device: " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
? ""
? "shape (m x k x n)      ggml-cpu ms   wgpu ms    ratio"

# the census: [m, k, n, label]
aShapes = [
    [ 128,  384,  384, "attn qkv/proj, seq 128" ],
    [ 128,  384, 1536, "ffn up,        seq 128" ],
    [ 128, 1536,  384, "ffn down,      seq 128" ],
    [ 512,  384, 1536, "ffn up,        seq 512" ],
    [ 4096, 384, 1536, "batch embed (32x128 tokens)" ],
    [ 1,    384, 1536, "DECODE matvec (m=1)" ],
    [ 1,   1536,  384, "DECODE matvec down" ]
]

for s = 1 to len(aShapes)
    nM = aShapes[s][1]
    nK = aShapes[s][2]
    nN = aShapes[s][3]

    # ggml route: resident stz_matrix handles, repeated MulGgml
    hA = StzEngineMatrixNew(nM, nK)
    hB = StzEngineMatrixNew(nK, nN)
    hR = StzEngineMatrixNew(nM, nN)
    for i = 1 to nM
        StzEngineMatrixSet(hA, i, 1 + (i % nK), 1.5)
    next
    for i = 1 to nK
        StzEngineMatrixSet(hB, i, 1 + (i % nN), 0.5)
    next
    StzEngineMatrixMulGgml(hA, hB, hR)
    nGgml = 999999999
    for r = 1 to 5
        nT0 = StzEngineWatchTimestampNs()
        StzEngineMatrixMulGgml(hA, hB, hR)
        nMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
        if nMs < nGgml nGgml = nMs ok
    next

    # wgpu route: resident buffers, OpMatmul + Sync per rep
    hGa = StzEngineGpuBufferNew(nM * nK * 4)
    hGb = StzEngineGpuBufferNew(nK * nN * 4)
    hGc = StzEngineGpuBufferNew(nM * nN * 4)
    aFill = []
    for i = 1 to nM * nK
        aFill + 1.5
    next
    StzEngineGpuBufferUploadList(hGa, aFill)
    aFill = []
    for i = 1 to nK * nN
        aFill + 0.5
    next
    StzEngineGpuBufferUploadList(hGb, aFill)
    StzEngineGpuOpMatmul(hGa, hGb, hGc, nM, nK, nN)
    StzEngineGpuSync()
    nGpu = 999999999
    for r = 1 to 5
        nT0 = StzEngineWatchTimestampNs()
        StzEngineGpuOpMatmul(hGa, hGb, hGc, nM, nK, nN)
        StzEngineGpuSync()
        nMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
        if nMs < nGpu nGpu = nMs ok
    next

    ? "" + nM + " x " + nK + " x " + nN + "  (" + aShapes[s][4] + ")" + char(10) +
        "    " + nGgml + "    " + nGpu + "    " + (nGgml / nGpu) + "x"

    StzEngineMatrixFree(hA)
    StzEngineMatrixFree(hB)
    StzEngineMatrixFree(hR)
    StzEngineGpuBufferFree(hGa)
    StzEngineGpuBufferFree(hGb)
    StzEngineGpuBufferFree(hGc)
next
StzEngineGpuShutdown()
