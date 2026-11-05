# GB0 -- THE RADIX SORT, the library layer's third op (SOFTANZA_GPU_PLAN.md, GB0;
# built on the scan of gpu_scan_narrated.ring, as stream compaction is).
#
# Sort n f32 keys ascending or descending, STABLY, with the values that follow them
# (a key-value sort) or the permutation that sorts them (an argsort), on the device:
# the key becomes an unsigned integer that orders like the float; eight passes of four
# bits each; in a pass every group of 256 sorts its keys by the digit in shared memory
# (four one-bit splits, each a scan), a scan of the table of digit counts says where each
# group's run of each digit lands, and a scatter puts every key there.
#
# This guard proves a sort WITHOUT a reference sort to lean on, by what a sort IS:
#   - the keys come out in order (ascending or descending);
#   - the values come out as a PERMUTATION of 0 .. n - 1, every one exactly once;
#   - each value sits beside ITS OWN key (keys[value] is the key it carries);
#   - STABLE: where two keys are equal, their values stay in increasing order.
# Those four together say the output is a stable sort of the input, whatever the tree.
# The fractional data is also compared to Ring's own sort, element for element.
#
# Run with Ring++: rnxc gpu_sort_narrated.ring

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

? "-- Scene 0: the op refuses the fallback way before there is a device --"
chk("a sort before Init answers FALLBACK", StzEngineGpuOpSort(1, 2, 100, 0) = S_FALLBACK)
chk("...and so do the pairs and the argsort", StzEngineGpuOpSortPairs(1, 2, 3, 4, 100, 0) = S_FALLBACK and StzEngineGpuOpArgSort(1, 2, 100, 0) = S_FALLBACK)

oG = new stzGpu
bDevice = oG.IsAvailable()
if NOT bDevice
	? "  NO GPU ON THIS MACHINE -- the scenes below need a device; the fallback scene above is the CI coverage"
