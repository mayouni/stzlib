# GB0 -- STREAM COMPACTION, the library layer's second op (SOFTANZA_GPU_PLAN.md, GB0;
# built on the scan of gpu_scan_narrated.ring).
#
# Keep some of n f32s and pack them, IN ORDER, at the front of an output buffer; say
# how many were kept. Two ways to say which: a MASK buffer (keep where it is not 0) or
# a comparison with a threshold (gt ge lt le eq ne). Three steps in ONE submit: the
# flags, an exclusive scan of the flags (each kept element's scan value is its place),
# and a scatter that also writes the count; the count comes back through a 4-byte read.
#
# Parity discipline, as the scan's guard states it:
#   - EXACT WITNESSES: elements that are whole numbers, kept and packed -- the device
#     must equal the plain loop's list element for element, in order, at sizes that
#     cross every scan level (1, 255, 256, 257, 65,537, 1,000,003), and at both
#     extremes (everything kept, nothing kept);
#   - the output is written ONLY up to the count: a sentinel past it must survive;
#   - NEGATIVE SIBLINGS: wrong sizes, aliased buffers, a freed buffer, an unknown
#     comparison, more elements than the counts can hold exactly (2^24), no device --
#     and the happy path counts ZERO fallbacks.
#
# Run with Ring++: rnxc gpu_compact_narrated.ring

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
S_TOOLARGE = 4

aOps = [ ">", ">=", "<", "<=", "=", "!=" ]

