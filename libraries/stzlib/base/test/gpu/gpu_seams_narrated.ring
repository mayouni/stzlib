# The first silent seam -- G3 of the GPU plane (SOFTANZA_GPU_PLAN.md).
#
# stzVectorIndex.SearchExact() now runs its full scan on the GPU when the
# corpus earned residency: uploaded once at build time, each query moves d
# floats in and k pairs out -- the compute-dense shape G0 approved. The
# user calls the SAME method and notices nothing but speed.
#
# What this guard asserts -- BOTH SIDES OF THE THRESHOLD, mechanism first:
#   - below the calibrated line: NO dispatch happens (the counter is the
#     witness), no corpus goes resident, the answer is the CPU's
#   - above the line: the corpus IS resident (live-buffer counter),
#     SearchExact MOVES the dispatch counter, and the answer matches the
#     forced-CPU answer -- indices EXACTLY (integer grid; both sides break
#     ties on the lower index), distances exactly on integers and within
#     the measured band on fractions
#   - :Cosine stays CPU even above the line (the CPU index normalizes
#     internally; raw rows on the GPU would compute WRONG distances)
#   - the approximate path never touches the GPU, resident or not
#   - a shutdown mid-life falls back to CPU with the SAME contract
#
# Loads the full stzBase: the seam lives in a library face, so this guard
# deliberately runs the real face, not the engine bridge.

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_DISP = 0
C_LIVE = 8

pr()

decimals(12)

? "-- Scene 0: a device, and a clean slate --"
nInit = StzEngineGpuInit($cStzGpuRuntime)
if StzEngineGpuIsAvailable() = 0
    ? "  NO GPU ON THIS MACHINE -- the seam can never engage; asserting the CPU contract only"
else
    ? "  device: " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
ok

? ""
? "-- Scene 1: BELOW the line, the CPU keeps the work (the negative side) --"
StzEngineGpuCalibSet("pairdist", 4000000)
StzEngineGpuCountersReset()
nLive0 = StzEngineGpuCounter(C_LIVE)
aSmall = BuildCorpus(100, 8)         # 800 << 4,000,000
oIdxS = new stzVectorIndex(aSmall)
aResS = oIdxS.SearchExact(BuildQuery(8, 3), 5)
chk("small-corpus SearchExact answers (5 hits)", len(aResS) = 5)
chk("NO dispatch happened below the line", StzEngineGpuCounter(C_DISP) = 0)
chk("NO corpus went resident", StzEngineGpuCounter(C_LIVE) = nLive0)

