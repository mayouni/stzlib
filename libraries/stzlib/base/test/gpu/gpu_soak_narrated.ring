# GT3 -- THE LONG RUN (SOFTANZA_GPU_PLAN.md, GT3): the library layer across a device that
# closes and reopens, and under a loop that runs for minutes.
#
# The plan's criterion: "memory and handle counts are flat; a lost device is reported and
# recovered, not crashed". This guard asserts the MECHANISMS, each with its negative sibling:
#   - every compute module of the plane (the fft op, the checker, the scan, compaction, the radix
#     sort, the segmented reduction, the sparse product) keeps SOMETHING device-scoped between
#     calls (a twiddle table, a verifier's kernels, a scratch vector); when the device goes
#     those must be forgotten, not reused: the device is closed and reopened FIVE times and
#     every answer after each reopening must equal the answer before the first closing;
#   - while it is closed every op answers FALLBACK, counted, and nothing crashes;
#   - a close-hook registry that silently dropped a hook once it was full is a defect that
#     hides exactly here, so the number of hooks registered and the number DROPPED are both
#     asserted: nothing may be dropped;
#   - the live buffer count returns to its baseline after the scratch is given back, however
#     many closings and reopenings and however many iterations of the loop have gone by;
#   - no uncaptured device error is counted anywhere.
#
# The checker's SPEED verdict is not a correctness answer. `impossible` means a measured time fell below the
# device's measured floors (its own source records the same false alarm on a cold or contended device). Measured
# 2026-11-06 over two runs, 2,650 and 290 rounds: the checker said `impossible` instead of `verified` for a tiny
# correct kernel in 4 rounds of 2,940 (0.14%); the six compute modules never erred. The first run's three all fell
# within 3 rounds of a reopening, which looked like a cause, and the second run's one did not (three of three
# landing there by luck is about 6%), so NO claim is made about reopening: the guard keeps the verdict apart from
# the answers, treats `verified` and `impossible` as "the checker found no mismatch", fails on a verdict of any
# other kind, and bounds the plain RATE of `impossible` (under 2%) and prints it.
#
# What the memory checks can see: the process's resident memory mixes the ENGINE's allocations with
# Ring's own heap, which grows in steps as it builds lists (measured 2026-11-06: 325 to 455 MB in one
# step and then flat, for list churn alone with no GPU). So scene 2 bounds the whole process loosely, and
# scene 3 runs the device ops ALONE on resident buffers, no Ring list built in its loop, where the engine's
# own memory is the only thing that can move (measured: 320 to 325 MB over 40 s and 27,838 rounds).
#
# The loop's length is a parameter (SOAK_SECONDS in the environment, default 60) so the same
# guard is a minute in a gate and an hour on a quiet machine the author has set aside for it:
# a long run holds the GPU, and a second process that uses it at the same time has crashed the
# driver before (the image desk's mailbox note of 2026-11-03).
#
# Run with Ring++: rnxc gpu_soak_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSkip = 0

pr()

decimals(6)
NLc = char(10)

? "-- Scene 0: before there is a device --"
chk("an op answers FALLBACK before Init", StzEngineGpuOpScan(1, 2, 100, 0) = 1)

oG = new stzGpu
bDevice = oG.IsAvailable()
if NOT bDevice
	? "  NO GPU ON THIS MACHINE -- the scenes below need a device; the fallback scene above is the CI coverage"