? "-- Scene 0: the op refuses the fallback way before there is a device --"
aF = StzEngineGpuOpCompact(1, 2, 3, 100)
chk("a compaction before Init answers FALLBACK", aF[1] = S_FALLBACK)
aF = StzEngineGpuOpCompactWhere(1, 2, 100, 0, 0)
chk("...and so does the comparison form", aF[1] = S_FALLBACK)

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
	for nN in [ 1, 255, 256, 257, 65537, 1000003 ]
		aIn = []
		for i = 1 to nN
			aIn + ((i * 5) % 11)
		next
		aRef = []
		for i = 1 to nN
			if aIn[i] > 4
				aRef + aIn[i]
			ok
		next
		hI = StzEngineGpuBufferNew(nN * 4)
		hO = StzEngineGpuBufferNew(nN * 4)
		aSent = []
		for i = 1 to nN
			aSent + (0 - 1)
		next
		StzEngineGpuBufferUploadList(hI, aIn)
		StzEngineGpuBufferUploadList(hO, aSent)
		aRes = StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 4)
		nKept = floor(aRes[2])
		aOut = StzEngineGpuBufferDownloadList(hO, nN)
		bSame = (aRes[1] = S_OK and nKept = len(aRef))
		for i = 1 to len(aRef)
			if aOut[i] != aRef[i]
				bSame = 0
				? "  first difference at " + i + ": " + aOut[i] + " against " + aRef[i]
				exit
			ok
		next
		bSent = 1
		for i = nKept + 1 to nN
			if aOut[i] != -1
				bSent = 0
				exit
			ok
		next
		chk("n = " + nN + " (" + StzEngineGpuCompactDispatches(nN) + " dispatches): " + nKept + " kept above 4, every one the loop's, in order", bSame)
		chk("n = " + nN + ": nothing past the count was written (the sentinel survived)", bSent)
		StzEngineGpuBufferFree(hI)
		StzEngineGpuBufferFree(hO)
	next
	nN = 10000
	aIn = []
	for i = 1 to nN
		aIn + i
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	aRes = StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 0)
	aOut = StzEngineGpuBufferDownloadList(hO, nN)
	chk("everything kept: the count is " + aRes[2] + " and the output is the input", aRes[1] = S_OK and aRes[2] = nN and aOut[1] = 1 and aOut[nN] = nN and aOut[5000] = 5000)
	aRes = StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 1000000)
	chk("nothing kept: the count is 0", aRes[1] = S_OK and aRes[2] = 0)
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hO)
	chk("the happy path counted zero fallbacks", StzEngineGpuCounter(3) = 0)
	? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 2: the six comparisons, ties included --"
	$t0 = clock()
	nN = 100000
	aIn = []
	for i = 1 to nN
		aIn + ((i * 5) % 7)
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	for nC = 0 to 5
		aRef = oG._CompactWhereCpu(aIn, aOps[nC + 1], 3)
		aRes = StzEngineGpuOpCompactWhere(hI, hO, nN, nC, 3)
		nKept = floor(aRes[2])
		aOut = []
		if nKept > 0
			aOut = StzEngineGpuBufferDownloadList(hO, nKept)
		ok
		chk("x " + aOps[nC + 1] + " 3 over 100,000 whole numbers 0..6: " + nKept + " kept, the loop's list to the bit", aRes[1] = S_OK and nKept = len(aRef) and @@(aOut) = @@(aRef))
	next
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hO)
	? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 3: the mask form, a mask made apart from the values --"
	nN = 100000
	aIn = []
	aMask = []
	for i = 1 to nN
		aIn + i
		aMask + ((i * 7) % 5 < 2)
	next
	aRef = []
	for i = 1 to nN
		if aMask[i]
			aRef + aIn[i]
		ok
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hM = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuBufferUploadList(hM, aMask)
	aRes = StzEngineGpuOpCompact(hI, hM, hO, nN)
	nKept = floor(aRes[2])
	aOut = StzEngineGpuBufferDownloadList(hO, nKept)
	chk("a mask keeping 2 of every 5: " + nKept + " kept, the loop's list to the bit, in order", aRes[1] = S_OK and nKept = len(aRef) and @@(aOut) = @@(aRef))
	aMask = []
	for i = 1 to nN
		aMask + (0 - 0.5 * (i % 2))
	next
	StzEngineGpuBufferUploadList(hM, aMask)
	aRes = StzEngineGpuOpCompact(hI, hM, hO, nN)
	chk("a mask of -0.5 and 0 keeps the -0.5 positions: any entry that is not 0 keeps its element (" + aRes[2] + " kept)", aRes[1] = S_OK and aRes[2] = nN / 2)
	StzEngineGpuBufferFree(hM)

	? ""
	? "-- Scene 4: 2 + scan dispatches in one batch, the scratch kept between calls and given back --"
	nN = 100000
	hI = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 50000)
	StzEngineGpuSync()
	nD0 = StzEngineGpuCounter(0)
	nS0 = StzEngineGpuCounter(6)
	nL0 = StzEngineGpuCounter(8)
	nF0 = StzEngineGpuCounter(3)
	aRes = StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 50000)
	StzEngineGpuSync()
	chk("a compaction of 100,000 is " + StzEngineGpuCompactDispatches(nN) + " dispatches (the counter says " + (StzEngineGpuCounter(0) - nD0) + ")", StzEngineGpuCounter(0) - nD0 = StzEngineGpuCompactDispatches(nN) and StzEngineGpuCompactDispatches(nN) = 7)
	chk("...in ONE batch plus the count's read: two queue submits (the counter says " + (StzEngineGpuCounter(6) - nS0) + ")", StzEngineGpuCounter(6) - nS0 = 2)
	chk("...the scratch (the flags, the places, the count) is kept, not made again: live buffers " + nL0 + " before the call and " + StzEngineGpuCounter(8) + " after", StzEngineGpuCounter(8) = nL0)
	nLive = StzEngineGpuCounter(8)
	StzEngineGpuCompactRelease()
	chk("CompactRelease gives the three back (live buffers " + nLive + " then " + StzEngineGpuCounter(8) + ")", StzEngineGpuCounter(8) = nLive - 3)
	aRes = StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 50000)
	chk("...and nothing fell back, and the count is right (" + aRes[2] + ")", StzEngineGpuCounter(3) = nF0 and aRes[2] = 50000)

	? ""
	? "-- Scene 5: what it refuses --"
	chk("n = 0 is BAD_ARG", StzEngineGpuOpCompactWhere(hI, hO, 0, 0, 0)[1] = S_BADARG)
	chk("an unknown comparison code is BAD_ARG", StzEngineGpuOpCompactWhere(hI, hO, nN, 6, 0)[1] = S_BADARG and StzEngineGpuOpCompactWhere(hI, hO, nN, 0 - 1, 0)[1] = S_BADARG)
	chk("the same buffer in and out is BAD_ARG (WebGPU aliasing validation)", StzEngineGpuOpCompactWhere(hI, hI, nN, 0, 0)[1] = S_BADARG)
	chk("the mask as the input, or as the output, is BAD_ARG", StzEngineGpuOpCompact(hI, hI, hO, nN)[1] = S_BADARG and StzEngineGpuOpCompact(hI, hO, hO, nN)[1] = S_BADARG)
	chk("an output too small is BAD_ARG", StzEngineGpuOpCompactWhere(hI, hO, nN + 1, 0, 0)[1] = S_BADARG)
	chk("more than 16,777,216 elements are refused by name before any buffer is looked at (TOO_LARGE): the counts are f32", StzEngineGpuOpCompactWhere(hI, hO, 16777217, 0, 0)[1] = S_TOOLARGE)
	StzEngineGpuBufferFree(hO)
	chk("a freed output answers STALE", StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 0)[1] = S_STALE)
	StzEngineGpuBufferFree(hI)

	? ""
	? "-- Scene 6: the face, lists in and a list out --"
	aA = oG.CompactWhere([ 3, 1, 4, 1, 5, 9, 2, 6 ], ">", 3)
	aB = oG.Compact([ 3, 1, 4, 1, 5, 9, 2, 6 ], [ 1, 0, 1, 0, 1, 0, 0, 1 ])
	aC = oG.CompactWhere([ 3, 1, 4 ], ">", 100)
	chk("CompactWhere([3 1 4 1 5 9 2 6], '>', 3) = [4 5 9 6]", @@(aA) = "[ 4, 5, 9, 6 ]")
	chk("Compact with a mask = [3 4 5 6]", @@(aB) = "[ 3, 4, 5, 6 ]")
	chk("nothing kept is an empty list", len(aC) = 0)
	cErr = ""
	try
		oG.CompactWhere([ 1, 2 ], "~", 1)
	catch
		cErr = cCatchError
	done
	chk("an unknown comparison is refused by name (" + left(cErr, 60) + ")", StzFindFirst("the comparison is one of", cErr) > 0)
	cErr = ""
	try
		oG.Compact([ 1, 2, 3 ], [ 1, 0 ])
	catch
		cErr = cCatchError
	done
	chk("a mask of another length is refused by name (" + left(cErr, 60) + ")", StzFindFirst("a mask of the same length", cErr) > 0)

	? ""
	? "-- Scene 7: how fast, resident, against a scale pass --"
	$t0 = clock()
	nN = 16000000
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	if hI = 0 or hO = 0
		? "  (no room for two 64 MB buffers: scene skipped)"
	else
		oG.Wake(400)
		StzEngineGpuSync()
		nBestC = 1000000
		nBestS = 1000000
		for nRep = 1 to 5
			StzEngineGpuSync()
			nT = StzEngineWatchTimestampNs()
			for q = 1 to 5
				StzEngineGpuOpCompactWhere(hI, hO, nN, 0, 0 - 1)
			next
			nMs = (StzEngineWatchTimestampNs() - nT) / 1000000 / 5
			if nMs < nBestC
				nBestC = nMs
			ok
			StzEngineGpuSync()
			nT = StzEngineWatchTimestampNs()
			for q = 1 to 5
				StzEngineGpuOpScaleInPlace(hI, 1.0, nN)
			next
			StzEngineGpuSync()
			nMs = (StzEngineWatchTimestampNs() - nT) / 1000000 / 5
			if nMs < nBestS
				nBestS = nMs
			ok
		next
		? "  16,000,000 floats, " + StzEngineGpuCompactDispatches(nN) + " dispatches (the count read included): compaction " + nBestC + " ms, a scale pass over the same vector " + nBestS + " ms"
		? "  the compaction costs " + (nBestC / nBestS) + " scale passes: the flags, the scan (which moves its vector twice over), the scatter, and the count's read"
		chk("a compaction costs under 8 scale passes (a sanity line from the measurement above, 5.2 on the 3050 once the scratch is kept; 17 when it was made on every call)", nBestC / nBestS < 8)
	ok
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hO)
	? "  (scene 7: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 8: the route -- the loop against the device through the face, measured, stored, followed --"
	$t0 = clock()
	aCal = oG.CalibrateCompact()
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
			if (StzEngineGpuCalibRouteShaped("compact", aCell[2], 1) = 1) != bWin
				bFollow = 0
			ok
		next
		chk("the route sends a size to the device exactly where its measured ratio reached 1.3, at every rung", bFollow)
		aNum = []
		for i = 1 to 200000
			aNum + ((i * 5) % 7)
		next
		aR = oG.CompactWhereRouted(aNum, ">", 2.5)
		aG = oG.CompactWhere(aNum, ">", 2.5)
		chk("CompactWhereRouted gives the same list whichever side it ran on (200,000 whole numbers, to the bit)", @@(aR) = @@(aG))
		chk("a short list stays on the loop and CompactWhereRouted answers [4 5 9]", @@(oG.CompactWhereRouted([ 3, 1, 4, 5, 9 ], ">", 3.5)) = "[ 4, 5, 9 ]" and StzEngineGpuCalibRouteShaped("compact", 5, 1) = 0)
	ok
	? "  (scene 8: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 9: puzzle 21, pack the large ones --"
