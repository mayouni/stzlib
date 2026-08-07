# THE EMBEDDING SEAM -- the resident backbone, wired in silently.
#
# Every embedding in the library comes through StzEngineNeuralEmbed, and the
# ENGINE now decides its route: sequences long enough to pay for the GPU go
# to the resident backbone, everything else stays on ggml's CPU kernels.
# Callers -- EmbeddingOf(), the semantic index, stzText -- change nothing.
#
# THE LINE IS MEASURED, not guessed (RTX 3050, MiniLM-L6-v2):
#     tokens   11     20     29     47     74    119    182    254
#     ratio  0.755  1.021  1.341  1.585  1.671  1.567  1.942
# The backbone LOSES below ~20 tokens and only earns a margin from ~29, so
# the shipped gate is 32 -- past break-even with room, never at it.
#
# What this guard asserts, both sides, by MECHANISM (the route counters):
#   - a short text is served by the CPU, and the backbone counter does NOT move
#   - a long text is served by the BACKBONE, and that counter does
#   - both routes give the SAME answer (cosine parity), so the seam is silent
#   - the threshold governs: raise it and the same long text goes back to CPU
#   - the per-token states are INVALIDATED on the backbone route, because the
#     backbone produces only the pooled vector -- a stale token read would be
#     a silent wrong answer, and zero tokens is the honest one
#   - with no model / no device, everything routes CPU and still answers

load "../../stzBase.ring"

nPass = 0
nFail = 0

R_GPU = 0
R_CPU = 1

pr()

decimals(12)

cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"

? "-- Scene 1: the shipped gate is the measured one --"
chk("default threshold is 32 tokens (measured crossover ~29, break-even ~20)",
    StzEngineNeuralBackboneMinTokens() = 32)

if NOT fexists(cModel)
    ? "  no local MiniLM -- the seam scenes need it; the gate above is the CI coverage"
else
    StzEngineNeuralModelLoad(cModel)
    cShort = "a short sentence"
    cLong = ""
    for i = 1 to 8
        cLong += "the quick brown fox jumps over the lazy dog and runs away "
    next
    nShortTok = StzEngineNeuralTokenize(cShort)
    nLongTok = StzEngineNeuralTokenize(cLong)
    ? "  short text = " + nShortTok + " tokens ; long text = " + nLongTok + " tokens"

    ? ""
    ? "-- Scene 2: BELOW the line the CPU keeps it (the negative side) --"
    StzEngineNeuralBackboneRouteReset()
    nDim = StzEngineNeuralEmbed(cShort)
    chk("the short text embeds (384 dims)", nDim = 384)
    chk("the BACKBONE counter did not move", StzEngineNeuralBackboneRouteCount(R_GPU) = 0)
    chk("the CPU counter did", StzEngineNeuralBackboneRouteCount(R_CPU) = 1)
    aShortCpu = []
    for i = 1 to nDim
        aShortCpu + StzEngineNeuralEmbedAt(i - 1)
    next

    ? ""
    ? "-- Scene 3: ABOVE the line the backbone takes it (the positive side) --"
    StzEngineNeuralBackboneRouteReset()
    nDim = StzEngineNeuralEmbed(cLong)
    chk("the long text embeds (384 dims)", nDim = 384)
    chk("the BACKBONE served it", StzEngineNeuralBackboneRouteCount(R_GPU) = 1)
    chk("and the CPU did not", StzEngineNeuralBackboneRouteCount(R_CPU) = 0)
    aLongGpu = []
    for i = 1 to nDim
        aLongGpu + StzEngineNeuralEmbedAt(i - 1)
    next

    ? ""
    ? "-- Scene 4: the seam is SILENT -- both routes give the same answer --"
    # force the same long text onto the CPU by raising the line out of reach
    StzEngineNeuralBackboneSetMinTokens(100000)
    StzEngineNeuralBackboneRouteReset()
    StzEngineNeuralEmbed(cLong)
    chk("raising the line sends the SAME text back to the CPU (the gate governs)",
        StzEngineNeuralBackboneRouteCount(R_CPU) = 1 and
        StzEngineNeuralBackboneRouteCount(R_GPU) = 0)
    aLongCpu = []
    for i = 1 to 384
        aLongCpu + StzEngineNeuralEmbedAt(i - 1)
    next
    nCos = 0
    for i = 1 to 384
        nCos += aLongGpu[i] * aLongCpu[i]
    next
    ? "  cos(backbone route, cpu route) = " + nCos
    chk("the two routes agree (cos >= 0.999) -- callers cannot tell", nCos >= 0.999)
    StzEngineNeuralBackboneSetMinTokens(32)

    ? ""
    ? "-- Scene 5: the backbone route INVALIDATES the per-token states --"
    # the backbone yields only the pooled vector; leaving stale token states
    # readable would be a silent wrong answer for NER-shaped callers
    StzEngineNeuralEmbedTokens(cLong)          # populate token states (CPU path)
    chk("token states are populated by the token path", StzEngineNeuralTokenDim() = 384)
    StzEngineNeuralEmbed(cLong)                # backbone route
    chk("after a backbone embed, the token dim reads 0 -- not stale data",
        StzEngineNeuralTokenDim() = 0)

    ? ""
    ? "-- Scene 6: the library's own face benefits, unchanged --"
    StzEngineNeuralBackboneRouteReset()
    oTxt = new stzText(cLong)
    aVec = oTxt.EmbeddingVector()
    chk("stzText.EmbeddingVector() returns a 384-dim vector", len(aVec) = 384)
    chk("...and it came through the BACKBONE without the caller asking",
        StzEngineNeuralBackboneRouteCount(R_GPU) >= 1)

    ? ""
    ? "-- Scene 7: speed, at the face --"
    StzEngineNeuralBackboneSetMinTokens(100000)
    StzEngineNeuralEmbed(cLong)
    nT0 = StzEngineWatchTimestampNs()
    for r = 1 to 5
        StzEngineNeuralEmbed(cLong)
    next
    nCpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000 / 5
    StzEngineNeuralBackboneSetMinTokens(32)
    StzEngineNeuralEmbed(cLong)
    nT0 = StzEngineWatchTimestampNs()
    for r = 1 to 5
        StzEngineNeuralEmbed(cLong)
    next
    nGpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000 / 5
    ? "  " + nLongTok + " tokens: CPU " + nCpuMs + " ms vs routed " + nGpuMs +
        " ms  (" + (nCpuMs / nGpuMs) + "x)"
    chk("the routed path is faster at this length", nGpuMs < nCpuMs)

    StzEngineNeuralModelFree()
ok

? ""
? "-- Scene 8: with no model, everything routes CPU and still answers --"
StzEngineNeuralBackboneRouteReset()
nDim = StzEngineNeuralEmbed("no model is loaded")
chk("no model: the embed refuses the same way it always did", nDim = 0)
chk("...having gone the CPU way (no device work attempted)",
    StzEngineNeuralBackboneRouteCount(R_GPU) = 0)

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
