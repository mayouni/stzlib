# The GPU op library -- G2 of the GPU plane (SOFTANZA_GPU_PLAN.md).
#
# Seven ops on the G1 lifecycle layer: matmulF32, pairwise squared-L2
# distance (the embedding kernel), axpby / hadamard / scale (the chain
# links G0 admitted ONLY inside resident chains), softmax, and the
# sum / dot reductions.
#
# Parity discipline, per the plan:
#   - EXACT WITNESSES first: integer-valued (or f32-exact fractional)
#     inputs where every intermediate is exactly representable in f32,
#     so GPU and CPU must agree to the BIT -- across drivers. A later
#     change that breaks an exact witness changed the math, full stop.
#   - TOLERANCE BANDS second, on f32-exact fractional data where only
#     accumulation ORDER differs: the band is SET FROM MEASUREMENT
#     (observed error printed by this guard, band = ~50x observed to
#     absorb driver variation, still orders of magnitude below any
#     wrong-math failure).
#   - NEGATIVE SIBLINGS: wrong-size buffers answer BAD_ARG, freed
#     buffers answer STALE, a shut-down device answers FALLBACK -- and
#     the happy path counts ZERO fallbacks.
#
# Standalone like the G1 guard (loads only the engine bridge): a broken
# face elsewhere in the library must not mask an op regression.

load "stdlib.ring"
$cEngineDir = "../../../engine"
load "../../../engine/stz_gpu.ring"

decimals(12)  # the measured-error printouts are the point; 2 decimals hides them

nPass = 0
nFail = 0

S_OK = 0
S_FALLBACK = 1
S_STALE = 2
S_BADARG = 3

C_FALL = 3

? "-- Scene 0: ops refuse the fallback way before Init --"
aRes = StzEngineGpuOpSum(1, 100)
chk("sum before Init answers [FALLBACK, 0]", aRes[1] = S_FALLBACK and aRes[2] = 0)

nInit = StzEngineGpuInit($cStzGpuRuntime)
if StzEngineGpuIsAvailable() = 0
    ? "  NO GPU ON THIS MACHINE -- parity scenes need a device; fallback scene above is the CI coverage"
