# GB0 -- THE SCAN, the library layer's first op (SOFTANZA_GPU_PLAN.md, GB0).
#
# out[i] = in[0] + ... + in[i] (inclusive) or in[0] + ... + in[i-1] (exclusive),
# over n f32s, entirely on the device: every group of 256 scans its block in
# workgroup memory, the block totals are scanned one level up until one group
# holds them, and the scanned totals are added back down. 2 * levels - 1
# dispatches in ONE submit; the data is never read back in between.
#
# Parity discipline, as the op library's guard states it:
#   - EXACT WITNESSES first: whole numbers whose every partial is exact in
#     f32 (below 2^24), at sizes that cross each level (1, 255, 256, 257,
#     65536, 65537, 1,000,003): the device must equal the sequential scan to
#     the BIT, whatever the tree.
#   - a TOLERANCE BAND second, on data whose partials round: the order is a
#     fixed tree, not left to right, so the band is SET FROM MEASUREMENT.
#   - NEGATIVE SIBLINGS: wrong sizes, the same buffer twice, a freed buffer,
#     an unknown mode, no device -- and the happy path counts ZERO fallbacks.
#
# Run with Ring++: rnxc gpu_scan_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSkip = 0

pr()

decimals(10)

S_OK = 0
S_FALLBACK = 1
S_STALE = 2
S_BADARG = 3

? "-- Scene 0: the op refuses the fallback way before there is a device --"
chk("a scan before Init answers FALLBACK", StzEngineGpuOpScan(1, 2, 100, 0) = S_FALLBACK)

oG = new stzGpu
bDevice = oG.IsAvailable()
if NOT bDevice
	? "  NO GPU ON THIS MACHINE -- the scenes below need a device; the fallback scene above is the CI coverage"
