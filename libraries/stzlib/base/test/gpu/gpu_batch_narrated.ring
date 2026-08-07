# Batched passes -- the lifecycle layer's amortization of submission cost,
# and the prerequisite the resident-backbone spike proved necessary
# (SOFTANZA_GPU_PLAN.md, "THE RESIDENT BACKBONE").
#
# G0 measured ~60 us per submit+wait against ~9 us for a dispatch INSIDE a
# pass. A chain of many small ops therefore pays more in SUBMISSION than in
# work: the backbone spike's 144 tiny attention dispatches cost 11.3 ms
# unbatched and 4.7 ms batched.
#
# THE SUBTLE CORRECTNESS PROBLEM this guard exists for: the tile and params
# uniforms are written with queue.writeBuffer, which is ordered against
# SUBMITS -- not against dispatches inside one pass. A batch that shared one
# params buffer would give EVERY dispatch the LAST value written, silently.
# So each batched dispatch takes its own uniform slot from a pool. The
# assertion that proves it: a batch of ops with DIFFERENT parameters must
# produce exactly what the same ops produce unbatched.

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_SUB = 6      # queue submits
C_DISP = 0     # dispatches

pr()

decimals(12)

oG = new stzGpu
if NOT oG.IsAvailable()
    ? "  NO GPU ON THIS MACHINE -- batching needs the device"