else
    ? "  device: [" + StzEngineGpuSelectedAdapter() + "] " +
        StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
    StzEngineGpuCountersReset()

    ? ""
    ? "-- Scene 1: elementwise, exact by construction --"
    nN = 1000
    aA = []
    aB = []
    for i = 1 to nN
        aA + ((i-1) / 2.0)
        aB + ((i-1) / 4.0)
    next
    hA = StzEngineGpuBufferNew(nN * 4)
    hB = StzEngineGpuBufferNew(nN * 4)
    hOut = StzEngineGpuBufferNew(nN * 4)
    chk("buffers up", hA > 0 and hB > 0 and hOut > 0)
    chk("upload a", StzEngineGpuBufferUploadList(hA, aA) = S_OK)
    chk("upload b", StzEngineGpuBufferUploadList(hB, aB) = S_OK)

    # axpby: 1.5*(k/2) - 0.25*(k/4) = 0.6875k -- 11/16, exact in f32
    chk("axpby dispatches", StzEngineGpuOpAxpby(1.5, hA, -0.25, hB, hOut, nN) = S_OK)
    aOut = StzEngineGpuBufferDownloadList(hOut, nN)
    bOk = TRUE
    for i = 1 to nN
        if aOut[i] != 0.6875 * (i-1)
            bOk = FALSE
            exit
        ok
    next
    chk("axpby EXACT: out[k] = 0.6875k, all " + nN + " elements", bOk)

    # hadamard: (k/2)*(k/4) = k^2/8 -- k^2 < 2^24, exact
    chk("mul dispatches", StzEngineGpuOpMul(hA, hB, hOut, nN) = S_OK)
    aOut = StzEngineGpuBufferDownloadList(hOut, nN)
    bOk = TRUE
    for i = 1 to nN
        if aOut[i] != ((i-1) * (i-1)) / 8.0
            bOk = FALSE
            exit
        ok
    next
    chk("mul EXACT: out[k] = k^2/8", bOk)

    # scale in place: doubling is exact
    chk("scale dispatches", StzEngineGpuOpScaleInPlace(hOut, 2.0, nN) = S_OK)
    aOut = StzEngineGpuBufferDownloadList(hOut, nN)
    bOk = TRUE
    for i = 1 to nN
        if aOut[i] != ((i-1) * (i-1)) / 4.0
            bOk = FALSE
            exit
        ok
    next
    chk("scale EXACT: doubled in place", bOk)
    StzEngineGpuBufferFree(hA)
    StzEngineGpuBufferFree(hB)
    StzEngineGpuBufferFree(hOut)

    ? ""
    ? "-- Scene 2: matmul, exact integer witnesses (square AND ragged) --"
    # 32x32, entries 0..7: every product <= 49, every sum <= 1568 -- integers,
    # exact in f32, so equality is the assertion.
    nM = 32
    aMa = []
    aMb = []
    for r = 0 to nM-1
        for cc = 0 to nM-1
            aMa + ((r*7 + cc) % 8)
            aMb + ((r*3 + cc) % 8)
        next
    next
    hMa = StzEngineGpuBufferNew(nM * nM * 4)
    hMb = StzEngineGpuBufferNew(nM * nM * 4)
    hMc = StzEngineGpuBufferNew(nM * nM * 4)
    StzEngineGpuBufferUploadList(hMa, aMa)
    StzEngineGpuBufferUploadList(hMb, aMb)
    chk("matmul 32x32 dispatches", StzEngineGpuOpMatmul(hMa, hMb, hMc, nM, nM, nM) = S_OK)
    aMc = StzEngineGpuBufferDownloadList(hMc, nM * nM)
    bOk = TRUE
    for r = 0 to nM-1
        for cc = 0 to nM-1
            _nRef_ = 0
            for kk = 0 to nM-1
                _nRef_ += aMa[r*nM + kk + 1] * aMb[kk*nM + cc + 1]
            next
            if aMc[r*nM + cc + 1] != _nRef_
                bOk = FALSE
                exit 2
            ok
        next
    next
    chk("matmul 32x32 EXACT against the Ring triple loop (1024 entries)", bOk)
    StzEngineGpuBufferFree(hMa)
    StzEngineGpuBufferFree(hMb)
    StzEngineGpuBufferFree(hMc)

    # ragged 20x48x36: exercises the tile TAILS (none of m,k,n is a
    # multiple of 16) -- the select() guards, not just the happy tiles
    nMm = 20
    nMk = 48
    nMn = 36
    aMa = []
    aMb = []
    for r = 0 to nMm-1
        for cc = 0 to nMk-1
            aMa + ((r*5 + cc*3) % 8)
        next
    next
    for r = 0 to nMk-1
        for cc = 0 to nMn-1
            aMb + ((r*2 + cc*7) % 8)
        next
    next
    hMa = StzEngineGpuBufferNew(nMm * nMk * 4)
    hMb = StzEngineGpuBufferNew(nMk * nMn * 4)
    hMc = StzEngineGpuBufferNew(nMm * nMn * 4)
    StzEngineGpuBufferUploadList(hMa, aMa)
    StzEngineGpuBufferUploadList(hMb, aMb)
    chk("ragged matmul 20x48x36 dispatches", StzEngineGpuOpMatmul(hMa, hMb, hMc, nMm, nMk, nMn) = S_OK)
    aMc = StzEngineGpuBufferDownloadList(hMc, nMm * nMn)
    bOk = TRUE
    for r = 0 to nMm-1
        for cc = 0 to nMn-1
            _nRef_ = 0
            for kk = 0 to nMk-1
                _nRef_ += aMa[r*nMk + kk + 1] * aMb[kk*nMn + cc + 1]
            next
            if aMc[r*nMn + cc + 1] != _nRef_
                bOk = FALSE
                exit 2
            ok
        next
    next
    chk("ragged matmul EXACT -- the tile tails are guarded", bOk)
    StzEngineGpuBufferFree(hMa)
    StzEngineGpuBufferFree(hMb)
    StzEngineGpuBufferFree(hMc)

    ? ""
    ? "-- Scene 3: matmul tolerance band on NON-DYADIC data --"
    # /251 values are NOT exactly representable in f32, so this measures the
    # real parity situation a silent seam faces: Ring f64 data quantized to
    # f32 on upload, then accumulated in f32 -- against the f64 reference.
    # (First draft used /256 dyadics and measured a literal ZERO: every
    # intermediate was exact and the "tolerance" scene tested nothing.)
    nT = 64
    aMa = []
    aMb = []
    for r = 0 to nT-1
        for cc = 0 to nT-1
            aMa + (((r*31 + cc*17) % 251) / 251.0)
            aMb + (((r*13 + cc*41) % 251) / 251.0)
        next
    next
    hMa = StzEngineGpuBufferNew(nT * nT * 4)
    hMb = StzEngineGpuBufferNew(nT * nT * 4)
    hMc = StzEngineGpuBufferNew(nT * nT * 4)
    StzEngineGpuBufferUploadList(hMa, aMa)
    StzEngineGpuBufferUploadList(hMb, aMb)
    chk("matmul 64x64 fractional dispatches", StzEngineGpuOpMatmul(hMa, hMb, hMc, nT, nT, nT) = S_OK)
    aMc = StzEngineGpuBufferDownloadList(hMc, nT * nT)
    nMaxRel = 0
    for r = 0 to nT-1
        for cc = 0 to nT-1
            _nRef_ = 0
            for kk = 0 to nT-1
                _nRef_ += aMa[r*nT + kk + 1] * aMb[kk*nT + cc + 1]
            next
            if _nRef_ != 0
                _nRel_ = fabs(aMc[r*nT + cc + 1] - _nRef_) / _nRef_
                if _nRel_ > nMaxRel nMaxRel = _nRel_ ok
            ok
        next
    next
    ? "  measured max rel error (k=64, f32 accumulation vs f64): " + nMaxRel
    chk("matmul band: rel error < 1e-5 (measured 4.05e-7 on the 3050, band = 25x)", nMaxRel < 0.00001)
    StzEngineGpuBufferFree(hMa)
    StzEngineGpuBufferFree(hMb)
    StzEngineGpuBufferFree(hMc)

    ? ""
    ? "-- Scene 4: pairwise distance, exact integer witnesses --"
    # the embedding kernel: D[i][j] = sum_k (A[i][k]-B[j][k])^2. Integer
    # coords 0..9 over d=16 -> distances <= 16*81 = 1296, integers, exact.
    nPm = 8
    nPn = 12
    nPd = 16
    aPa = []
    aPb = []
    for r = 0 to nPm-1
        for cc = 0 to nPd-1
            aPa + ((r*3 + cc*5) % 10)
        next
    next
    for r = 0 to nPn-1
        for cc = 0 to nPd-1
            aPb + ((r*7 + cc*2) % 10)
        next
    next
    hPa = StzEngineGpuBufferNew(nPm * nPd * 4)
    hPb = StzEngineGpuBufferNew(nPn * nPd * 4)
    hPd = StzEngineGpuBufferNew(nPm * nPn * 4)
    StzEngineGpuBufferUploadList(hPa, aPa)
    StzEngineGpuBufferUploadList(hPb, aPb)
    chk("pairdist 8x12 d=16 dispatches", StzEngineGpuOpPairDist(hPa, hPb, hPd, nPm, nPn, nPd) = S_OK)
    aPo = StzEngineGpuBufferDownloadList(hPd, nPm * nPn)
    bOk = TRUE
    for r = 0 to nPm-1
        for cc = 0 to nPn-1
            _nRef_ = 0
            for kk = 0 to nPd-1
                _nD_ = aPa[r*nPd + kk + 1] - aPb[cc*nPd + kk + 1]
                _nRef_ += _nD_ * _nD_
            next
            if aPo[r*nPn + cc + 1] != _nRef_
                bOk = FALSE
                exit 2
            ok
        next
    next
    chk("pairdist EXACT (96 pairs)", bOk)
    StzEngineGpuBufferFree(hPa)
    StzEngineGpuBufferFree(hPb)
    StzEngineGpuBufferFree(hPd)

    # ragged d=10, m=5, n=7 -- dimension tail inside one tile
    nPm = 5
    nPn = 7
    nPd = 10
    aPa = []
    aPb = []
    for r = 0 to nPm-1
        for cc = 0 to nPd-1
            aPa + ((r*4 + cc*3) % 9)
        next
    next
    for r = 0 to nPn-1
        for cc = 0 to nPd-1
            aPb + ((r*5 + cc*6) % 9)
        next
    next
    hPa = StzEngineGpuBufferNew(nPm * nPd * 4)
    hPb = StzEngineGpuBufferNew(nPn * nPd * 4)
    hPd = StzEngineGpuBufferNew(nPm * nPn * 4)
    StzEngineGpuBufferUploadList(hPa, aPa)
    StzEngineGpuBufferUploadList(hPb, aPb)
    chk("ragged pairdist 5x7 d=10 dispatches", StzEngineGpuOpPairDist(hPa, hPb, hPd, nPm, nPn, nPd) = S_OK)
    aPo = StzEngineGpuBufferDownloadList(hPd, nPm * nPn)
    bOk = TRUE
    for r = 0 to nPm-1
        for cc = 0 to nPn-1
            _nRef_ = 0
            for kk = 0 to nPd-1
                _nD_ = aPa[r*nPd + kk + 1] - aPb[cc*nPd + kk + 1]
                _nRef_ += _nD_ * _nD_
            next
            if aPo[r*nPn + cc + 1] != _nRef_
                bOk = FALSE
                exit 2
            ok
        next
    next
    chk("ragged pairdist EXACT -- the d-tail is guarded", bOk)
    StzEngineGpuBufferFree(hPa)
    StzEngineGpuBufferFree(hPb)
    StzEngineGpuBufferFree(hPd)

    ? ""
    ? "-- Scene 5: reductions -- exact on integers, banded on fractions --"
    nN = 100000
    aV = []
    nRefSum = 0
    for i = 1 to nN
        _v_ = (i-1) % 16
        aV + _v_
        nRefSum += _v_
    next
    hV = StzEngineGpuBufferNew(nN * 4)
    StzEngineGpuBufferUploadList(hV, aV)
    aRes = StzEngineGpuOpSum(hV, nN)
    chk("sum status OK", aRes[1] = S_OK)
    chk("sum of 100000 integers EXACT: " + nRefSum, aRes[2] = nRefSum)

    # dot, exact ints
    nN2 = 4096
    aD1 = []
    aD2 = []
    nRefDot = 0
    for i = 1 to nN2
        _a_ = (i-1) % 8
        _b_ = (i+2) % 8
        aD1 + _a_
        aD2 + _b_
        nRefDot += _a_ * _b_
    next
    hD1 = StzEngineGpuBufferNew(nN2 * 4)
    hD2 = StzEngineGpuBufferNew(nN2 * 4)
    StzEngineGpuBufferUploadList(hD1, aD1)
    StzEngineGpuBufferUploadList(hD2, aD2)
    aRes = StzEngineGpuOpDot(hD1, hD2, nN2)
    chk("dot status OK", aRes[1] = S_OK)
    chk("dot of 4096 integer pairs EXACT: " + nRefDot, aRes[2] = nRefDot)
    StzEngineGpuBufferFree(hD1)
    StzEngineGpuBufferFree(hD2)

    # non-dyadic fractional sum: f32 quantization + accumulation order
    aV = []
    nRefSum = 0
    for i = 1 to nN
        _v_ = ((i * 37) % 251) / 251.0
        aV + _v_
        nRefSum += _v_
    next
    StzEngineGpuBufferUploadList(hV, aV)
    aRes = StzEngineGpuOpSum(hV, nN)
    nRel = fabs(aRes[2] - nRefSum) / nRefSum
    ? "  measured sum rel error (100k fractional): " + nRel
    chk("sum band: rel error < 5e-7 (measured 1.28e-8 on the 3050, band = 39x)", aRes[1] = S_OK and nRel < 0.0000005)
    StzEngineGpuBufferFree(hV)

    ? ""
    ? "-- Scene 6: softmax -- the probability properties + a measured band --"
    nS = 300
    aS = []
    for i = 1 to nS
        aS + (((i * 37) % 100) / 10.0)
    next
    hIn = StzEngineGpuBufferNew(nS * 4)
    hOut = StzEngineGpuBufferNew(nS * 4)
    StzEngineGpuBufferUploadList(hIn, aS)
    chk("softmax dispatches", StzEngineGpuOpSoftmax(hIn, hOut, nS) = S_OK)
    aSo = StzEngineGpuBufferDownloadList(hOut, nS)
    # reference in f64
    nMax = aS[1]
    for i = 2 to nS
        if aS[i] > nMax nMax = aS[i] ok
    next
    aRef = []
    nTot = 0
    for i = 1 to nS
        _e_ = exp(aS[i] - nMax)
        aRef + _e_
        nTot += _e_
    next
    nSumOut = 0
    nMaxRel = 0
    for i = 1 to nS
        _r_ = aRef[i] / nTot
        nSumOut += aSo[i]
        if _r_ > 0
            _nRel_ = fabs(aSo[i] - _r_) / _r_
            if _nRel_ > nMaxRel nMaxRel = _nRel_ ok
        ok
    next
    ? "  measured softmax max rel error: " + nMaxRel
    chk("softmax band: per-element rel error < 2e-5 (measured 8.06e-7 on the 3050, band = 25x)", nMaxRel < 0.00002)
    chk("probabilities sum to 1 within 1e-5", fabs(nSumOut - 1) < 0.00001)
    StzEngineGpuBufferFree(hIn)
    StzEngineGpuBufferFree(hOut)

    ? ""
    ? "-- Scene 7: a resident chain through the ops -- no syncs between links --"
    # upload once -> axpby -> mul -> scale -> sum -> one readback inside sum.
    # Every link is submit-only; correctness of the final scalar proves the
    # queue ordering carried the chain. (G0's whole case for the GPU.)
    nN = 2048
    aA = []
    aB = []
    for i = 1 to nN
        aA + ((i-1) % 32)
        aB + ((i-1) % 16)
    next
    hA = StzEngineGpuBufferNew(nN * 4)
    hB = StzEngineGpuBufferNew(nN * 4)
    hT1 = StzEngineGpuBufferNew(nN * 4)
    hT2 = StzEngineGpuBufferNew(nN * 4)
    StzEngineGpuBufferUploadList(hA, aA)
    StzEngineGpuBufferUploadList(hB, aB)
    chk("link 1: t1 = 2a + b", StzEngineGpuOpAxpby(2.0, hA, 1.0, hB, hT1, nN) = S_OK)
    chk("link 2: t2 = t1 .* b", StzEngineGpuOpMul(hT1, hB, hT2, nN) = S_OK)
    chk("link 3: t2 *= 0.5", StzEngineGpuOpScaleInPlace(hT2, 0.5, nN) = S_OK)
    aRes = StzEngineGpuOpSum(hT2, nN)
    nRefChain = 0
    for i = 1 to nN
        nRefChain += (2 * ((i-1) % 32) + ((i-1) % 16)) * ((i-1) % 16) * 0.5
    next
    chk("chain result EXACT: " + nRefChain, aRes[1] = S_OK and aRes[2] = nRefChain)
    chk("ZERO fallbacks through every scene so far (negative sibling)",
        StzEngineGpuCounter(C_FALL) = 0)
    StzEngineGpuBufferFree(hA)
    StzEngineGpuBufferFree(hB)
    StzEngineGpuBufferFree(hT1)
    StzEngineGpuBufferFree(hT2)

    ? ""
    ? "-- Scene 8: the negatives answer by NAME --"
    hSmall = StzEngineGpuBufferNew(16 * 4)
    hGone = StzEngineGpuBufferNew(64 * 4)
    StzEngineGpuBufferFree(hGone)
    chk("matmul into a too-small C answers BAD_ARG",
        StzEngineGpuOpMatmul(hSmall, hSmall, hSmall, 16, 16, 16) = S_BADARG)
    chk("op on a freed buffer answers STALE",
        StzEngineGpuOpScaleInPlace(hGone, 2.0, 64) = S_STALE)
    aRes = StzEngineGpuOpSum(hSmall, 0)
    chk("zero-length op answers BAD_ARG", aRes[1] = S_BADARG)
    StzEngineGpuBufferFree(hSmall)

    StzEngineGpuShutdown()
    aRes = StzEngineGpuOpDot(1, 2, 100)
    chk("after shutdown, dot answers [FALLBACK, 0]", aRes[1] = S_FALLBACK and aRes[2] = 0)
ok

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

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