else
	? "  device: [" + StzEngineGpuSelectedAdapter() + "] " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

	? ""
	? "-- Scene 1: every compute module across five closings and reopenings of the device --"
	$t0 = clock()
	StzEngineGpuCountersReset()
	aRound1 = _Round(oG)
	chk("round 1 (before any closing): the fft op, the checker, the scan, compaction, the sort, the segmented reduction and the sparse product answer: " + left(aRound1[1], 90), aRound1[2])
	nHooks1 = StzEngineGpuCloseHooks(0)
	? "  close hooks registered after round 1: " + nHooks1 + ", dropped: " + StzEngineGpuCloseHooks(1)
	# what stays on the device after the scratch is given back is what is KEPT ON PURPOSE (the fft op's twiddle
	# table); FLAT means every later round, after every closing, ends with the same count
	StzEngineGpuCompactRelease()
	StzEngineGpuSortRelease()
	StzEngineGpuSegScanRelease()
	nFlat = StzEngineGpuCounter(8)
	? "  live buffers after round 1 with the scratch given back: " + nFlat + " (the fft op keeps its twiddle table on purpose)"
	for nCycle = 1 to 5
		StzEngineGpuShutdown()
		bDown = (StzEngineGpuIsAvailable() = 0)
		nFb0 = StzEngineGpuCounter(3)
		bFb = (StzEngineGpuOpScan(1, 2, 100, 0) = 1) and (StzEngineGpuOpSort(1, 2, 100, 0) = 1) and (StzEngineGpuOpSpmv(1, 2, 3, 4, 5, 10, 10, 0) = 1)
		StzEngineGpuInit($tStzGpuRuntime)
		bUp = (StzEngineGpuIsAvailable() = 1)
		aR = _Round(oG)
		StzEngineGpuCompactRelease()
		StzEngineGpuSortRelease()
		StzEngineGpuSegScanRelease()
		bFlat = (StzEngineGpuCounter(8) = nFlat)
		? "  closing " + nCycle + ": the checker's verdict on its first round after the reopening: " + aR[4]
		chk("closing " + nCycle + ": the device is down, three ops answer FALLBACK, it reopens, every answer is the first round's, and the live buffers are as flat as after round 1 (" + StzEngineGpuCounter(8) + " of " + nFlat + ")", bDown and bFb and bUp and aR[2] and aR[1] = aRound1[1] and bFlat)
	next
	chk("no hook was dropped: the registry held every module that registered one (" + StzEngineGpuCloseHooks(0) + " registered, " + StzEngineGpuCloseHooks(1) + " dropped)", StzEngineGpuCloseHooks(1) = 0)
	chk("no uncaptured device error was counted across the five closings", StzEngineGpuCounter(9) = 0)
	chk("after five closings and reopenings the live buffers are exactly what they were after the first round (" + nFlat + ")", StzEngineGpuCounter(8) = nFlat)
	? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 2: the loop, for as long as SOAK_SECONDS says (default 60) --"
	$t0 = clock()
	nSec = 0 + sysget("SOAK_SECONDS")
	if nSec <= 0
		nSec = 60
	ok
	? "  running for " + nSec + " seconds: a round of every module, the device closed and reopened every tenth round"
	StzEngineGpuCountersReset()
	nStart = StzEngineWatchTimestampNs()
	nRound = 0
	nClosings = 0
	nWrong = 0
	nCompileMoved = 0
	nLiveMoved = 0
	nPrevCompile = 0 - 1
	nLastSample = 0
	aRss = []
	aWrongAt = []
	nImpossible = 0
	while (StzEngineWatchTimestampNs() - nStart) / 1000000000 < nSec
		nRound++
		if nRound % 10 = 0
			StzEngineGpuShutdown()
			StzEngineGpuOpScan(1, 2, 100, 0)
			StzEngineGpuOpSort(1, 2, 100, 0)
			StzEngineGpuOpSpmv(1, 2, 3, 4, 5, 10, 10, 0)
			StzEngineGpuInit($tStzGpuRuntime)
			nClosings++
			nPrevCompile = 0 - 1
		ok
		aR = _Round(oG)
		if aR[4] = "impossible"
			nImpossible++
		ok
		if NOT aR[2] or aR[1] != aRound1[1]
			nWrong++
			if len(aWrongAt) < 5
				aWrongAt + ("round " + nRound + " (" + (nRound % 10) + " since the last closing; errors " + StzEngineGpuCounter(9) + "): " + aR[3] + " | " + aR[1] + " | the device says: " + left(StzEngineGpuLastError(), 80))
			ok
		ok
		nC = StzEngineGpuCounter(4)
		if nPrevCompile >= 0 and nC != nPrevCompile
			nCompileMoved++
		ok
		nPrevCompile = nC
		if nRound % 5 = 0
			StzEngineGpuCompactRelease()
			StzEngineGpuSortRelease()
			StzEngineGpuSegScanRelease()
			if StzEngineGpuCounter(8) != nFlat
				nLiveMoved++
			ok
		ok
		nT = floor((StzEngineWatchTimestampNs() - nStart) / 1000000000)
		if nT >= nLastSample + 5
			nLastSample = nT
			aRss + StzEnginePerfMemRss()
		ok
	end
	StzEngineGpuCompactRelease()
	StzEngineGpuSortRelease()
	StzEngineGpuSegScanRelease()
	nN = len(aRss)
	nQ = floor(nN / 4)
	nEarly = 0
	nLate = 0
	if nQ >= 1
		for i = nQ + 1 to 2 * nQ
			nEarly += aRss[i]
		next
		for i = nN - nQ + 1 to nN
			nLate += aRss[i]
		next
		nEarly = nEarly / nQ
		nLate = nLate / nQ
	ok
	? "  " + nRound + " rounds, " + nClosings + " closings; resident memory, the second quarter's mean " + floor(nEarly / 1048576) + " MB and the last quarter's " + floor(nLate / 1048576) + " MB (" + nN + " samples)"
	for cW in aWrongAt
		? "  WRONG: " + cW
	next
	? "  the checker's speed verdict was 'impossible' in " + nImpossible + " of " + nRound + " rounds (measured before: 4 of 2,940)"
	chk("" + nRound + " rounds: every answer of every module was the first round's, to the bit, through " + nClosings + " closings (" + nWrong + " were not)", nWrong = 0 and nRound >= 3)
	chk("kernel handles are flat: a round that follows a round without a closing compiled nothing new, in every one (" + nCompileMoved + " moved)", nCompileMoved = 0)
	chk("buffer handles are flat: with the scratch given back every fifth round, the live buffers were " + nFlat + " each time (" + nLiveMoved + " moved)", nLiveMoved = 0)
	chk("fallbacks are exactly the ones asked for: 3 probes in each of the " + nClosings + " closings = " + (3 * nClosings) + " (the counter says " + StzEngineGpuCounter(3) + ")", StzEngineGpuCounter(3) = 3 * nClosings)
	chk("no uncaptured device error was counted in the whole run", StzEngineGpuCounter(9) = 0)
	chk("no close hook was dropped (" + StzEngineGpuCloseHooks(0) + " registered, " + StzEngineGpuCloseHooks(1) + " dropped)", StzEngineGpuCloseHooks(1) = 0)
	chk("the checker's speed verdict `impossible` on its tiny correct kernel is rare: " + nImpossible + " of " + nRound + " rounds, under 2% (it is a speed verdict, never a wrong answer: the six compute modules were right in every round)", nImpossible <= 0.02 * nRound + 1)
	chk("the device did the work: " + StzEngineGpuCounter(0) + " dispatches in " + StzEngineGpuCounter(6) + " queue submits", StzEngineGpuCounter(0) > 100 * nRound / 10)
	if nQ >= 1
		chk("resident memory does not climb: the last quarter's mean is within 25% + 64 MB of the second quarter's (the bound is a measurement, printed above)", nLate < nEarly * 1.25 + 67108864)
	else
		$nSkip++
		? "  [SKIPPED] the memory check: the run was too short to sample (a sample every 5 s, four quarters)"
	ok
	? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 3: the engine alone, no Ring list in the loop --"
	$t0 = clock()
	nSec3 = floor(nSec / 3)
	if nSec3 < 10
		nSec3 = 10
	ok
	nN = 70000
	aIn = []
	aFl = []
	for i = 1 to nN
		aIn + ((i * 5) % 7)
		aFl + (i % 100 = 1)
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hF = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuBufferUploadList(hF, aFl)
	StzEngineGpuCountersReset()
	nC3a = 0 - 1
	nLive3a = 0 - 1
	nStart = StzEngineWatchTimestampNs()
	nLastSample = 0 - 2
	nRounds3 = 0
	aRss3 = []
	while (StzEngineWatchTimestampNs() - nStart) / 1000000000 < nSec3
		StzEngineGpuOpScan(hI, hO, nN, 0)
		StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 3)
		StzEngineGpuOpSort(hI, hO, nN, 0)
		StzEngineGpuOpSegScan(hI, hF, hO, nN, 0)
		StzEngineGpuSync()
		nRounds3++
		if nRounds3 = 3
			nC3a = StzEngineGpuCounter(4)
			nLive3a = StzEngineGpuCounter(8)
		ok
		nT = floor((StzEngineWatchTimestampNs() - nStart) / 1000000000)
		if nT >= nLastSample + 2
			nLastSample = nT
			aRss3 + StzEnginePerfMemRss()
		ok
	end
	nN3 = len(aRss3)
	nQ3 = floor(nN3 / 4)
	nE3 = 0
	nLt3 = 0
	if nQ3 >= 1
		for i = nQ3 + 1 to 2 * nQ3
			nE3 += aRss3[i]
		next
		for i = nN3 - nQ3 + 1 to nN3
			nLt3 += aRss3[i]
		next
		nE3 = nE3 / nQ3
		nLt3 = nLt3 / nQ3
	ok
	? "  " + nRounds3 + " rounds of four ops in " + nSec3 + " s; resident memory, second quarter's mean " + floor(nE3 / 1048576) + " MB, last quarter's " + floor(nLt3 / 1048576) + " MB (" + nN3 + " samples)"
	chk("the engine compiled nothing after the third round (" + nC3a + " kernels then, " + StzEngineGpuCounter(4) + " at the end)", StzEngineGpuCounter(4) = nC3a)
	chk("the live buffers did not move: " + nLive3a + " after the third round (the scratch made and kept), " + StzEngineGpuCounter(8) + " after " + nRounds3 + " rounds", StzEngineGpuCounter(8) = nLive3a)
	chk("no uncaptured device error in " + nRounds3 + " rounds", StzEngineGpuCounter(9) = 0)
	if nQ3 >= 1
		chk("the engine's resident memory does not climb: the last quarter's mean is within 32 MB of the second quarter's (measured: 5 MB over 40 s)", nLt3 < nE3 + 33554432)
	else
		$nSkip++
		? "  [SKIPPED] the engine memory check: the run was too short to sample"
	ok
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hF)
	StzEngineGpuBufferFree(hO)
	StzEngineGpuCompactRelease()
	StzEngineGpuSortRelease()
	StzEngineGpuSegScanRelease()
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: a device destroyed under the engine, the way a driver reset does it, then recovered --"
	$t0 = clock()
	for nLoss = 1 to 3
		nErr0 = StzEngineGpuCounter(9)
		nSeen = StzEngineGpuSimulateDeviceLoss()
		bDown = (StzEngineGpuIsAvailable() = 0)
		nErr1 = StzEngineGpuCounter(9)
		cMsg = StzEngineGpuLastError()
		bFb = (StzEngineGpuOpScan(1, 2, 100, 0) = 1) and (StzEngineGpuOpSort(1, 2, 100, 0) = 1) and (StzEngineGpuOpSpmv(1, 2, 3, 4, 5, 10, 10, 0) = 1)
		nUp = StzEngineGpuInit($tStzGpuRuntime)
		bUp = (StzEngineGpuIsAvailable() = 1)
		aR = _Round(oG)
		StzEngineGpuCompactRelease()
		StzEngineGpuSortRelease()
		StzEngineGpuSegScanRelease()
		? "  loss " + nLoss + ": noticed " + nSeen + ", errors " + nErr0 + " -> " + nErr1 + ", the device says '" + left(cMsg, 70) + "'; after Init: " + aR[3]
		chk("loss " + nLoss + ": the engine noticed it, is down, REPORTED it (the error count rose), answers FALLBACK for three ops, Init brings it back, and every module's answer is the first round's", nSeen = 1 and bDown and nErr1 > nErr0 and len(cMsg) > 0 and bFb and bUp and aR[2] and aR[1] = aRound1[1])
	next
	chk("after three losses and recoveries the live buffers are what they were after the first round (" + StzEngineGpuCounter(8) + " of " + nFlat + ")", StzEngineGpuCounter(8) = nFlat)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail" + ", " + $nSkip + " skipped"