else
    ? "  device: " + oG.DeviceName()

    ? ""
    ? "-- Scene 1: a batch is one submit, not N --"
    nN = 4096
    aA = []
    for i = 1 to nN
        aA + (i % 17)
    next
    hA = StzEngineGpuBufferNew(nN * 4)
    hB = StzEngineGpuBufferNew(nN * 4)
    aOuts = []
    for i = 1 to 8
        aOuts + StzEngineGpuBufferNew(nN * 4)
    next
    StzEngineGpuBufferUploadList(hA, aA)
    StzEngineGpuBufferUploadList(hB, aA)

    # warm the pipeline outside the counted window
    StzEngineGpuOpAxpby(1, hA, 1, hB, aOuts[1], nN)
    StzEngineGpuSync()

    StzEngineGpuCountersReset()
    for i = 1 to 8
        StzEngineGpuOpAxpby(i, hA, 1, hB, aOuts[i], nN)
    next
    StzEngineGpuSync()
    nSubsUnbatched = StzEngineGpuCounter(C_SUB)
    ? "  8 ops unbatched: " + nSubsUnbatched + " submits"
    chk("unbatched: one submit per op (8)", nSubsUnbatched = 8)

    aUnbatched = []
    for i = 1 to 8
        aUnbatched + StzEngineGpuBufferDownloadList(aOuts[i], nN)
    next

    StzEngineGpuCountersReset()
    chk("batch opens", StzEngineGpuBatchBegin() = 0)
    chk("and reports itself active", StzEngineGpuBatchActive() = 1)
    for i = 1 to 8
        StzEngineGpuOpAxpby(i, hA, 1, hB, aOuts[i], nN)
    next
    chk("batch closes", StzEngineGpuBatchEnd() = 0)
    chk("no longer active", StzEngineGpuBatchActive() = 0)
    StzEngineGpuSync()
    nSubsBatched = StzEngineGpuCounter(C_SUB)
    ? "  the same 8 ops batched: " + nSubsBatched + " submit"
    chk("batched: EXACTLY ONE submit for all 8 ops", nSubsBatched = 1)
    chk("all 8 dispatches still happened (the work was not dropped)",
        StzEngineGpuCounter(C_DISP) = 8)

    ? ""
    ? "-- Scene 2: THE UNIFORM-SLOT PROOF -- each op kept its OWN alpha --"
    # every op used a DIFFERENT alpha (i = 1..8). If the batch shared one
    # params buffer, every result would carry the LAST alpha (8) instead.
    bIdentical = TRUE
    bWouldHaveCollapsed = FALSE
    for i = 1 to 8
        aGot = StzEngineGpuBufferDownloadList(aOuts[i], nN)
        for j = 1 to nN
            if aGot[j] != aUnbatched[i][j]
                bIdentical = FALSE
            ok
        next
        # the "all got the last alpha" failure mode, named explicitly
        if i < 8 and aGot[2] = (8 * aA[2] + aA[2])
            bWouldHaveCollapsed = TRUE
        ok
    next
    chk("batched results are IDENTICAL to unbatched, op by op, element by element",
        bIdentical)
    chk("...and NOT collapsed onto the last op's parameter (the negative sibling)",
        NOT bWouldHaveCollapsed)

    ? ""
    ? "-- Scene 3: the amortization is real, and it is the backbone's key --"
    nBig = 64
    hM1 = StzEngineGpuBufferNew(nBig * nBig * 4)
    hM2 = StzEngineGpuBufferNew(nBig * nBig * 4)
    hM3 = StzEngineGpuBufferNew(nBig * nBig * 4)
    aM = []
    for i = 1 to nBig * nBig
        aM + 0.5
    next
    StzEngineGpuBufferUploadList(hM1, aM)
    StzEngineGpuBufferUploadList(hM2, aM)
    StzEngineGpuOpMatmul(hM1, hM2, hM3, nBig, nBig, nBig)
    StzEngineGpuSync()

    nUn = 999999
    for r = 1 to 3
        nT0 = StzEngineWatchTimestampNs()
        for i = 1 to 60
            StzEngineGpuOpMatmul(hM1, hM2, hM3, nBig, nBig, nBig)
        next
        StzEngineGpuSync()
        _n_ = (StzEngineWatchTimestampNs() - nT0) / 1000000
        if _n_ < nUn nUn = _n_ ok
    next
    nBa = 999999
    for r = 1 to 3
        nT0 = StzEngineWatchTimestampNs()
        StzEngineGpuBatchBegin()
        for i = 1 to 60
            StzEngineGpuOpMatmul(hM1, hM2, hM3, nBig, nBig, nBig)
        next
        StzEngineGpuBatchEnd()
        StzEngineGpuSync()
        _n_ = (StzEngineWatchTimestampNs() - nT0) / 1000000
        if _n_ < nBa nBa = _n_ ok
    next
    ? "  60 small matmuls: unbatched " + nUn + " ms, batched " + nBa + " ms  (" +
        (nUn / nBa) + "x)"
    chk("batching a chain of small ops is FASTER (the submission floor is real)",
        nBa < nUn)

    ? ""
    ? "-- Scene 4: the negatives --"
    chk("closing a batch that was never opened refuses", StzEngineGpuBatchEnd() = 3)
    chk("opening twice is idempotent, not an error",
        StzEngineGpuBatchBegin() = 0 and StzEngineGpuBatchBegin() = 0)
    StzEngineGpuBatchEnd()
    chk("a shutdown mid-batch does not strand the layer",
        _SurvivesShutdownMidBatch())

    StzEngineGpuShutdown()
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

# open a batch, pull the device out from under it, and confirm the layer is
# still usable afterwards (re-init, dispatch, correct answer)
func _SurvivesShutdownMidBatch
	StzEngineGpuBatchBegin()
	StzEngineGpuShutdown()
	if StzEngineGpuBatchActive() != 0
		return FALSE
	ok
	StzEngineGpuInit($cStzGpuRuntime)
	if StzEngineGpuIsAvailable() = 0
		return FALSE
	ok
	_h1_ = StzEngineGpuBufferNew(256 * 4)
	_h2_ = StzEngineGpuBufferNew(256 * 4)
	_a_ = []
	for _i_ = 1 to 256
		_a_ + 2
	next
	StzEngineGpuBufferUploadList(_h1_, _a_)
	if StzEngineGpuOpScaleInPlace(_h1_, 3, 256) != 0
		return FALSE
	ok
	_out_ = StzEngineGpuBufferDownloadList(_h1_, 256)
	StzEngineGpuBufferFree(_h1_)
	StzEngineGpuBufferFree(_h2_)
	return len(_out_) = 256 and _out_[1] = 6