else
	? "  device: [" + StzEngineGpuSelectedAdapter() + "] " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

	? ""
	? "-- Scene 1: whole numbers with ties, across every level, both directions --"
	$t0 = clock()
	StzEngineGpuCountersReset()
	for nN in [ 1, 2, 255, 256, 257, 4096, 4352, 65537, 1000003 ]
		aIn = []
		for i = 1 to nN
			aIn + (((i * 7919) % 1000) - 500)
		next
		aVal = []
		for i = 1 to nN
			aVal + (i - 1)
		next
		hK = StzEngineGpuBufferNew(nN * 4)
		hV = StzEngineGpuBufferNew(nN * 4)
		hOK = StzEngineGpuBufferNew(nN * 4)
		hOV = StzEngineGpuBufferNew(nN * 4)
		StzEngineGpuBufferUploadList(hK, aIn)
		StzEngineGpuBufferUploadList(hV, aVal)
		for nDesc = 0 to 1
			nSt = StzEngineGpuOpSortPairs(hK, hV, hOK, hOV, nN, nDesc)
			aK = StzEngineGpuBufferDownloadList(hOK, nN)
			aV = StzEngineGpuBufferDownloadList(hOV, nN)
			cWhy = _Verify(aIn, aK, aV, nDesc)
			cDir = "ascending"
			if nDesc = 1 cDir = "descending" ok
			chk("n = " + nN + " " + cDir + " (" + StzEngineGpuSortDispatches(nN) + " dispatches): ordered, a permutation, each value beside its own key, stable" + cWhy, nSt = S_OK and cWhy = "")
		next
		StzEngineGpuBufferFree(hK)
		StzEngineGpuBufferFree(hV)
		StzEngineGpuBufferFree(hOK)
		StzEngineGpuBufferFree(hOV)
	next
	chk("the happy path counted zero fallbacks", StzEngineGpuCounter(3) = 0)
	? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 2: fractions, negatives and wide magnitudes, against Ring's own sort --"
	$t0 = clock()
	nN = 100000
	aIn = []
	for i = 1 to nN
		_x_ = (((i * 7919) % 100003) - 50000) / 7
		if i % 11 = 0
			_x_ = _x_ * 100000000
		ok
		if i % 13 = 0
			_x_ = _x_ / 100000000
		ok
		aIn + _x_
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	aUp = StzEngineGpuBufferDownloadList(hI, nN)
	aRef = ring_sort(aUp)
	StzEngineGpuOpSort(hI, hO, nN, 0)
	aAsc = StzEngineGpuBufferDownloadList(hO, nN)
	chk("100,000 floats (negatives, 1e-8 to 1e10): the keys-only sort equals Ring's sort of the same values, element for element", @@(aAsc) = @@(aRef))
	StzEngineGpuOpSort(hI, hO, nN, 1)
	aDesc = StzEngineGpuBufferDownloadList(hO, nN)
	bRev = 1
	for i = 1 to nN
		if aDesc[i] != aRef[nN + 1 - i]
			bRev = 0
			exit
		ok
	next
	chk("...and descending is its reverse, element for element", bRev)
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hO)
	? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 3: the argsort, a permutation that sorts --"
	nN = 100000
	aIn = []
	for i = 1 to nN
		aIn + (((i * 7919) % 1000) - 500)
	next
	hK = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hK, aIn)
	nSt = StzEngineGpuOpArgSort(hK, hO, nN, 0)
	aIdx = StzEngineGpuBufferDownloadList(hO, nN)
	aSorted = []
	for i = 1 to nN
		aSorted + aIn[aIdx[i] + 1]
	next
	cWhy = _Verify(aIn, aSorted, aIdx, 0)
	chk("the argsort of 100,000 keys with ties: the places sort the keys, each exactly once, ties in their original order" + cWhy, nSt = S_OK and cWhy = "")
	nSt = StzEngineGpuOpArgSort(hK, hO, nN, 1)
	aIdx = StzEngineGpuBufferDownloadList(hO, nN)
	aSorted = []
	for i = 1 to nN
		aSorted + aIn[aIdx[i] + 1]
	next
	cWhy = _Verify(aIn, aSorted, aIdx, 1)
	chk("...and descending, ties still in their original order" + cWhy, nSt = S_OK and cWhy = "")
	StzEngineGpuBufferFree(hK)
	StzEngineGpuBufferFree(hO)

	? ""
	? "-- Scene 4: one submit, the dispatches counted, the scratch kept between calls and given back --"
	nN = 100000
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	StzEngineGpuOpSort(hI, hO, nN, 0)
	StzEngineGpuSync()
	nD0 = StzEngineGpuCounter(0)
	nS0 = StzEngineGpuCounter(6)
	nL0 = StzEngineGpuCounter(8)
	nF0 = StzEngineGpuCounter(3)
	StzEngineGpuOpSort(hI, hO, nN, 0)
	StzEngineGpuSync()
	chk("a sort of 100,000 is " + StzEngineGpuSortDispatches(nN) + " dispatches (the counter says " + (StzEngineGpuCounter(0) - nD0) + "): the keys in, eight passes of local sort + scan + scatter, the keys out", StzEngineGpuCounter(0) - nD0 = StzEngineGpuSortDispatches(nN) and StzEngineGpuSortDispatches(nN) = 42)
	chk("...in ONE queue submit, nothing read back (the counter says " + (StzEngineGpuCounter(6) - nS0) + ")", StzEngineGpuCounter(6) - nS0 = 1)
	chk("...the scratch is kept, not made again: live buffers " + nL0 + " before the call and " + StzEngineGpuCounter(8) + " after", StzEngineGpuCounter(8) = nL0)
	chk("...and nothing fell back", StzEngineGpuCounter(3) = nF0)
	nLive = StzEngineGpuCounter(8)
	StzEngineGpuSortRelease()
	chk("SortRelease gives the seven scratch buffers back (live buffers " + nLive + " then " + StzEngineGpuCounter(8) + ")", StzEngineGpuCounter(8) = nLive - 7)
	chk("the dispatch counts: 26 for one group, 42 for 100,000, and one more level of scan makes the table longer",
		StzEngineGpuSortDispatches(100) = 26 and StzEngineGpuSortDispatches(100000) = 42 and StzEngineGpuSortDispatches(4352) = 42 and StzEngineGpuSortDispatches(16777216) = 58)

	? ""
	? "-- Scene 5: what it refuses --"
	chk("n = 0 is BAD_ARG", StzEngineGpuOpSort(hI, hO, 0, 0) = S_BADARG)
	chk("the same buffer in and out is BAD_ARG (WebGPU aliasing validation)", StzEngineGpuOpSort(hI, hI, nN, 0) = S_BADARG)
	chk("the values as the keys, or an output as an input, is BAD_ARG", StzEngineGpuOpSortPairs(hI, hI, hO, hO, nN, 0) = S_BADARG and StzEngineGpuOpSortPairs(hI, hO, hO, hI, nN, 0) = S_BADARG)
	chk("an output too small is BAD_ARG", StzEngineGpuOpSort(hI, hO, nN + 1, 0) = S_BADARG)
	chk("more than 16,777,216 elements are refused by name (TOO_LARGE): the scan and the table are f32", StzEngineGpuOpSort(hI, hO, 16777217, 0) = S_TOOLARGE)
	StzEngineGpuBufferFree(hO)
	chk("a freed output answers STALE", StzEngineGpuOpSort(hI, hO, nN, 0) = S_STALE)
	StzEngineGpuBufferFree(hI)

	? ""
	? "-- Scene 6: the face, lists in and lists out --"
	aA = oG.Sort([ 3, 1, 4, 1, 5, 9, 2, 6 ])
	aB = oG.SortDescending([ 3, 1, 4, 1, 5, 9, 2, 6 ])
	aC = oG.SortPairs([ 3, 1, 4, 1, 5 ], [ 10, 20, 30, 40, 50 ])
	aD = oG.ArgSort([ 3, 1, 4, 1, 5 ])
	chk("Sort([3 1 4 1 5 9 2 6]) = [1 1 2 3 4 5 6 9]", @@(aA) = "[ 1, 1, 2, 3, 4, 5, 6, 9 ]")
	chk("SortDescending of the same = [9 6 5 4 3 2 1 1]", @@(aB) = "[ 9, 6, 5, 4, 3, 2, 1, 1 ]")
	chk("SortPairs: keys [3 1 4 1 5] carry [10 20 30 40 50] -> keys [1 1 3 4 5], values [20 40 10 30 50] (the two 1s keep their order)", @@(aC) = "[ [ 1, 1, 3, 4, 5 ], [ 20, 40, 10, 30, 50 ] ]")
	chk("ArgSort([3 1 4 1 5]) = [2 4 1 3 5]: 1-based places, the two 1s in their order", @@(aD) = "[ 2, 4, 1, 3, 5 ]")
	cErr = ""
	try
		oG.Sort([])
	catch
		cErr = cCatchError
	done
	chk("an empty list is refused by name (" + left(cErr, 50) + ")", StzFindFirst("non-empty list", cErr) > 0)
	cErr = ""
	try
		oG.SortPairs([ 1, 2, 3 ], [ 1, 2 ])
	catch
		cErr = cCatchError
	done
	chk("values of another length are refused by name (" + left(cErr, 50) + ")", StzFindFirst("values of the same length", cErr) > 0)

	? ""
	? "-- Scene 7: how fast, resident --"
	$t0 = clock()
	nN = 1000000
	aIn = []
	for i = 1 to nN
		aIn + (((i * 7919) % 100003) / 7)
	next
	hI = StzEngineGpuBufferNew(nN * 4)
	hO = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hI, aIn)
	oG.Wake(400)
	StzEngineGpuSync()
	StzEngineGpuOpSort(hI, hO, nN, 0)
	nBest = 1000000
	for nRep = 1 to 5
		StzEngineGpuSync()
		nT = StzEngineWatchTimestampNs()
		for q = 1 to 3
			StzEngineGpuOpSort(hI, hO, nN, 0)
		next
		StzEngineGpuSync()
		nMs = (StzEngineWatchTimestampNs() - nT) / 1000000 / 3
		if nMs < nBest
			nBest = nMs
		ok
	next
	nT = StzEngineWatchTimestampNs()
	aRing = ring_sort(aIn)
	nRingMs = (StzEngineWatchTimestampNs() - nT) / 1000000
	? "  1,000,000 floats resident: " + nBest + " ms on the device (" + (nN / nBest / 1000) + " million keys a second); Ring's own sort of the same list: " + nRingMs + " ms"
	aOut = StzEngineGpuBufferDownloadList(hO, nN)
	aRing = ring_sort(StzEngineGpuBufferDownloadList(hI, nN))
	chk("the resident sort's output is Ring's sort of the same f32 values, element for element (1,000,000 of them)", @@(aOut) = @@(aRing))
	StzEngineGpuBufferFree(hI)
	StzEngineGpuBufferFree(hO)
	? "  (scene 7: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 8: the route -- Ring's sort against the device through the face, measured, stored, followed --"
	$t0 = clock()
	aCal = oG.CalibrateSort()
	? "  adapter " + aCal[:adapter] + ", flat line at " + aCal[:flat] + " (" + aCal[:flatwhy] + ")"
	for aCell in aCal[:cells]
		? "  n = " + aCell[2] + ": Ring's sort " + aCell[3] + " ms, face " + aCell[4] + " ms, ratio " + aCell[5]
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
			if (StzEngineGpuCalibRouteShaped("sort", aCell[2], 1) = 1) != bWin
				bFollow = 0
			ok
		next
		chk("the route sends a size to the device exactly where its measured ratio reached 1.3, at every rung", bFollow)
		aNum = []
		for i = 1 to 200000
			aNum + (((i * 7919) % 100003) / 7)
		next
		chk("SortRouted gives the same sorted list whichever side it ran on (200,000 floats, element for element)", @@(oG.SortRouted(aNum)) = @@(oG.Sort(aNum)) or @@(oG.SortRouted(aNum)) = @@(ring_sort(aNum)))
		chk("a short list stays on Ring's sort and SortRouted answers [1 2 3]", @@(oG.SortRouted([ 3, 1, 2 ])) = "[ 1, 2, 3 ]" and StzEngineGpuCalibRouteShaped("sort", 3, 1) = 0)
	ok
	? "  (scene 8: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 9: puzzle 22, sort a group --"