else
	? "  device: [" + StzEngineGpuSelectedAdapter() + "] " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

	? ""
	? "-- Scene 1: exact witnesses, whole numbers, across every level --"
	$t0 = clock()
	StzEngineGpuCountersReset()
	for nN in [ 1, 255, 256, 257, 65536, 65537, 1000003 ]
		aIn = []
		for i = 1 to nN
			aIn + ((i * 5) % 7)
		next
		hI = StzEngineGpuBufferNew(nN * 4)
		hO = StzEngineGpuBufferNew(nN * 4)
		StzEngineGpuBufferUploadList(hI, aIn)
		nStI = StzEngineGpuOpScan(hI, hO, nN, 0)
		aOut = StzEngineGpuBufferDownloadList(hO, nN)
		bSame = (nStI = S_OK and len(aOut) = nN)
		nRun = 0
		for i = 1 to nN
			nRun += aIn[i]
			if aOut[i] != nRun
				bSame = 0
				? "  first difference at " + i + ": " + aOut[i] + " against " + nRun
				exit
			ok
		next
		chk("inclusive, n = " + nN + " (" + StzEngineGpuScanDispatches(nN) + " dispatches): every element equals the sequential scan to the bit", bSame)
		nStE = StzEngineGpuOpScan(hI, hO, nN, 1)
		aOut = StzEngineGpuBufferDownloadList(hO, nN)
		bSame = (nStE = S_OK and len(aOut) = nN)
		nRun = 0
		for i = 1 to nN
			if aOut[i] != nRun
				bSame = 0
				? "  first difference at " + i + ": " + aOut[i] + " against " + nRun
				exit
			ok
			nRun += aIn[i]
		next
		chk("exclusive, n = " + nN + ": every element equals the sequential scan, shifted, to the bit", bSame)
		StzEngineGpuBufferFree(hI)
		StzEngineGpuBufferFree(hO)
	next
	chk("the happy path counted zero fallbacks", StzEngineGpuCounter(3) = 0)
	? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 2: the shift is exact inside a block, and the band holds where partials round --"
	$t0 = clock()
	nN = 100000
	aIn = []
	for i = 1 to nN
		aIn + (((i * 37) % 1000) / 1000.0 + 0.001)
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hInc = StzEngineGpuBufferNew(nN * 4)
	hExc = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuOpScan(hI, hInc, nN, 0)
	StzEngineGpuOpScan(hI, hExc, nN, 1)
	aInc = StzEngineGpuBufferDownloadList(hInc, nN)
	aExc = StzEngineGpuBufferDownloadList(hExc, nN)
	aUp = StzEngineGpuBufferDownloadList(hI, nN)
	bShift = 1
	nChecked = 0
	for i = 2 to nN
		if (i - 1) % 256 != 0
			nChecked++
			if aExc[i] != aInc[i - 1]
				bShift = 0
			ok
		ok
	next
	chk("exclusive[i] equals inclusive[i - 1] to the bit at every position inside a block (" + nChecked + " of them, on data whose partials round)", bShift and aExc[1] = 0)
	nRun = 0
	nMaxRel = 0
	nMaxRelExc = 0
	for i = 1 to nN
		nRef = nRun
		nRun += aUp[i]
		_nR_ = fabs(aInc[i] - nRun) / nRun
		if _nR_ > nMaxRel
			nMaxRel = _nR_
		ok
		if nRef > 0
			_nR_ = fabs(aExc[i] - nRef) / nRef
			if _nR_ > nMaxRelExc
				nMaxRelExc = _nR_
			ok
		ok
	next
	? "  measured max relative error against the f64 scan of the uploaded values, n = 100000: inclusive " + nMaxRel + ", exclusive " + nMaxRelExc
	chk("band: inclusive relative error < 1e-5 (the band is set from the measurement printed above)", nMaxRel < 0.00001)
	chk("band: exclusive relative error < 1e-5", nMaxRelExc < 0.00001)
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hInc)
	StzEngineGpuBufferFree(hExc)
	? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 3: one submit, 2 * levels - 1 dispatches, no buffer left behind --"
	nN = 100000
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	aOnes = []
	for i = 1 to nN
		aOnes + 1
	next
	StzEngineGpuBufferUploadList(hI, aOnes)
	StzEngineGpuSync()
	nD0 = StzEngineGpuCounter(0)
	nS0 = StzEngineGpuCounter(6)
	nL0 = StzEngineGpuCounter(8)
	nF0 = StzEngineGpuCounter(3)
	StzEngineGpuOpScan(hI, hO, nN, 0)
	StzEngineGpuSync()
	chk("a scan of 100,000 is " + StzEngineGpuScanDispatches(nN) + " dispatches (the counter says " + (StzEngineGpuCounter(0) - nD0) + ")", StzEngineGpuCounter(0) - nD0 = StzEngineGpuScanDispatches(nN) and StzEngineGpuScanDispatches(nN) = 5)
	chk("...in ONE queue submit (the counter says " + (StzEngineGpuCounter(6) - nS0) + ")", StzEngineGpuCounter(6) - nS0 = 1)
	chk("...the work buffers are gone (live buffers " + nL0 + " before, " + StzEngineGpuCounter(8) + " after)", StzEngineGpuCounter(8) = nL0)
	chk("...and nothing fell back", StzEngineGpuCounter(3) = nF0)
	aOut = StzEngineGpuBufferDownloadList(hO, nN)
	chk("a scan of ones is the ramp 1 .. 100000", aOut[1] = 1 and aOut[256] = 256 and aOut[257] = 257 and aOut[nN] = nN)
	chk("the dispatch counts: 1 up to 256, 3 up to 65,536, 5 up to 16,777,216, 7 past it",
		StzEngineGpuScanDispatches(256) = 1 and StzEngineGpuScanDispatches(257) = 3 and StzEngineGpuScanDispatches(65536) = 3 and StzEngineGpuScanDispatches(65537) = 5 and StzEngineGpuScanDispatches(16777217) = 7)

	? ""
	? "-- Scene 4: what it refuses --"
	chk("n = 0 is BAD_ARG", StzEngineGpuOpScan(hI, hO, 0, 0) = S_BADARG)
	chk("an unknown mode is BAD_ARG", StzEngineGpuOpScan(hI, hO, nN, 2) = S_BADARG)
	chk("the same buffer twice is BAD_ARG (WebGPU aliasing validation)", StzEngineGpuOpScan(hI, hI, nN, 0) = S_BADARG)
	chk("an output too small is BAD_ARG", StzEngineGpuOpScan(hI, hO, nN + 1, 0) = S_BADARG)
	StzEngineGpuBufferFree(hO)
	chk("a freed output answers STALE", StzEngineGpuOpScan(hI, hO, nN, 0) = S_STALE)
	StzEngineGpuBufferFree(hI)

	? ""
	? "-- Scene 5: the face, a list in and a list out --"
	aS = oG.Scan([ 3, 1, 4, 1, 5, 9, 2, 6 ])
	aE = oG.ScanExclusive([ 3, 1, 4, 1, 5, 9, 2, 6 ])
	chk("Scan([3 1 4 1 5 9 2 6]) = [3 4 8 9 14 23 25 31]", @@(aS) = "[ 3, 4, 8, 9, 14, 23, 25, 31 ]")
	chk("ScanExclusive of the same = [0 3 4 8 9 14 23 25]", @@(aE) = "[ 0, 3, 4, 8, 9, 14, 23, 25 ]")
	cErr = ""
	try
		oG.Scan([])
	catch
		cErr = cCatchError
	done
	chk("an empty list is refused by name (" + left(cErr, 50) + ")", StzFindFirst("non-empty list", cErr) > 0)

	? ""
	? "-- Scene 6: how fast, against the same bytes moved by a scale pass --"
	$t0 = clock()
	nN = 16000000
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	if hI = 0 or hO = 0
		? "  (no room for two 64 MB buffers: scene skipped)"
	else
		oG.Wake(400)
		StzEngineGpuSync()
		nBestScan = 1000000
		nBestScale = 1000000
		nPer = 10
		for nRep = 1 to 5
			StzEngineGpuSync()
			nT = clock()
			for q = 1 to nPer
				StzEngineGpuOpScan(hI, hO, nN, 0)
			next
			StzEngineGpuSync()
			nMs = (clock() - nT) / clockspersecond() * 1000 / nPer
			if nMs < nBestScan
				nBestScan = nMs
			ok
			StzEngineGpuSync()
			nT = clock()
			for q = 1 to nPer
				StzEngineGpuOpScaleInPlace(hI, 1.0, nN)
			next
			StzEngineGpuSync()
			nMs = (clock() - nT) / clockspersecond() * 1000 / nPer
			if nMs < nBestScale
				nBestScale = nMs
			ok
		next
		nBytes = nN * 4 * 2
		nGbsScan = nBytes / (nBestScan / 1000) / 1000000000
		nGbsScale = nBytes / (nBestScale / 1000) / 1000000000
		? "  16,000,000 floats, " + StzEngineGpuScanDispatches(nN) + " dispatches, ten to a sync: scan " + nBestScan + " ms (" + nGbsScan + " GB/s counting the minimum read + write), scale " + nBestScale + " ms (" + nGbsScale + " GB/s)"
		? "  the scan reaches " + (nGbsScan / nGbsScale) + " of what a scale pass over the same bytes reaches (it moves twice the minimum: the offsets pass reads and writes every element again)"
		chk("the scan runs at more than a tenth of the bandwidth a scale pass reaches (measured above; the floor is a sanity line, not a goal)", nGbsScan / nGbsScale > 0.1)
	ok
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hO)
	? "  (scene 6: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 7: the route -- the loop against the device through the face, measured, stored, followed --"
	$t0 = clock()
	aCal = oG.CalibrateScan()
	? "  adapter " + aCal[:adapter] + ", flat line at " + aCal[:flat] + " (" + aCal[:flatwhy] + ")"
	for aCell in aCal[:cells]
		? "  n = " + aCell[2] + ": loop " + aCell[3] + " ms, face " + aCell[4] + " ms, ratio " + aCell[5]
	next
	if aCal[:confounded]
		# the control rung moved by more than 2x: another process held the machine, the store refused the line,
		# and a route that was never stored cannot be followed. A gate that could not run says so; it is not a pass
		$nSkip++
		? "  [SKIPPED] the route checks: the machine was too loaded for a stable measurement (the control rung moved more than 2x), so nothing was stored; run this guard again on a quiet machine"
	else
		chk("the control rung (the first, measured again at the end) stayed within 2x, so the line is stored", NOT aCal[:confounded])
		bFollow = 1
		for aCell in aCal[:cells]
			bWin = (aCell[5] >= 1.3)
			if (StzEngineGpuCalibRouteShaped("scan", aCell[2], 1) = 1) != bWin
				bFollow = 0
			ok
		next
		chk("the route sends a size to the device exactly where its measured ratio reached 1.3, at every rung", bFollow)
		chk("the smallest rung stays on the loop and the largest goes to the device on this machine (the face costs about 0.15 ms before it scans)",
			aCal[:cells][1][5] < 1.3 and aCal[:cells][ring_len(aCal[:cells])][5] >= 1.3)
		aNum = []
		for i = 1 to 200000
			aNum + ((i * 5) % 7)
		next
		aR = oG.ScanRouted(aNum)
		aG = oG.Scan(aNum)
		chk("ScanRouted gives the same running total whichever side it ran on (200,000 whole numbers, to the bit)", @@(aR) = @@(aG))
		aRE = oG.ScanExclusiveRouted([ 3, 1, 4 ])
		chk("a short list stays on the loop and ScanExclusiveRouted answers [0 3 4]", @@(aRE) = "[ 0, 3, 4 ]" and StzEngineGpuCalibRouteShaped("scan", 3, 1) = 0)
	ok
	? "  (scene 7: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 8: puzzle 20, the running total of a group --"
