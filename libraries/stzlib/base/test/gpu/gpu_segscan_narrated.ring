# GB0 -- SEGMENTED SCAN AND SEGMENTED REDUCTION, the library layer's fourth op
# (SOFTANZA_GPU_PLAN.md, GB0; the scan of gpu_scan_narrated.ring with a reset, and the
# compaction of gpu_compact_narrated.ring on top).
#
# A flags buffer cuts a vector into SEGMENTS: a nonzero flag at i starts a new segment
# there, and element 0 always starts one. Two ops, each with an operator (sum, max, min):
#   segscan     out[i] = the operator over the elements of i's segment up to i
#   segreduce   out[s] = the operator over the whole of segment s, one number per segment,
#               packed, and how many segments there were
# The scan carries pairs (flag, value), combined as (f1, v1) + (f2, v2) = (f1 or f2,
# if f2 then v2 else v1 op v2) -- associative, so the three-phase scan applies unchanged.
#
# Parity discipline, as the scan's guard states it:
#   - EXACT WITNESSES: whole numbers (negatives included), the plain loop's answer element
#     for element, for all three operators, at sizes that cross every level, with segments of
#     every length, with no flag, and with a flag everywhere;
#   - a TOLERANCE BAND for sums whose partials round, set from measurement;
#   - NEGATIVE SIBLINGS: wrong sizes, aliased buffers, a freed buffer, an unknown operator,
#     no device -- and the happy path counts ZERO fallbacks.
#
# Run with Ring++: rnxc gpu_segscan_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(10)

S_OK = 0
S_FALLBACK = 1
S_STALE = 2
S_BADARG = 3
S_TOOLARGE = 4

aOpNames = [ "sum", "max", "min" ]

? "-- Scene 0: the ops refuse the fallback way before there is a device --"
chk("a segmented scan before Init answers FALLBACK", StzEngineGpuOpSegScan(1, 2, 3, 100, 0) = S_FALLBACK)
aF = StzEngineGpuOpSegReduce(1, 2, 3, 100, 0)
chk("...and so does the reduction", aF[1] = S_FALLBACK)

oG = new stzGpu
bDevice = oG.IsAvailable()
if NOT bDevice
	? "  NO GPU ON THIS MACHINE -- the scenes below need a device; the fallback scene above is the CI coverage"
