# R1 SPIKE for the resident backbone (SOFTANZA_GPU_PLAN.md).
#
# Times the MATMUL SPINE of a MiniLM forward pass exactly as a resident
# backbone would run it: every operand already on the device, every
# dispatch submitted with NO readback and NO sync between links, ONE sync
# at the end. That is the FLOOR -- the real backbone adds LN, softmax,
# GELU, bias and pooling dispatches on top, so it can only be slower.
#
# The bar (R1, written before this ran): the spine must beat the CPU's
# FULL forward -- 36.6 ms measured by neural_gpu_routing_narrated.ring on
# the same machine, same seq -- by >= 2x, or the backbone has no headroom
# for its remaining kernels and is a NO-GO.
#
# MiniLM-L6-v2 at seq 130: n_embd 384, 12 heads (head_dim 32), ffn 1536,
# 6 layers. Per layer: Q,K,V,attn_out [130x384]x[384x384]; ffn_up
# [130x384]x[384x1536]; ffn_down [130x1536]x[1536x384]; plus per-head
# KQ [130x32]x[32x130] and KQV [130x130]x[130x32].

load "../../stzBase.ring"

decimals(3)

nSeq = 130
nEmb = 384
nHeads = 12
nHeadDim = 32
nFfn = 1536
nLayers = 6
nCpuFullMs = 36.6   # measured, same machine/seq (neural_gpu_routing guard)

StzEngineGpuInit($cStzGpuRuntime)
if StzEngineGpuIsAvailable() = 0
    ? "no GPU -- the spike needs the device"
    return
ok
? "device: " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

# --- resident operands (a real backbone holds exactly these) ---
hX = StzEngineGpuBufferNew(nSeq * nEmb * 4)        # activations
hW = StzEngineGpuBufferNew(nEmb * nEmb * 4)        # a 384x384 weight
hWup = StzEngineGpuBufferNew(nEmb * nFfn * 4)      # 384x1536
hWdn = StzEngineGpuBufferNew(nFfn * nEmb * 4)      # 1536x384
hMid = StzEngineGpuBufferNew(nSeq * nFfn * 4)      # ffn hidden
hOut = StzEngineGpuBufferNew(nSeq * nEmb * 4)
hQ = StzEngineGpuBufferNew(nSeq * nHeadDim * 4)    # one head slice
hK = StzEngineGpuBufferNew(nHeadDim * nSeq * 4)
hS = StzEngineGpuBufferNew(nSeq * nSeq * 4)        # scores
hV = StzEngineGpuBufferNew(nSeq * nHeadDim * 4)
hHo = StzEngineGpuBufferNew(nSeq * nHeadDim * 4)

aFill = []
for i = 1 to nSeq * nEmb
    aFill + 0.01
next
StzEngineGpuBufferUploadList(hX, aFill)

SpineOnce()   # warm (pipeline compiles)

nBest = 999999999
for r = 1 to 5
    nT0 = StzEngineWatchTimestampNs()
    SpineOnce()
    nMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
    if nMs < nBest
        nBest = nMs
    ok
next

nDisp = 6 * (4 + 2*nHeads + 2)
? ""
? "dispatches per forward (matmul spine only): " + nDisp
? "resident spine, warm-min: " + nBest + " ms"
? "CPU FULL forward (measured, same seq): " + nCpuFullMs + " ms"
? "ratio vs CPU full forward: " + (nCpuFullMs / nBest) + "x"
? ""
if nCpuFullMs / nBest >= 2
    ? "R1 PASSES (>= 2x): the backbone has headroom for its other kernels."
else
    ? "R1 FAILS (< 2x): the spine ALONE cannot clear the bar; the backbone"
    ? "                 (which only adds dispatches) is a NO-GO at this scale."
ok

# DIAGNOSTIC: split the spine -- 36 big projection/FFN matmuls vs the 144
# tiny per-head attention ones. If the tiny ones dominate, a batched
# attention kernel is the only thing that could move the verdict.
BigOnly()
nBig = 999999999
for r = 1 to 5
    nT0 = StzEngineWatchTimestampNs()
    BigOnly()
    nMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
    if nMs < nBig
        nBig = nMs
    ok
next
? ""
? "  big projections + FFN only (36 dispatches): " + nBig + " ms"
? "  per-head attention share (144 dispatches):  " + (nBest - nBig) + " ms"
? "  even at ZERO attention cost the ratio would be: " + (nCpuFullMs / nBig) + "x"

StzEngineGpuShutdown()

func SpineOnce
    StzEngineGpuBatchBegin()
    for L = 1 to nLayers
        # Q, K, V, attn_output projections
        for p = 1 to 4
            StzEngineGpuOpMatmul(hX, hW, hOut, nSeq, nEmb, nEmb)
        next
        # per-head attention: scores then context
        for h = 1 to nHeads
            StzEngineGpuOpMatmul(hQ, hK, hS, nSeq, nHeadDim, nSeq)
            StzEngineGpuOpMatmul(hS, hV, hHo, nSeq, nSeq, nHeadDim)
        next
        # FFN
        StzEngineGpuOpMatmul(hX, hWup, hMid, nSeq, nEmb, nFfn)
        StzEngineGpuOpMatmul(hMid, hWdn, hOut, nSeq, nFfn, nEmb)
    next
    StzEngineGpuBatchEnd()  # ONE submit for the whole spine
    StzEngineGpuSync()      # the ONE sync a resident backbone pays

func BigOnly
    StzEngineGpuBatchBegin()
    for L = 1 to nLayers
        for p = 1 to 4
            StzEngineGpuOpMatmul(hX, hW, hOut, nSeq, nEmb, nEmb)
        next
        StzEngineGpuOpMatmul(hX, hWup, hMid, nSeq, nEmb, nFfn)
        StzEngineGpuOpMatmul(hMid, hWdn, hOut, nSeq, nFfn, nEmb)
    next
    StzEngineGpuBatchEnd()
    StzEngineGpuSync()