? "=========================================="

shutdown($nFail)

func chk cLabel, bCond
	if bCond
		$nPass++
		? "  [OK] " + cLabel
	else
		$nFail++
		? "  [FAIL] " + cLabel
	ok

# One pass over every compute module, small inputs whose answers are known exactly:
# returns [ the answers as one text, whether every one is as expected ]
func _Round oG
	cAns = ""
	bOk = 1
	# the fft op: a convolution of whole numbers
	aC = oG.ConvolveReal([ 1, 2, 3 ], [ 4, 5 ])
	bC = (len(aC) = 4 and fabs(aC[1] - 4) < 0.01 and fabs(aC[2] - 13) < 0.01 and fabs(aC[3] - 22) < 0.01 and fabs(aC[4] - 15) < 0.01)
	cAns += "conv " + _Round1(aC) + "; "
	# the checker: a tiny kernel against itself, verified
	cSpec = "in a" + char(10) + "out c" + char(10) + "body { @c = @a * 2 + 1 }"
	k = StzKernelMakerFromSpec(cSpec)
	aV = oG.VerifySpecWith(k, k, [ [ "a", _Seq(1000) ] ], [ [ "n", 1000 ] ])
	bV = (aV[:verdict] = "verified" or aV[:verdict] = "impossible")
	# the scan: 70,000 ones is the ramp
	aOnes = []
	for i = 1 to 70000
		aOnes + 1
	next
	aS = oG.Scan(aOnes)
	bS = (aS[1] = 1 and aS[256] = 256 and aS[257] = 257 and aS[70000] = 70000)
	cAns += "scan " + aS[70000] + "; "
	# compaction: the elements above 3 of 0..6 repeated
	aIn = []
	for i = 1 to 70000
		aIn + ((i * 5) % 7)
	next
	aK = oG.CompactWhere(aIn, ">", 3)
	nKeep = 0
	for i = 1 to 70000
		if aIn[i] > 3
			nKeep++
		ok
	next
	bK = (len(aK) = nKeep and aK[1] > 3 and aK[len(aK)] > 3)
	cAns += "compact " + len(aK) + "; "
	# the sort: 70,000 keys with ties, ordered afterwards
	aT = oG.Sort(aIn)
	bT = (len(aT) = 70000 and aT[1] = 0 and aT[70000] = 6)
	for i = 2 to 70000 step 997
		if aT[i] < aT[i - 1]
			bT = 0
		ok
	next
	cAns += "sort " + aT[1] + "-" + aT[70000] + "; "
	# the segmented reduction: segments of 100 ones sum to 100 each
	aFl = []
	for i = 1 to 70000
		aFl + (i % 100 = 1)
	next
	aR = oG.SegmentedReduce(aOnes, aFl, "sum")
	bR = (len(aR) = 700 and aR[1] = 100 and aR[700] = 100)
	cAns += "segreduce " + len(aR) + "x" + aR[1] + "; "
	# the sparse product: the identity of 50 rows times a ramp is the ramp
	aRp = []
	aCo = []
	aVa = []
	aX = []
	for i = 0 to 49
		aRp + i
		aCo + i
		aVa + 1
		aX + (i + 1)
	next
	aRp + 50
	aP = oG.Spmv(aRp, aCo, aVa, aX)
	bP = (len(aP) = 50 and aP[1] = 1 and aP[50] = 50)
	cAns += "spmv " + aP[50]
	cFlags = "conv=" + bC + " verify=" + bV + " scan=" + bS + " compact=" + bK + " sort=" + bT + " segreduce=" + bR + " spmv=" + bP
	return [ cAns, (bC and bV and bS and bK and bT and bR and bP), cFlags, aV[:verdict] ]

func _Round1 aList
	cT = ""
	nQ = len(aList)
	for q = 1 to nQ
		cT += "" + floor(aList[q] + 0.5) + " "
	next
	return cT

func _Seq nN
	aR = []
	for q = 0 to nN - 1
		aR + q
	next
	return aR