$t0 = clock()
NLc = char(10)
oQ = StzKernelPuzzleQ("kp-21")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages, says stream compaction and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("stream compaction", oQ.Task("en")) > 0 and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "shared r 256" + NLc + "stage { @t[@l] = @a }" + NLc
cIncl = "stage { @r[@l] = sum(j, 0, 256, when(j <= @l, when(@t[j] > 5, 1, 0), 0)) }" + NLc
# the verdicts were worked out from the data (a is (i * 7) % 13: 0 7 1 8 2 9 3 10 4 11 5 12 6 ..., so the
# kept values, above 5, run 7 8 9 10 11 12 6 ...) before the first run:
#   masks only:      slot 0 owes 7 and gets a[0] = 0: element 1
#   rank one high:   slot 0 looks for rank 0, which nothing has: 0 for 7, element 1
#   at least 5:      the 5 joins the kept values after 7 8 9 10 11, and 12 is owed there: element 6
aCases = [
	[ cHead + cIncl + "body { @c = sum(j, 0, 256, when(@t[j] > 5 and @r[j] == @l + 1, @t[j], 0)) }", "verified" ],
	[ cHead + "stage { @r[@l] = sum(j, 0, 256, when(j < @l, when(@t[j] > 5, 1, 0), 0)) }" + NLc + "body { @c = sum(j, 0, 256, when(@t[j] > 5 and @r[j] == @l, @t[j], 0)) }", "verified" ],
	[ "in a" + NLc + "out c" + NLc + "body { @c = when(@a > 5, @a, 0) }", "mismatch at element 1" ],
	[ cHead + cIncl + "body { @c = sum(j, 0, 256, when(@t[j] > 5 and @r[j] == @l, @t[j], 0)) }", "mismatch at element 1" ],
	[ cHead + "stage { @r[@l] = sum(j, 0, 256, when(j <= @l, when(@t[j] >= 5, 1, 0), 0)) }" + NLc + "body { @c = sum(j, 0, 256, when(@t[j] >= 5 and @r[j] == @l + 1, @t[j], 0)) }", "mismatch at element 6" ]
]
nAgree = 0
for aQ in aCases
	if bDevice
		cV = oQ.Grade(aQ[1])
	else
		cV = oQ.GradeOnCpu(aQ[1])
	ok
	chk(replace(replace(replace(aQ[1], NLc, " / "), "in a / out c / ", ""), "shared t 256 / shared r 256 / stage { @t[@l] = @a } / ", "") + " -> " + aQ[2] + " (" + cV + ")", cV = aQ[2])
	if oQ.GradeOnCpu(aQ[1]) = aQ[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
cV = oQ.Grade("in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @t[@l] + 1 }" + NLc + "body { @c = @t[@l] }")
chk("a stage that reads the array it writes is refused by name (" + left(cV, 60) + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("cannot read the array it writes", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-21")
	aPr = oE.ProveItself()
	chk("the exercise proves itself through the System's checker: wrong refused " + aPr[:wrong] + ", right accepted " + aPr[:right] + ", failures " + @@(aPr[:failures]),
		aPr[:wrong] = 5 and aPr[:right] = 2 and len(aPr[:failures]) = 0)
ok
? "  (scene 9: " + ((clock() - $t0) / clockspersecond()) + " s)"

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
