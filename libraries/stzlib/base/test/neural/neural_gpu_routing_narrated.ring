# GPU routing of the neural forward pass -- the constructive route G6
# recorded, delivered (SOFTANZA_GPU_PLAN.md).
#
# Big MUL_MAT nodes in ggml's graph are claimed by the wgpu plane compiled
# into stz_neural.dll (its OWN device -- per-DLL handle law), via ggml's
# extra-compute hook: weights dequantize + transpose ONCE and stay resident,
# activations stream through two reused buffers, and a work threshold
# (m*k*n) keeps every small shape -- including G0's killed decode matvec --
# on the CPU kernels.
#
# What this guard asserts, both sides, mechanism first:
#   - the TINY parity fixture never wakes the device: too small to even
#     attempt init (state stays UNTRIED) -- the bit-parity ground truth
#     keeps its CPU meaning
#   - on a real MiniLM (local models/, skipped gracefully without it):
#     above the line the hook CLAIMS nodes (claimed counter moves) and the
#     device goes LIVE; below the line it claims NOTHING; the two routes'
#     embeddings agree within a band SET FROM MEASUREMENT (NOT bit-parity:
#     ggml's Q8_0 CPU kernels quantize activations, the GPU path computes
#     full f32 -- different rounding by design)
#   - the GPU-routed path is deterministic, and the scalar-fallback
#     counter stays ZERO on the happy path (its negative sibling)
#
# THE TIMING VERDICT IS PART OF THE RECORD: per-node interception measured
# 0.45-0.67x on MiniLM (two runs) (36 claimed nodes, each paying upload+readback+sync while
# CPU ops interleave -- not a resident chain), so the SHIPPED default
# threshold (1.5e9 work) keeps small-model forwards entirely on CPU; the
# mechanism stands ready for multi-GFLOP nodes and for the resident-backbone
# follow-up.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(12)

# neural_gpu counters: 0 = claimed nodes, 1 = scalar fallbacks
C_CLAIMED = 0
C_SCALAR = 1

? "-- Scene 0: the knobs are live, the device untried --"
chk("threshold reads back (the MEASURED default: ~1.5 GFLOP break-even)",
    StzEngineNeuralGpuThreshold() = 1500000000)
chk("state = untried before any eligible matmul", StzEngineNeuralGpuState() = 0)

? ""
? "-- Scene 1: the tiny parity fixture never wakes the device --"
StzEngineNeuralGpuCountersReset()
chk("tiny_bert loads", StzEngineNeuralModelLoad("tiny_bert.gguf") = 1)
chk("it embeds", StzEngineNeuralEmbed("the cat sat on the mat") = 32)
chk("NO node was claimed (32-dim shapes are far below the line)",
    StzEngineNeuralGpuCounter(C_CLAIMED) = 0)
chk("the device was never even initialized (state still untried)",
    StzEngineNeuralGpuState() = 0)
StzEngineNeuralModelFree()

cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"
if NOT fexists(cModel)
    ? ""
    ? "  no local MiniLM -- the real-model scenes need models/; scene 1 is the CI coverage"
else
    ? ""
    ? "-- Scene 2: a real MiniLM -- the hook claims above the line, not below --"
    chk("MiniLM loads", StzEngineNeuralModelLoad(cModel) = 1)
    cText = ""
    for i = 1 to 13
        cText += "the quick brown fox jumps over the lazy dog and runs away "
    next

    # CPU route first: line pushed out of reach
    StzEngineNeuralGpuSetThreshold(1000000000000000)
    StzEngineNeuralGpuCountersReset()
    nDim = StzEngineNeuralEmbed(cText)
    chk("CPU-routed embed answers (384 dims)", nDim = 384)
    chk("below the line: ZERO nodes claimed", StzEngineNeuralGpuCounter(C_CLAIMED) = 0)
    aCpu = []
    for i = 1 to nDim
        aCpu + StzEngineNeuralEmbedAt(i - 1)
    next
    nT0 = StzEngineWatchTimestampNs()
    for r = 1 to 3
        StzEngineNeuralEmbed(cText)
    next
    nCpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000 / 3

    # GPU route: line low enough for the seq-130 attention/FFN shapes
    StzEngineNeuralGpuSetThreshold(1000000)
    StzEngineNeuralGpuCountersReset()
    nDim = StzEngineNeuralEmbed(cText)
    chk("GPU-routed embed answers (384 dims)", nDim = 384)
    nClaimed = StzEngineNeuralGpuCounter(C_CLAIMED)
    ? "  nodes claimed by the GPU in one forward pass: " + nClaimed
    chk("above the line: the hook CLAIMED matmul nodes", nClaimed > 0)
    chk("the device is LIVE", StzEngineNeuralGpuState() = 1)
    chk("and the scalar-fallback counter stayed ZERO (negative sibling)",
        StzEngineNeuralGpuCounter(C_SCALAR) = 0)
    aGpu = []
    for i = 1 to nDim
        aGpu + StzEngineNeuralEmbedAt(i - 1)
    next
    nT0 = StzEngineWatchTimestampNs()
    for r = 1 to 3
        StzEngineNeuralEmbed(cText)
    next
    nGpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000 / 3

    ? ""
    ? "-- Scene 3: the two routes agree (semantic parity, measured band) --"
    nCos = 0
    nMaxD = 0
    for i = 1 to 384
        nCos += aCpu[i] * aGpu[i]
        _nD_ = fabs(aCpu[i] - aGpu[i])
        if _nD_ > nMaxD
            nMaxD = _nD_
        ok
    next
    ? "  cos(cpu, gpu) = " + nCos + "   max |diff| = " + nMaxD
    chk("cosine parity >= 0.999 (Q8_0-CPU vs f32-GPU rounding differs by design)",
        nCos >= 0.999)
    # determinism of the routed path
    StzEngineNeuralEmbed(cText)
    bSame = TRUE
    for i = 1 to 384
        if StzEngineNeuralEmbedAt(i - 1) != aGpu[i]
            bSame = FALSE
        ok
    next
    chk("the GPU route is deterministic (same text, identical vector)", bSame)

    ? ""
    ? "  timing (informational, warm min-of-3): CPU " + nCpuMs +
        " ms/embed vs GPU-routed " + nGpuMs + " ms/embed  (" + (nCpuMs / nGpuMs) + "x)"

    # both sides again: the line back up, nothing claimed
    StzEngineNeuralGpuSetThreshold(1000000000000000)
    StzEngineNeuralGpuCountersReset()
    StzEngineNeuralEmbed(cText)
    chk("line restored: zero claims again", StzEngineNeuralGpuCounter(C_CLAIMED) = 0)
    # the SHIPPED default: MiniLM-class models stay CPU by measurement
    StzEngineNeuralGpuSetThreshold(1500000000)
    StzEngineNeuralGpuCountersReset()
    StzEngineNeuralEmbed(cText)
    chk("at the SHIPPED default, MiniLM claims nothing -- CPU keeps it, by measurement",
        StzEngineNeuralGpuCounter(C_CLAIMED) = 0)
    StzEngineNeuralModelFree()
ok

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func fabs n
	if n < 0 return -n ok
	return n