else
	? "  device: [" + StzEngineGpuSelectedAdapter() + "] " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

	? ""
	? "-- Scene 1: the segmented scan, exact, three operators, every level, segments of every length --"
	$t0 = clock()
	StzEngineGpuCountersReset()
	for nN in [ 1, 2, 255, 256, 257, 4096, 65537, 1000003 ]
		aIn = []
		aFl = []
		for i = 1 to nN
			aIn + (((i * 5) % 7) - 3)
			aFl + (((i * 7919) % 97) < 3)
		next
		hI = StzEngineGpuBufferNew(nN * 4)
		hF = StzEngineGpuBufferNew(nN * 4)
		hO = StzEngineGpuBufferNew(nN * 4)
		StzEngineGpuBufferUploadList(hI, aIn)
		StzEngineGpuBufferUploadList(hF, aFl)
		for nOp = 0 to 2
			nSt = StzEngineGpuOpSegScan(hI, hF, hO, nN, nOp)
			aOut = StzEngineGpuBufferDownloadList(hO, nN)
			aRef = _RefScan(aIn, aFl, nOp)
			bSame = (nSt = S_OK and @@(aOut) = @@(aRef))
			chk("n = " + nN + " " + aOpNames[nOp + 1] + " (" + StzEngineGpuSegScanDispatches(nN) + " dispatches): every element equals the loop's, to the bit", bSame)
		next
		StzEngineGpuBufferFree(hI)
		StzEngineGpuBufferFree(hF)
		StzEngineGpuBufferFree(hO)
	next
	nN = 100000
	aIn = []
	aNone = []
	aAll = []
	for i = 1 to nN
		aIn + (((i * 5) % 7) - 3)
		aNone + 0
		aAll + 1
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hF = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	hP = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuBufferUploadList(hF, aNone)
	StzEngineGpuOpSegScan(hI, hF, hO, nN, 0)
	StzEngineGpuOpScan(hI, hP, nN, 0)
	chk("no flag at all is one segment, so a segmented sum is the plain scan's, to the bit (100,000 elements)", @@(StzEngineGpuBufferDownloadList(hO, nN)) = @@(StzEngineGpuBufferDownloadList(hP, nN)))
	StzEngineGpuBufferUploadList(hF, aAll)
	StzEngineGpuOpSegScan(hI, hF, hO, nN, 1)
	chk("a flag on every element makes every element its own segment, so any operator returns the input", @@(StzEngineGpuBufferDownloadList(hO, nN)) = @@(aIn))
	aZero = [ 0, 5, 0, 5, 0 ]
	StzEngineGpuBufferFree(hF)
	hF2 = StzEngineGpuBufferNew(20)
	hI2 = StzEngineGpuBufferNew(20)
	hO2 = StzEngineGpuBufferNew(20)
	StzEngineGpuBufferUploadList(hF2, [ 0, 0, 1, 0, 0 ])
	StzEngineGpuBufferUploadList(hI2, [ 1, 2, 3, 4, 5 ])
	StzEngineGpuOpSegScan(hI2, hF2, hO2, 5, 0)
	chk("element 0 starts a segment whatever its flag says: flags [0 0 1 0 0] over [1 2 3 4 5] give [1 3 3 7 12]", @@(StzEngineGpuBufferDownloadList(hO2, 5)) = "[ 1, 3, 3, 7, 12 ]")
	StzEngineGpuBufferFree(hF2)
	StzEngineGpuBufferFree(hI2)
	StzEngineGpuBufferFree(hO2)
	StzEngineGpuBufferFree(hP)
	chk("the happy path counted zero fallbacks", StzEngineGpuCounter(3) = 0)
	? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 2: the reduction, one number per segment --"
	$t0 = clock()
	for nN in [ 1, 255, 257, 65537, 1000003 ]
		aIn = []
		aFl = []
		for i = 1 to nN
			aIn + (((i * 5) % 7) - 3)
			aFl + (((i * 7919) % 97) < 3)
		next
		hI = StzEngineGpuBufferNew(nN * 4)
		hF = StzEngineGpuBufferNew(nN * 4)
		hO = StzEngineGpuBufferNew(nN * 4)
		StzEngineGpuBufferUploadList(hI, aIn)
		StzEngineGpuBufferUploadList(hF, aFl)
		for nOp = 0 to 2
			aRes = StzEngineGpuOpSegReduce(hI, hF, hO, nN, nOp)
			nSeg = floor(aRes[2])
			aOut = []
			if nSeg > 0
				aOut = StzEngineGpuBufferDownloadList(hO, nSeg)
			ok
			aRef = _RefReduce(aIn, aFl, nOp)
			chk("n = " + nN + " " + aOpNames[nOp + 1] + ": " + nSeg + " segments, each the loop's number, to the bit", aRes[1] = S_OK and nSeg = len(aRef) and @@(aOut) = @@(aRef))
		next
		StzEngineGpuBufferFree(hI)
		StzEngineGpuBufferFree(hF)
		StzEngineGpuBufferFree(hO)
	next
	hI = StzEngineGpuBufferNew(40)
	hF = StzEngineGpuBufferNew(40)
	hO = StzEngineGpuBufferNew(40)
	StzEngineGpuBufferUploadList(hI, [ 4, 1, 7, 2, 9, 3, 8, 5, 6, 0 ])
	StzEngineGpuBufferUploadList(hF, [ 1, 0, 0, 1, 0, 0, 0, 1, 0, 0 ])
	aRes = StzEngineGpuOpSegReduce(hI, hF, hO, 10, 1)
	chk("segments [4 1 7] [2 9 3 8] [5 6 0]: the largest of each is [7 9 6], three segments", aRes[2] = 3 and @@(StzEngineGpuBufferDownloadList(hO, 3)) = "[ 7, 9, 6 ]")
	aRes = StzEngineGpuOpSegReduce(hI, hF, hO, 10, 0)
	chk("...the sums are [12 22 11]", @@(StzEngineGpuBufferDownloadList(hO, 3)) = "[ 12, 22, 11 ]")
	aRes = StzEngineGpuOpSegReduce(hI, hF, hO, 10, 2)
	chk("...the smallest are [1 2 0]", @@(StzEngineGpuBufferDownloadList(hO, 3)) = "[ 1, 2, 0 ]")
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hF)
	StzEngineGpuBufferFree(hO)
	? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 3: a sum whose partials round, against the loop in f64 --"
	nN = 100000
	aIn = []
	aFl = []
	for i = 1 to nN
		aIn + (((i * 37) % 1000) / 1000.0 + 0.001)
		aFl + (((i * 7919) % 997) < 2)
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hF = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuBufferUploadList(hF, aFl)
	aUp = StzEngineGpuBufferDownloadList(hI, nN)
	StzEngineGpuOpSegScan(hI, hF, hO, nN, 0)
	aOut = StzEngineGpuBufferDownloadList(hO, nN)
	aRef = _RefScan(aUp, aFl, 0)
	nMaxRel = 0
	for i = 1 to nN
		_r_ = fabs(aOut[i] - aRef[i]) / aRef[i]
		if _r_ > nMaxRel
			nMaxRel = _r_
		ok
	next
	? "  measured max relative error against the f64 segmented scan of the uploaded values, n = 100000: " + nMaxRel
	chk("band: relative error < 1e-5 (the band is set from the measurement printed above)", nMaxRel < 0.00001)
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hF)
	StzEngineGpuBufferFree(hO)

	? ""
	? "-- Scene 4: one submit, dispatches counted, the scratch kept and given back --"
	nN = 100000
	aIn = []
	aFl = []
	for i = 1 to nN
		aIn + (((i * 5) % 7) - 3)
		aFl + (((i * 7919) % 97) < 3)
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hF = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuBufferUploadList(hF, aFl)
	StzEngineGpuOpSegScan(hI, hF, hO, nN, 0)
	StzEngineGpuSync()
	nD0 = StzEngineGpuCounter(0)
	nS0 = StzEngineGpuCounter(6)
	nL0 = StzEngineGpuCounter(8)
	nF0 = StzEngineGpuCounter(3)
	StzEngineGpuOpSegScan(hI, hF, hO, nN, 0)
	StzEngineGpuSync()
	chk("a segmented scan of 100,000 is " + StzEngineGpuSegScanDispatches(nN) + " dispatches (the counter says " + (StzEngineGpuCounter(0) - nD0) + ")", StzEngineGpuCounter(0) - nD0 = StzEngineGpuSegScanDispatches(nN) and StzEngineGpuSegScanDispatches(nN) = 5)
	chk("...in ONE queue submit (the counter says " + (StzEngineGpuCounter(6) - nS0) + ")", StzEngineGpuCounter(6) - nS0 = 1)
	chk("...the scratch is kept, not made again: live buffers " + nL0 + " before the call and " + StzEngineGpuCounter(8) + " after", StzEngineGpuCounter(8) = nL0)
	chk("...and nothing fell back", StzEngineGpuCounter(3) = nF0)
	nLive = StzEngineGpuCounter(8)
	StzEngineGpuSegScanRelease()
	chk("SegScanRelease gives the three scratch buffers back (live buffers " + nLive + " then " + StzEngineGpuCounter(8) + ")", StzEngineGpuCounter(8) = nLive - 3)

	? ""
	? "-- Scene 5: what it refuses --"
	chk("n = 0 is BAD_ARG", StzEngineGpuOpSegScan(hI, hF, hO, 0, 0) = S_BADARG)
	chk("an unknown operator is BAD_ARG", StzEngineGpuOpSegScan(hI, hF, hO, nN, 3) = S_BADARG and StzEngineGpuOpSegScan(hI, hF, hO, nN, 0 - 1) = S_BADARG)
	chk("the same buffer twice is BAD_ARG (WebGPU aliasing validation)", StzEngineGpuOpSegScan(hI, hI, hO, nN, 0) = S_BADARG and StzEngineGpuOpSegScan(hI, hF, hI, nN, 0) = S_BADARG and StzEngineGpuOpSegScan(hI, hF, hF, nN, 0) = S_BADARG)
	chk("an output too small is BAD_ARG", StzEngineGpuOpSegScan(hI, hF, hO, nN + 1, 0) = S_BADARG)
	aR = StzEngineGpuOpSegReduce(hI, hF, hO, 16777217, 0)
	chk("a reduction of more than 16,777,216 elements is refused by name (TOO_LARGE): the compaction's counts are f32", aR[1] = S_TOOLARGE)
	StzEngineGpuBufferFree(hO)
	chk("a freed output answers STALE", StzEngineGpuOpSegScan(hI, hF, hO, nN, 0) = S_STALE)
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hF)

	? ""
	? "-- Scene 6: the face, lists in and lists out --"
	aA = oG.SegmentedScan([ 1, 2, 3, 4, 5, 6 ], [ 1, 0, 0, 1, 0, 0 ], "sum")
	aB = oG.SegmentedReduce([ 4, 1, 7, 2, 9, 3, 8, 5, 6, 0 ], [ 1, 0, 0, 1, 0, 0, 0, 1, 0, 0 ], "max")
	aC = oG.SegmentedReduce([ 4, 1, 7 ], [ 0, 0, 0 ], "min")
	chk("SegmentedScan([1..6], flags [1 0 0 1 0 0], 'sum') = [1 3 6 4 9 15]", @@(aA) = "[ 1, 3, 6, 4, 9, 15 ]")
	chk("SegmentedReduce of the three segments, 'max' = [7 9 6]", @@(aB) = "[ 7, 9, 6 ]")
	chk("no flag is one segment: SegmentedReduce([4 1 7], 'min') = [1]", @@(aC) = "[ 1 ]")
	cErr = ""
	try
		oG.SegmentedReduce([ 1, 2 ], [ 1 ], "sum")
	catch
		cErr = cCatchError
	done
	chk("flags of another length are refused by name (" + left(cErr, 50) + ")", StzFindFirst("flags of the same length", cErr) > 0)
	cErr = ""
	try
		oG.SegmentedScan([ 1, 2 ], [ 1, 0 ], "mean")
	catch
		cErr = cCatchError
	done
	chk("an unknown operator is refused by name (" + left(cErr, 60) + ")", StzFindFirst("one of sum, max, min", cErr) > 0)

	? ""
	? "-- Scene 7: how fast, resident, against the plain scan --"
	$t0 = clock()
	nN = 16000000
	hI = StzEngineGpuBufferNew(nN * 4)
	hF = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	if hI = 0 or hF = 0 or hO = 0
		? "  (no room for three 64 MB buffers: scene skipped)"
	else
		oG.Wake(400)
		StzEngineGpuSync()
		nBestSeg = 1000000
		nBestScan = 1000000
		for nRep = 1 to 5
			StzEngineGpuSync()
			nT = StzEngineWatchTimestampNs()
			for q = 1 to 5
				StzEngineGpuOpSegScan(hI, hF, hO, nN, 0)
			next
			StzEngineGpuSync()
			nMs = (StzEngineWatchTimestampNs() - nT) / 1000000 / 5
			if nMs < nBestSeg
				nBestSeg = nMs
			ok
			StzEngineGpuSync()
			nT = StzEngineWatchTimestampNs()
			for q = 1 to 5
				StzEngineGpuOpScan(hI, hO, nN, 0)
			next
			StzEngineGpuSync()
			nMs = (StzEngineWatchTimestampNs() - nT) / 1000000 / 5
			if nMs < nBestScan
				nBestScan = nMs
			ok
		next
		? "  16,000,000 floats, " + StzEngineGpuSegScanDispatches(nN) + " dispatches: segmented scan " + nBestSeg + " ms, plain scan " + nBestScan + " ms (" + (nBestSeg / nBestScan) + " times)"
		chk("a segmented scan costs under 6 plain scans (a sanity line from the measurement above, not a goal: it moves two more vectors, the flags in and the carried flags out)", nBestSeg / nBestScan < 6)
	ok
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hF)
	StzEngineGpuBufferFree(hO)
	? "  (scene 7: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 8: the route -- the loop against the device through the face, measured, stored, followed --"
	$t0 = clock()
	aCal = oG.CalibrateSegmentedReduce()
	? "  adapter " + aCal[:adapter] + ", flat line at " + aCal[:flat] + " (" + aCal[:flatwhy] + ")"
	for aCell in aCal[:cells]
		? "  n = " + aCell[2] + ": loop " + aCell[3] + " ms, face " + aCell[4] + " ms, ratio " + aCell[5]
	next
	chk("the control rung (the first, measured again at the end) stayed within 2x, so the line is stored", NOT aCal[:confounded])
	bFollow = 1
	for aCell in aCal[:cells]
		bWin = (aCell[5] >= 1.3)
		if (StzEngineGpuCalibRouteShaped("segreduce", aCell[2], 1) = 1) != bWin
			bFollow = 0
		ok
	next
	chk("the route sends a size to the device exactly where its measured ratio reached 1.3, at every rung", bFollow)
	aNum = []
	aFlg = []
	for i = 1 to 200000
		aNum + ((i * 5) % 7)
		aFlg + (i % 64 = 1)
	next
	chk("SegmentedReduceRouted gives the same numbers whichever side it ran on (200,000 whole numbers, 3,125 segments, to the bit)", @@(oG.SegmentedReduceRouted(aNum, aFlg, "sum")) = @@(oG._SegReduceCpu(aNum, aFlg, "sum")))
	chk("a short list stays on the loop and SegmentedReduceRouted answers [3 9]", @@(oG.SegmentedReduceRouted([ 1, 2, 4, 5 ], [ 1, 0, 1, 0 ], "sum")) = "[ 3, 9 ]" and StzEngineGpuCalibRouteShaped("segreduce", 4, 1) = 0)
	? "  (scene 8: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 9: puzzle 23, a running total that starts over --"