if StzEngineGpuIsAvailable() = 1

    ? ""
    ? "-- Scene 2: ABOVE the line, the GPU takes the scan (the positive side) --"
    StzEngineGpuCalibSet("pairdist", 1000)
    StzEngineGpuCountersReset()
    nLive0 = StzEngineGpuCounter(C_LIVE)
    aBig = BuildCorpus(300, 64)      # 19200 > 1000
    oIdxG = new stzVectorIndex(aBig)
    aQ1 = BuildQuery(64, 3)
    aResG = oIdxG.SearchExact(aQ1, 7)
    chk("resident corpus: 3 device buffers live (corpus+query+dist)",
        StzEngineGpuCounter(C_LIVE) = nLive0 + 3)
    nDisp1 = StzEngineGpuCounter(C_DISP)
    chk("SearchExact MOVED the dispatch counter (the mechanism, not the vibe)", nDisp1 > 0)
    chk("7 hits", len(aResG) = 7)

    # the forced-CPU twin: same data, threshold pushed out of reach BEFORE build
    StzEngineGpuCalibSet("pairdist", 999999999)
    oIdxC = new stzVectorIndex(aBig)
    aResC = oIdxC.SearchExact(aQ1, 7)
    bSameIdx = TRUE
    bSameDist = TRUE
    for i = 1 to 7
        if aResG[i][1] != aResC[i][1]
            bSameIdx = FALSE
        ok
        if aResG[i][2] != aResC[i][2]
            bSameDist = FALSE
        ok
    next
    chk("GPU and CPU name the SAME neighbours, same order", bSameIdx)
    chk("and the SAME integer distances, exactly", bSameDist)

    # more queries through the resident index: each moves the counter
    nDispB = StzEngineGpuCounter(C_DISP)
    for q = 1 to 5
        oIdxG.SearchExact(BuildQuery(64, q + 10), 3)
    next
    chk("5 more exact queries = 5 more dispatches",
        StzEngineGpuCounter(C_DISP) = nDispB + 5)

    ? ""
    ? "-- Scene 3: the approximate path never touches the GPU --"
    nDispB = StzEngineGpuCounter(C_DISP)
    oIdxG.Search(aQ1, 5)
    oIdxG.SearchWithBudget(aQ1, 5, 100)
    chk("Search()/SearchWithBudget() moved NOTHING (tree walk stays CPU)",
        StzEngineGpuCounter(C_DISP) = nDispB)

    ? ""
    ? "-- Scene 4: fractional parity -- indices exact, distances banded --"
    StzEngineGpuCalibSet("pairdist", 1000)
    aFrac = []
    for i = 0 to 199
        _aRow_ = []
        for j = 0 to 63
            _aRow_ + (((i*31 + j*17) % 251) / 251.0)
        next
        aFrac + _aRow_
    next
    oIdxF = new stzVectorIndex(aFrac)
    aQF = []
    for j = 0 to 63
        aQF + (((j*7) % 251) / 251.0)
    next
    aResGF = oIdxF.SearchExact(aQF, 5)
    StzEngineGpuCalibSet("pairdist", 999999999)
    oIdxFC = new stzVectorIndex(aFrac)
    aResCF = oIdxFC.SearchExact(aQF, 5)
    bSameIdx = TRUE
    nMaxRel = 0
    for i = 1 to 5
        if aResGF[i][1] != aResCF[i][1]
            bSameIdx = FALSE
        ok
        _nRel_ = fabs(aResGF[i][2] - aResCF[i][2]) / aResCF[i][2]
        if _nRel_ > nMaxRel nMaxRel = _nRel_ ok
    next
    ? "  measured distance rel error (f32 corpus vs f64 scan): " + nMaxRel
    chk("same neighbours on fractional data", bSameIdx)
    chk("distance band: rel error < 1e-5 (f32 quantization; measured ~1e-7)",
        nMaxRel < 0.00001)

    ? ""
    ? "-- Scene 5: :Cosine keeps the CPU, even above the line --"
    StzEngineGpuCalibSet("pairdist", 1000)
    StzEngineGpuCountersReset()
    nLive0 = StzEngineGpuCounter(C_LIVE)
    oIdxCos = new stzVectorIndex(aBig)
    oIdxCos.SetMetric(:Cosine)
    aResCos = oIdxCos.SearchExact(aQ1, 5)
    chk(":Cosine SearchExact answers (5 hits)", len(aResCos) = 5)
    chk("no dispatch: the normalized index is the CPU's",
        StzEngineGpuCounter(C_DISP) = 0)
    chk("no residency either", StzEngineGpuCounter(C_LIVE) = nLive0)

    ? ""
    ? "-- Scene 6: shutdown mid-life -- the face falls back, the answer stands --"
    aRef = oIdxG.SearchExact(aQ1, 7)     # GPU answer while alive
    StzEngineGpuShutdown()
    aAfter = oIdxG.SearchExact(aQ1, 7)   # buffers dead -> silent CPU path
    bSame = TRUE
    for i = 1 to 7
        if aAfter[i][1] != aRef[i][1] or aAfter[i][2] != aRef[i][2]
            bSame = FALSE
        ok
    next
    chk("post-shutdown SearchExact answers IDENTICALLY through the CPU", bSame)
    chk("and the device really is gone", StzEngineGpuIsAvailable() = 0)
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

# a deterministic integer-grid corpus: distances come out integer-valued in
# f32 and f64 alike, so index parity is exact, not probabilistic
func BuildCorpus nCount, nDim
	_aV_ = []
	for _i_ = 0 to nCount-1
		_aRow_ = []
		for _j_ = 0 to nDim-1
			_aRow_ + ((_i_*7 + _j_*13 + (_i_*_j_) % 5) % 32)
		next
		_aV_ + _aRow_
	next
	return _aV_

func BuildQuery nDim, nSeed
	_aQ_ = []
	for _j_ = 0 to nDim-1
		_aQ_ + ((nSeed*11 + _j_*3) % 32)
	next
	return _aQ_
