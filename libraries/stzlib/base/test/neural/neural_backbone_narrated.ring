# THE RESIDENT BACKBONE -- the whole BERT encoder on the GPU, one upload in
# and one pooled vector out (SOFTANZA_GPU_PLAN.md).
#
# Five kernels carry it: matmul+bias, a FUSED multi-head attention (one
# workgroup per head+query-row, so Q/K/V stay whole and no buffer offsets
# are needed), LayerNorm(x+residual), GELU, and an on-device mean-pool +
# L2 normalize -- so the readback is n_embd floats, not n_tok*n_embd.
# Every dispatch of the forward pass lands in ONE batched pass.
#
# VERIFIED AGAINST THE INDEPENDENT NUMPY REFERENCE, not against the CPU
# path: bert_parity_expected.ring was computed by a separate numpy forward
# (tools/gen_tiny_bert.py). A bug shared by both engine paths would still
# fail here -- which is the whole point of having ground truth.
#
# The band is NOT bit-parity and cannot be: this path computes GELU with
# the tanh approximation in f32 while ggml uses an f16 lookup table, and
# Q8_0 CPU matmuls quantize activations. The assertion is cosine + a
# measured absolute band, the same standard the per-node route met.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(12)

? "-- Scene 1: the tiny model, checked against numpy ground truth --"
chk("tiny_bert loads", StzEngineNeuralModelLoad("tiny_bert.gguf") = 1)
chk("the backbone recognizes the shape (learned positions, plain FFN)",
    StzEngineNeuralBackboneSupported() = 1)

aCases = []
if fexists("bert_parity_expected.ring")
    load "bert_parity_expected.ring"
    aCases = aBertParityCases
ok
chk("the numpy reference fixture is present", len(aCases) > 0)

nMaxAbs = 0
nMinCos = 2
nRan = 0
for c = 1 to len(aCases)
    cText = aCases[c][1]
    aWant = aCases[c][3]
    aGot = StzEngineNeuralBackboneEmbed(cText)
    if len(aGot) = 0
        loop      # no device: scene 3 covers that path
    ok
    nRan++
    _nCos_ = 0
    for i = 1 to len(aWant)
        _nCos_ += aGot[i] * aWant[i]
        _nD_ = fabs(aGot[i] - aWant[i])
        if _nD_ > nMaxAbs
            nMaxAbs = _nD_
        ok
    next
    if _nCos_ < nMinCos
        nMinCos = _nCos_
    ok
next

if nRan = 0
    ? "  NO GPU ON THIS MACHINE -- the backbone never ran; scene 3 is the CI coverage"
else
    ? "  sentences run through the GPU backbone: " + nRan
    ? "  worst cosine vs numpy: " + nMinCos
    ? "  worst |diff| vs numpy: " + nMaxAbs
    chk("every sentence matched the INDEPENDENT reference (cos >= 0.9999)",
        nMinCos >= 0.9999)
    chk("...and elementwise within 2e-3 (f32 tanh-GELU vs the f16 table)",
        nMaxAbs < 0.002)

    ? ""
    ? "-- Scene 2: it is a RESIDENT chain -- the transfer counter says so --"
    # one upload of n_tok*n_embd, one readback of n_embd. Nothing else
    # crosses: no per-layer round trips, which is the entire design claim.
    nTok = StzEngineNeuralTokenize(aCases[1][1])
    StzEngineNeuralGpuCountersReset()
    StzEngineNeuralBackboneEmbed(aCases[1][1])
    # counters 2.. map onto the gpu layer: 2+2 = transfer bytes, 2+6 = submits
    nBytes = StzEngineNeuralGpuCounter(4)
    nWantBytes = (nTok * 32 * 4) + (32 * 4)
    ? "  bytes across the bus: " + nBytes + "   (upload " + (nTok * 32 * 4) +
        " + readback " + (32 * 4) + " = " + nWantBytes + ")"
    chk("EXACTLY one upload + one pooled readback crossed the bus", nBytes = nWantBytes)
    nSubs = StzEngineNeuralGpuCounter(8)
    ? "  queue submits for the whole encoder: " + nSubs
    chk("the encoder is ONE batched submit (+1 for the readback copy)", nSubs <= 2)

    ? ""
    ? "-- Scene 3: determinism, and the refusals --"
    aA = StzEngineNeuralBackboneEmbed(aCases[2][1])
    aB = StzEngineNeuralBackboneEmbed(aCases[2][1])
    bSame = TRUE
    for i = 1 to len(aA)
        if aA[i] != aB[i]
            bSame = FALSE
        ok
    next
    chk("the same text gives an identical vector", bSame)
ok

StzEngineNeuralModelFree()
chk("with no model loaded, the backbone reports unsupported",
    StzEngineNeuralBackboneSupported() = 0)
aNone = StzEngineNeuralBackboneEmbed("anything")
chk("...and refuses by returning nothing (the caller keeps its CPU path)",
    len(aNone) = 0)

cReranker = "../../../models/jina-reranker-v1-turbo-en-Q8_0.gguf"
if fexists(cReranker)
    ? ""
    ? "-- Scene 4: an out-of-scope architecture is REFUSED, not mishandled --"
    StzEngineNeuralModelLoad(cReranker)
    chk("jina-bert-v2 (ALiBi + GEGLU) is recognized as unsupported",
        StzEngineNeuralBackboneSupported() = 0)
    chk("...and the backbone declines rather than computing nonsense",
        len(StzEngineNeuralBackboneEmbed("a query")) = 0)
    StzEngineNeuralModelFree()
ok

cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"
if fexists(cModel) and nRan > 0
    ? ""
    ? "-- Scene 5: a real MiniLM -- agreement with the CPU path, and speed --"
    StzEngineNeuralModelLoad(cModel)
    cText = ""
    for i = 1 to 13
        cText += "the quick brown fox jumps over the lazy dog and runs away "
    next
    nDim = StzEngineNeuralEmbed(cText)
    aCpu = []
    for i = 1 to nDim
        aCpu + StzEngineNeuralEmbedAt(i - 1)
    next
    aBb = StzEngineNeuralBackboneEmbed(cText)
    chk("the backbone ran on MiniLM (384 dims)", len(aBb) = nDim)
    if len(aBb) = nDim
        nCos = 0
        for i = 1 to nDim
            nCos += aCpu[i] * aBb[i]
        next
        ? "  cos(cpu, backbone) = " + nCos
        chk("semantic parity with the CPU forward (cos >= 0.999)", nCos >= 0.999)
    ok
    # timing, warm min-of-3
    nT0 = StzEngineWatchTimestampNs()
    for r = 1 to 3
        StzEngineNeuralEmbed(cText)
    next
    nCpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000 / 3
    StzEngineNeuralBackboneEmbed(cText)
    nT0 = StzEngineWatchTimestampNs()
    for r = 1 to 3
        StzEngineNeuralBackboneEmbed(cText)
    next
    nBbMs = (StzEngineWatchTimestampNs() - nT0) / 1000000 / 3
    ? "  CPU forward " + nCpuMs + " ms vs resident backbone " + nBbMs +
        " ms  (" + (nCpuMs / nBbMs) + "x)"
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