$t0 = clock()
NLc = char(10)
oQ = StzKernelPuzzleQ("kp-23")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages, names SegmentedScan and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("SegmentedScan", oQ.Task("en")) > 0 and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "in b" + NLc + "out c" + NLc + "shared t 256" + NLc + "shared s 256" + NLc + "shared r 256" + NLc + "stage { @t[@l] = @a }" + NLc + "stage { @s[@l] = when(@b < 2, 1, 0) }" + NLc
cIds = "stage { @r[@l] = sum(j, 0, 256, when(j <= @l, @s[j], 0)) }" + NLc
cExc = "stage { @r[@l] = sum(j, 0, 256, when(j < @l, @s[j], 0)) }" + NLc
# the verdicts were worked out from the data before the first run. a is (i * 7) % 13 = 0 7 1 8 2 9 3 10 ...;
# b is (i * 3) % 7 = 0 3 6 2 5 1 4 0 ..., so a mark below 2 starts a segment at i = 0, 5, 7, 12, 14 ... and the
# reference gives 0 7 8 16 18 | 9 12 | 10 ... (a[0] is 0, which hides some mistakes at element 1):
#   forgets the resets:    i = 5 adds everything before it (27) where its own 9 is owed: element 6
#   a start joins the one before: the count before i = 5 is 1, shared with i = 1 .. 4, so i = 5 totals 27: element 6
#   compares the marks:    i = 5 (a start, mark 1) matches only i = 0 (a 0) and i = 5, so it is right; i = 6 (mark 4)
#                          matches 1 2 3 4 and itself, 21 for 12 owed: element 7
aCases = [
	[ cHead + cIds + "body { @c = sum(j, 0, 256, when(j <= @l and @r[j] == @r[@l], @t[j], 0)) }", "verified" ],
	[ cHead + cExc + "body { @c = sum(j, 0, 256, when(j <= @l and @r[j] + @s[j] == @r[@l] + @s[@l], @t[j], 0)) }", "verified" ],
	[ cHead + "body { @c = sum(j, 0, 256, when(j <= @l, @t[j], 0)) }", "mismatch at element 6" ],
	[ cHead + cIds + "body { @c = sum(j, 0, 256, when(j <= @l and @s[j] == @s[@l], @t[j], 0)) }", "mismatch at element 7" ],
	[ cHead + cExc + "body { @c = sum(j, 0, 256, when(j <= @l and @r[j] == @r[@l], @t[j], 0)) }", "mismatch at element 6" ]
]
nAgree = 0
for aQ in aCases
	if bDevice
		cV = oQ.Grade(aQ[1])
	else
		cV = oQ.GradeOnCpu(aQ[1])
	ok
	cShow = replace(aQ[1], NLc, " / ")
	cShow = replace(cShow, "in a / in b / out c / shared t 256 / shared s 256 / shared r 256 / stage { @t[@l] = @a } / stage { @s[@l] = when(@b < 2, 1, 0) } / ", "")
	chk(cShow + " -> " + aQ[2] + " (" + cV + ")", cV = aQ[2])
	if oQ.GradeOnCpu(aQ[1]) = aQ[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
cV = oQ.Grade("in a" + NLc + "in b" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @t[@l] + @t[@l - 1] }" + NLc + "body { @c = @t[@l] }")
chk("a stage that reads the array it writes is refused by name (" + left(cV, 60) + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("cannot read the array it writes", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-23")
	aPr = oE.ProveItself()
	chk("the exercise proves itself through the System's checker: wrong refused " + aPr[:wrong] + ", right accepted " + aPr[:right] + ", failures " + @@(aPr[:failures]),
		aPr[:wrong] = 5 and aPr[:right] = 2 and len(aPr[:failures]) = 0)
ok
? "  (scene 9: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
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

# the loop's segmented scan: nOp 0 sum, 1 max, 2 min; element 1 always starts a segment
func _RefScan aIn, aFl, nOp
	aOut = []
	nAcc = 0
	nN = len(aIn)
	for i = 1 to nN
		if i = 1 or aFl[i] != 0
			nAcc = aIn[i]
		else
			if nOp = 0
				nAcc += aIn[i]
			but nOp = 1
				if aIn[i] > nAcc
					nAcc = aIn[i]
				ok
			else
				if aIn[i] < nAcc
					nAcc = aIn[i]
				ok
			ok
		ok
		aOut + nAcc
	next
	return aOut

# the loop's segmented reduction: the last element of each segment of its segmented scan
func _RefReduce aIn, aFl, nOp
	aS = _RefScan(aIn, aFl, nOp)
	aOut = []
	nN = len(aIn)
	for i = 1 to nN
		if i = nN or aFl[i + 1] != 0
			aOut + aS[i]
		ok
	next
	return aOut