$t0 = clock()
NLc = char(10)
oQ = StzKernelPuzzleQ("kp-20")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0 and StzFindFirst("block step of the library", oQ.Task("en")) > 0)
cLoad = "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc
cTwo = "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "shared u 256" + NLc + "stage { @t[@l] = @a }" + NLc + "tiles s { N }" + NLc + "stage { @u[@l] = @t[@l] + @t[@l - pow(2, s)] }" + NLc + "stage { @t[@l] = @u[@l] }" + NLc + "body { @c = @t[@l] }"
# the verdicts were worked out from the data (a is (i * 7) % 13: 0, 7, 1, 8, 2 ... so a[0] = 0) before the first run:
#   exclusive:   element 1 is 0 either way; element 2 owes a[0] + a[1] = 7 and gets a[0] = 0
#   no restart:  the second group starts at element 257, which owes a[256] alone
#   7 steps:     reaches 128 places back; thread 128 owes 129 numbers and is missing a[0], which is 0,
#                so element 129 coincides and element 130 is the first wrong one
aCases = [
	[ cLoad + "body { @c = sum(j, 0, 256, when(j <= @l, @t[j], 0)) }", "verified" ],
	[ StzReplace(cTwo, "N", "8"), "verified" ],
	[ cLoad + "body { @c = sum(j, 0, 256, when(j < @l, @t[j], 0)) }", "mismatch at element 2" ],
	[ "in a" + NLc + "out c" + NLc + "body { @c = sum(j, 0, @i + 1, @a[j]) }", "mismatch at element 257" ],
	[ StzReplace(cTwo, "N", "7"), "mismatch at element 130" ]
]
nAgree = 0
for aQ in aCases
	if bDevice
		cV = oQ.Grade(aQ[1])
	else
		cV = oQ.GradeOnCpu(aQ[1])
	ok
	chk(replace(replace(aQ[1], NLc, " / "), "in a / out c / ", "") + " -> " + aQ[2] + " (" + cV + ")", cV = aQ[2])
	if oQ.GradeOnCpu(aQ[1]) = aQ[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
cV = oQ.Grade("in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @t[@l] + @t[@l - 1] }" + NLc + "body { @c = @t[@l] }")
chk("a stage that reads the array it writes is refused by name (" + left(cV, 60) + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("cannot read the array it writes", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-20")
	aPr = oE.ProveItself()
	chk("the exercise proves itself through the System's checker: wrong refused " + aPr[:wrong] + ", right accepted " + aPr[:right] + ", failures " + @@(aPr[:failures]),
		aPr[:wrong] = 5 and aPr[:right] = 2 and len(aPr[:failures]) = 0)
ok
? "  (scene 8: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail" + ", " + $nSkip + " skipped"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		$nPass++
		? "  [OK] " + cLabel
	else
		$nFail++
		? "  [FAIL] " + cLabel
	ok