$t0 = clock()
NLc = char(10)
oQ = StzKernelPuzzleQ("kp-22")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop, and names the library's Sort",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0 and StzFindFirst("library's `Sort`", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "shared r 256" + NLc + "stage { @t[@l] = @a }" + NLc
cBody = NLc + "body { @c = sum(j, 0, 256, when(@r[j] == @l, @t[j], 0)) }"
# the verdicts were worked out from the data before the first run. a is (i * 7) % 13; the first group of 256
# holds the value 0 twenty times (at i = 0, 13 ... 247), so the sorted group starts with twenty 0s:
#   ties share a rank:  the twenty 0s all have rank 0, slot 0 sums them (0) and slots 1 to 19 find nobody (0):
#                       all equal to the owed 0s; slot 20 owes 1 and the 1s share rank 20: element 21
#   counts itself:      every rank is one too high, so slot k holds what slot k - 1 was owed: the twenty 0s
#                       still fill slots 0 to 19 (slot 0 finds nobody, a 0), and slot 20 gets a 0 where a 1 is owed: element 21
#   the larger:         the biggest value (12) goes to slot 0 where 0 is owed: element 1
aCases = [
	[ cHead + "stage { @r[@l] = sum(j, 0, 256, when(@t[j] < @t[@l] or (@t[j] == @t[@l] and j < @l), 1, 0)) }" + cBody, "verified" ],
	[ cHead + "stage { @r[@l] = sum(j, 0, 256, when(@t[j] < @t[@l] or (@t[j] == @t[@l] and j > @l), 1, 0)) }" + cBody, "verified" ],
	[ cHead + "stage { @r[@l] = sum(j, 0, 256, when(@t[j] < @t[@l], 1, 0)) }" + cBody, "mismatch at element 21" ],
	[ cHead + "stage { @r[@l] = sum(j, 0, 256, when(@t[j] > @t[@l] or (@t[j] == @t[@l] and j < @l), 1, 0)) }" + cBody, "mismatch at element 1" ],
	[ cHead + "stage { @r[@l] = sum(j, 0, 256, when(@t[j] < @t[@l] or (@t[j] == @t[@l] and j <= @l), 1, 0)) }" + cBody, "mismatch at element 21" ]
]
nAgree = 0
for aQ in aCases
	if bDevice
		cV = oQ.Grade(aQ[1])
	else
		cV = oQ.GradeOnCpu(aQ[1])
	ok
	chk(replace(replace(replace(replace(aQ[1], NLc, " / "), "in a / out c / ", ""), "shared t 256 / shared r 256 / stage { @t[@l] = @a } / ", ""), " / body { @c = sum(j, 0, 256, when(@r[j] == @l, @t[j], 0)) }", "") + " -> " + aQ[2] + " (" + cV + ")", cV = aQ[2])
	if oQ.GradeOnCpu(aQ[1]) = aQ[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
cV = oQ.Grade("in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @t[@l] + @t[@l - 1] }" + NLc + "body { @c = @t[@l] }")
chk("a stage that reads the array it writes is refused by name (" + left(cV, 60) + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("cannot read the array it writes", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-22")
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

# "" when aK, aV are a stable sort of aIn (aV holds 0-based places in aIn); else the first reason, with a leading ": "
func _Verify aIn, aK, aV, nDesc
	nN = len(aIn)
	if len(aK) != nN or len(aV) != nN
		return ": the output has the wrong length"
	ok
	aSeen = []
	for i = 1 to nN
		aSeen + 0
	next
	for i = 1 to nN
		nPlace = aV[i] + 1
		if nPlace < 1 or nPlace > nN or aSeen[nPlace] = 1
			return ": not a permutation at " + i + " (value " + aV[i] + ")"
		ok
		aSeen[nPlace] = 1
		if aK[i] != aIn[nPlace]
			return ": the key at " + i + " is not the key its value carries"
		ok
		if i > 1
			if nDesc = 0 and aK[i] < aK[i - 1]
				return ": out of order at " + i
			ok
			if nDesc = 1 and aK[i] > aK[i - 1]
				return ": out of order at " + i
			ok
			if aK[i] = aK[i - 1] and aV[i] < aV[i - 1]
				return ": unstable at " + i
			ok
		ok
	next
	return ""
