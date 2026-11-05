# GB0 -- THE CSR SPARSE-DENSE PRODUCT, the library layer's last op (SOFTANZA_GPU_PLAN.md,
# GB0; what the graph and neural desks asked for).
#
# y = A x with A a sparse matrix in CSR form (row offsets, columns, values; offsets and
# columns travel as f32 whole numbers, exact below 2^24), x a dense vector -- or, with k
# columns, a dense matrix. Two kernels because the shape decides: one thread per output
# element walking its row (no waste on a short row), and one workgroup of 256 threads per row
# whose partials a tree adds (right for a long row). The variant is chosen by the mean row
# length against a threshold this guard measures, or by the caller.
#
# Parity discipline, as the scan's guard states it:
#   - EXACT WITNESSES: whole numbers (negatives included), the plain loop's answer, to the
#     bit, for BOTH kernels and for auto, on matrices of every shape that matters: rows of
#     1 to 300 entries, empty rows, a few huge rows among tiny ones, a single row, a single entry;
#   - the dense-matrix product against the loop at k = 1, 2, 3, 8;
#   - a TOLERANCE BAND where the sums round, set from measurement;
#   - NEGATIVE SIBLINGS: wrong sizes, aliased buffers, a freed buffer, an unknown variant, an
#     oversized matrix, no device -- and the happy path counts ZERO fallbacks.
# The CSR is deliberately NOT validated by the op (reading the offsets back would cost more
# than the product): the face checks the one thing it can see cheaply, that the offsets start at
# 0 and end at the number of entries.
#
# Run with Ring++: rnxc gpu_spmv_narrated.ring

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

? "-- Scene 0: the ops refuse the fallback way before there is a device --"
chk("a sparse product before Init answers FALLBACK", StzEngineGpuOpSpmv(1, 2, 3, 4, 5, 10, 10, 0) = S_FALLBACK)
chk("...and so does the dense-matrix form", StzEngineGpuOpSpmm(1, 2, 3, 4, 5, 10, 10, 2) = S_FALLBACK)

oG = new stzGpu
bDevice = oG.IsAvailable()
if NOT bDevice
	? "  NO GPU ON THIS MACHINE -- the scenes below need a device; the fallback scene above is the CI coverage"
else
	? "  device: [" + StzEngineGpuSelectedAdapter() + "] " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

	? ""
	? "-- Scene 1: exact, both kernels and auto, matrices of every shape --"
	$t0 = clock()
	StzEngineGpuCountersReset()
	nCols = 777
	aX = _Xvec(nCols, 1)
	aShapes = []
	for nL in [ 1, 2, 5, 16, 31, 32, 100, 300 ]
		aLens = []
		for i = 1 to 500
			aLens + nL
		next
		aShapes + [ "500 rows of " + nL, aLens ]
	next
	aMixed = []
	for i = 1 to 600
		if i % 5 = 0
			aMixed + 0
		else
			aMixed + (i % 11)
		ok
	next
	aShapes + [ "600 rows, every fifth empty, the rest 1 to 10", aMixed ]
	aShapes + [ "a few huge rows among tiny ones", [ 0, 1, 3000, 0, 5, 2, 1500, 1, 0, 0, 700, 3, 0 ] ]
	aShapes + [ "a single row of 5,000", [ 5000 ] ]
	aShapes + [ "a single entry", [ 1 ] ]
	aShapes + [ "257 rows of 1 (crosses a workgroup)", _Fill(257, 1) ]
	for aS in aShapes
		aCsr = _Csr(aS[2], nCols)
		nR = len(aS[2])
		nZ = len(aCsr[2])
		aRef = _RefSpmv(aCsr[1], aCsr[2], aCsr[3], aX)
		hR = StzEngineGpuBufferNew((nR + 1) * 4)
		hC = StzEngineGpuBufferNew(nZ * 4)
		hV = StzEngineGpuBufferNew(nZ * 4)
		hX = StzEngineGpuBufferNew(nCols * 4)
		hY = StzEngineGpuBufferNew(nR * 4)
		StzEngineGpuBufferUploadList(hR, aCsr[1])
		StzEngineGpuBufferUploadList(hC, aCsr[2])
		StzEngineGpuBufferUploadList(hV, aCsr[3])
		StzEngineGpuBufferUploadList(hX, aX)
		cOk = ""
		for nVar = 0 to 2
			nSt = StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nZ, nVar)
			aOut = StzEngineGpuBufferDownloadList(hY, nR)
			if nSt != S_OK or @@(aOut) != @@(aRef)
				cOk += " [variant " + nVar + " differs]"
			ok
		next
		chk(aS[1] + " (" + nZ + " entries): variants auto, scalar and vector all equal the loop, to the bit" + cOk, cOk = "")
		StzEngineGpuBufferFree(hR)
		StzEngineGpuBufferFree(hC)
		StzEngineGpuBufferFree(hV)
		StzEngineGpuBufferFree(hX)
		StzEngineGpuBufferFree(hY)
	next
	chk("the happy path counted zero fallbacks", StzEngineGpuCounter(3) = 0)
	chk("auto picks the scalar kernel below a mean row length of " + 48 + " and the vector one from there", StzEngineGpuSpmvVariantFor(1000, 5000) = 1 and StzEngineGpuSpmvVariantFor(1000, 47000) = 1 and StzEngineGpuSpmvVariantFor(1000, 48000) = 2 and StzEngineGpuSpmvVariantFor(10, 10000) = 2)
	? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 2: the dense-matrix product, k columns --"
	$t0 = clock()
	aLens = []
	for i = 1 to 400
		if i % 7 = 0
			aLens + 0
		else
			aLens + (i % 13)
		ok
	next
	aCsr = _Csr(aLens, nCols)
	nR = 400
	nZ = len(aCsr[2])
	hR = StzEngineGpuBufferNew((nR + 1) * 4)
	hC = StzEngineGpuBufferNew(nZ * 4)
	hV = StzEngineGpuBufferNew(nZ * 4)
	StzEngineGpuBufferUploadList(hR, aCsr[1])
	StzEngineGpuBufferUploadList(hC, aCsr[2])
	StzEngineGpuBufferUploadList(hV, aCsr[3])
	for nK in [ 1, 2, 3, 8 ]
		aXk = _Xvec(nCols * nK, 1)
		hX = StzEngineGpuBufferNew(nCols * nK * 4)
		hY = StzEngineGpuBufferNew(nR * nK * 4)
		StzEngineGpuBufferUploadList(hX, aXk)
		nSt = StzEngineGpuOpSpmm(hR, hC, hV, hX, hY, nR, nZ, nK)
		aOut = StzEngineGpuBufferDownloadList(hY, nR * nK)
		aRef = _RefSpmm(aCsr[1], aCsr[2], aCsr[3], aXk, nK)
		chk("k = " + nK + ": " + nR + " x " + nK + " answers, every one the loop's, to the bit", nSt = S_OK and @@(aOut) = @@(aRef))
		StzEngineGpuBufferFree(hX)
		StzEngineGpuBufferFree(hY)
	next
	StzEngineGpuBufferFree(hR)
	StzEngineGpuBufferFree(hC)
	StzEngineGpuBufferFree(hV)
	? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 3: fractions, against the loop in f64 --"
	nR = 2000
	aLens = _Fill(nR, 20)
	aCsr = _Csr(aLens, nCols)
	nZ = len(aCsr[2])
	aVf = []
	for i = 1 to nZ
		aVf + (((i * 37) % 1000) / 1000.0 + 0.001)
	next
	aXf = []
	for i = 1 to nCols
		aXf + (((i * 91) % 997) / 997.0 + 0.001)
	next
	hR = StzEngineGpuBufferNew((nR + 1) * 4)
	hC = StzEngineGpuBufferNew(nZ * 4)
	hV = StzEngineGpuBufferNew(nZ * 4)
	hX = StzEngineGpuBufferNew(nCols * 4)
	hY = StzEngineGpuBufferNew(nR * 4)
	StzEngineGpuBufferUploadList(hR, aCsr[1])
	StzEngineGpuBufferUploadList(hC, aCsr[2])
	StzEngineGpuBufferUploadList(hV, aVf)
	StzEngineGpuBufferUploadList(hX, aXf)
	aRef = _RefSpmv(aCsr[1], aCsr[2], StzEngineGpuBufferDownloadList(hV, nZ), StzEngineGpuBufferDownloadList(hX, nCols))
	for nVar = 1 to 2
		StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nZ, nVar)
		aOut = StzEngineGpuBufferDownloadList(hY, nR)
		nMaxRel = 0
		for i = 1 to nR
			_r_ = fabs(aOut[i] - aRef[i]) / aRef[i]
			if _r_ > nMaxRel
				nMaxRel = _r_
			ok
		next
		? "  variant " + nVar + ": measured max relative error against the f64 product of the uploaded values, 2,000 rows of 20: " + nMaxRel
		chk("band: variant " + nVar + " relative error < 1e-5 (the band is set from the measurement printed above)", nMaxRel < 0.00001)
	next

	? ""
	? "-- Scene 4: one dispatch, one submit, no buffer made --"
	StzEngineGpuSync()
	nD0 = StzEngineGpuCounter(0)
	nS0 = StzEngineGpuCounter(6)
	nL0 = StzEngineGpuCounter(8)
	nF0 = StzEngineGpuCounter(3)
	StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nZ, 1)
	StzEngineGpuSync()
	chk("a sparse product is ONE dispatch (the counter says " + (StzEngineGpuCounter(0) - nD0) + ") in ONE queue submit (" + (StzEngineGpuCounter(6) - nS0) + ")", StzEngineGpuCounter(0) - nD0 = 1 and StzEngineGpuCounter(6) - nS0 = 1)
	chk("...no scratch: live buffers " + nL0 + " before and " + StzEngineGpuCounter(8) + " after, and nothing fell back", StzEngineGpuCounter(8) = nL0 and StzEngineGpuCounter(3) = nF0)

	? ""
	? "-- Scene 5: what it refuses --"
	chk("zero rows is BAD_ARG", StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, 0, nZ, 0) = S_BADARG)
	chk("zero entries is BAD_ARG", StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, 0, 0) = S_BADARG)
	chk("an unknown variant is BAD_ARG", StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nZ, 3) = S_BADARG)
	chk("k = 0 or a fractional k is BAD_ARG", StzEngineGpuOpSpmm(hR, hC, hV, hX, hY, nR, nZ, 0) = S_BADARG and StzEngineGpuOpSpmm(hR, hC, hV, hX, hY, nR, nZ, 1.5) = S_BADARG)
	chk("one buffer in two roles is BAD_ARG (WebGPU aliasing validation)", StzEngineGpuOpSpmv(hR, hC, hV, hX, hX, nR, nZ, 0) = S_BADARG and StzEngineGpuOpSpmv(hC, hC, hV, hX, hY, nR, nZ, 0) = S_BADARG)
	chk("an output too small, offsets too short or values too few are BAD_ARG", StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR + 1, nZ, 0) = S_BADARG and StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nZ + 1, 0) = S_BADARG)
	chk("more than 16,777,216 entries are refused by name (TOO_LARGE): the offsets and columns are f32", StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, 16777217, 0) = S_TOOLARGE)
	StzEngineGpuBufferFree(hY)
	chk("a freed output answers STALE", StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nZ, 0) = S_STALE)
	StzEngineGpuBufferFree(hR)
	StzEngineGpuBufferFree(hC)
	StzEngineGpuBufferFree(hV)
	StzEngineGpuBufferFree(hX)

	? ""
	? "-- Scene 6: the face, lists in and a list out --"
	aRp = [ 0, 2, 3, 6 ]
	aCo = [ 0, 2, 1, 0, 1, 2 ]
	aVa = [ 1, 2, 3, 4, 5, 6 ]
	chk("[[1 0 2] [0 3 0] [4 5 6]] times [1 2 3] = [7 6 32]", @@(oG.Spmv(aRp, aCo, aVa, [ 1, 2, 3 ])) = "[ 7, 6, 32 ]")
	chk("...with each kernel forced: [7 6 32] again", @@(oG.SpmvWith(aRp, aCo, aVa, [ 1, 2, 3 ], 1)) = "[ 7, 6, 32 ]" and @@(oG.SpmvWith(aRp, aCo, aVa, [ 1, 2, 3 ], 2)) = "[ 7, 6, 32 ]")
	chk("...times the matrix [[1 10] [2 20] [3 30]] = [[7 70] [6 60] [32 320]], flat", @@(oG.Spmm(aRp, aCo, aVa, [ 1, 10, 2, 20, 3, 30 ], 2)) = "[ 7, 70, 6, 60, 32, 320 ]")
	cErr = ""
	try
		oG.Spmv([ 1, 2, 3, 6 ], aCo, aVa, [ 1, 2, 3 ])
	catch
		cErr = cCatchError
	done
	chk("offsets that do not start at 0 are refused by name (" + left(cErr, 60) + ")", StzFindFirst("start at 0 and end at the number of entries", cErr) > 0)
	cErr = ""
	try
		oG.Spmv(aRp, aCo, [ 1, 2 ], [ 1, 2, 3 ])
	catch
		cErr = cCatchError
	done
	chk("columns and values of different lengths are refused by name (" + left(cErr, 60) + ")", StzFindFirst("give me a CSR matrix", cErr) > 0)

	? ""
	? "-- Scene 7: how fast, and where the two kernels cross --"
	$t0 = clock()
	nZ = 1000000
	nColsBig = 100000
	aCo = []
	aVa = []
	for i = 0 to nZ - 1
		aCo + ((i * 7919) % nColsBig)
		aVa + ((i % 9) - 4)
	next
	aXb = _Xvec(nColsBig, 1)
	hC = StzEngineGpuBufferNew(nZ * 4)
	hV = StzEngineGpuBufferNew(nZ * 4)
	hX = StzEngineGpuBufferNew(nColsBig * 4)
	StzEngineGpuBufferUploadList(hC, aCo)
	StzEngineGpuBufferUploadList(hV, aVa)
	StzEngineGpuBufferUploadList(hX, aXb)
	oG.Wake(400)
	StzEngineGpuSync()
	? "  1,000,000 entries, rows of L entries (best of 5, three products to a sync):"
	bAutoOk = 1
	for nL in [ 2, 4, 8, 16, 32, 64, 128, 256, 512 ]
		nR = floor(nZ / nL)
		aRp = []
		for i = 0 to nR
			aRp + (i * nL)
		next
		hR = StzEngineGpuBufferNew((nR + 1) * 4)
		hY = StzEngineGpuBufferNew(nR * 4)
		StzEngineGpuBufferUploadList(hR, aRp)
		aBest = [ 0, 1000000, 1000000 ]
		for nVar = 1 to 2
			StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nR * nL, nVar)
			for nRep = 1 to 5
				StzEngineGpuSync()
				nT = StzEngineWatchTimestampNs()
				for q = 1 to 3
					StzEngineGpuOpSpmv(hR, hC, hV, hX, hY, nR, nR * nL, nVar)
				next
				StzEngineGpuSync()
				nMs = (StzEngineWatchTimestampNs() - nT) / 1000000 / 3
				if nMs < aBest[nVar + 1]
					aBest[nVar + 1] = nMs
				ok
			next
		next
		nAuto = StzEngineGpuSpmvVariantFor(nR, nR * nL)
		nWin = 1
		if aBest[3] < aBest[2]
			nWin = 2
		ok
		nMin = aBest[2]
		if aBest[3] < nMin
			nMin = aBest[3]
		ok
		nChosen = aBest[nAuto + 1]
		cZone = ""
		if nL >= 16 and nL <= 32
			cZone = "  [the crossover zone: the two trade places from run to run, not asserted]"
		ok
		? "  L = " + nL + " (" + nR + " rows): scalar " + aBest[2] + " ms, vector " + aBest[3] + " ms; faster: " + nWin + ", auto picks " + nAuto + " (" + (nChosen / nMin) + " of the best)" + cZone
		if (nL <= 8 or nL >= 64) and nChosen > 1.5 * nMin
			bAutoOk = 0
		ok
		StzEngineGpuBufferFree(hR)
		StzEngineGpuBufferFree(hY)
	next
	chk("away from the crossover (rows of 8 or fewer, rows of 64 or more) auto's choice is within 1.5x of the faster kernel; at 16 to 32 the two trade places from run to run, which is why the threshold, 48, is a measurement printed above and not a line either side can fail", bAutoOk)
	StzEngineGpuBufferFree(hC)
	StzEngineGpuBufferFree(hV)
	StzEngineGpuBufferFree(hX)
	? "  (scene 7: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 8: the route -- the loop against the device through the face, measured, stored, followed --"
	$t0 = clock()
	aCal = oG.CalibrateSpmv()
	? "  adapter " + aCal[:adapter] + ", flat line at " + aCal[:flat] + " rows (" + aCal[:flatwhy] + ")"
	for aCell in aCal[:cells]
		? "  n = " + aCell[2] + " rows of 16: loop " + aCell[3] + " ms, face " + aCell[4] + " ms, ratio " + aCell[5]
	next
	if aCal[:confounded]
		# the control rung moved by more than 2x: another process held the machine, the store refused the line,
		# and a route that was never stored cannot be followed. A gate that could not run says so; it is not a pass
		$nSkip++
		? "  [SKIPPED] the route checks: the machine was too loaded for a stable measurement (the control rung moved more than 2x), so nothing was stored; run this guard again on a quiet machine"
	else
		chk("the control rung (the first, measured again at the end) stayed within 2x, so the line is stored", 1)
		bFollow = 1
		for aCell in aCal[:cells]
			bWin = (aCell[5] >= 1.3)
			if (StzEngineGpuCalibRouteShaped("spmv", aCell[2], 1) = 1) != bWin
				bFollow = 0
			ok
		next
		chk("the route sends a size to the device exactly where its measured ratio reached 1.3, at every rung", bFollow)
		aCsr = _Csr(_Fill(20000, 16), 20000)
		aXr = _Xvec(20000, 1)
		chk("SpmvRouted gives the same product whichever side it ran on (20,000 rows of 16, to the bit)", @@(oG.SpmvRouted(aCsr[1], aCsr[2], aCsr[3], aXr)) = @@(oG._SpmvCpu(aCsr[1], aCsr[2], aCsr[3], aXr)))
		chk("a tiny matrix stays on the loop and SpmvRouted answers [7 6 32]", @@(oG.SpmvRouted([ 0, 2, 3, 6 ], [ 0, 2, 1, 0, 1, 2 ], [ 1, 2, 3, 4, 5, 6 ], [ 1, 2, 3 ])) = "[ 7, 6, 32 ]" and StzEngineGpuCalibRouteShaped("spmv", 3, 1) = 0)
	ok
	? "  (scene 8: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 9: puzzle 24, a sparse matrix times a vector --"
$t0 = clock()
NLc = char(10)
oQ = StzKernelPuzzleQ("kp-24")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages, names Spmv and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("Spmv", oQ.Task("en")) > 0 and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "in b" + NLc + "in x" + NLc + "out y" + NLc
# the verdicts were worked out from the data before the first run. a is the ramp (k), b is (k * 3) % 7 (columns
# 0 3 6 2 5 1 4 0 ... in row 0) and x is (c * 7) % 13, so x of those columns is 0 8 3 1 9 7 2 0 and row 0 is
# 0*0 + 1*8 + 2*3 + 3*1 + 4*9 + 5*7 + 6*2 + 7*0 = 100:
#   swapped:       b * x[a] makes row 0 = 74 (3 * 7 + 6 * 1 + 2 * 8 + 5 * 2 + 1 * 9 + 4 * 3): element 1
#   stride of 7:   row 0 starts at 0 either way, so it is right; row 1 starts one entry early: element 2
#   nine entries:  row 0 takes a ninth, k = 8 (8 * x[3] = 64 more): element 1
#   no gather:     x[j] for the column: row 0 = 174 (1*7 + 2*1 + 3*8 + 4*2 + 5*9 + 6*3 + 7*10) where 100 is owed: element 1
aCases = [
	[ "body { @y = sum(j, 0, 8, @a[@i * 8 + j] * @x[@b[@i * 8 + j]]) }", "verified" ],
	[ "body { @y = sum(k, @i * 8, @i * 8 + 8, @a[k] * @x[@b[k]]) }", "verified" ],
	[ "body { @y = sum(j, 0, 8, @b[@i * 8 + j] * @x[@a[@i * 8 + j]]) }", "mismatch at element 1" ],
	[ "body { @y = sum(j, 0, 8, @a[@i * 7 + j] * @x[@b[@i * 7 + j]]) }", "mismatch at element 2" ],
	[ "body { @y = sum(j, 0, 9, @a[@i * 8 + j] * @x[@b[@i * 8 + j]]) }", "mismatch at element 1" ],
	[ "body { @y = sum(j, 0, 8, @a[@i * 8 + j] * @x[j]) }", "mismatch at element 1" ]
]
nAgree = 0
for aQ in aCases
	cSpec = cHead + aQ[1]
	if bDevice
		cV = oQ.Grade(cSpec)
	else
		cV = oQ.GradeOnCpu(cSpec)
	ok
	chk(aQ[1] + " -> " + aQ[2] + " (" + cV + ")", cV = aQ[2])
	if oQ.GradeOnCpu(cSpec) = aQ[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-24")
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

func _Fill nN, nV
	aR = []
	for q = 1 to nN
		aR + nV
	next
	return aR

# the dense vector (or flat matrix): whole numbers, negatives included
func _Xvec nN, nDummy
	aR = []
	for c = 0 to nN - 1
		aR + (((c * 5) % 11) - 5)
	next
	return aR

# a CSR matrix with the row lengths given: [ rowptr, cols, vals ], offsets 0-based
func _Csr aLens, nCols
	aRp = [ 0 ]
	aCo = []
	aVa = []
	nAt = 0
	nR = len(aLens)
	for r = 0 to nR - 1
		for e = 0 to aLens[r + 1] - 1
			aCo + ((r * 7919 + e * 131) % nCols)
			aVa + (((r + e * 3) % 9) - 4)
		next
		nAt += aLens[r + 1]
		aRp + nAt
	next
	return [ aRp, aCo, aVa ]

func _RefSpmv aRp, aCo, aVa, aX
	aOut = []
	nR = len(aRp) - 1
	for r = 1 to nR
		nAcc = 0
		for e = aRp[r] + 1 to aRp[r + 1]
			nAcc += aVa[e] * aX[aCo[e] + 1]
		next
		aOut + nAcc
	next
	return aOut

func _RefSpmm aRp, aCo, aVa, aX, nK
	aOut = []
	nR = len(aRp) - 1
	for r = 1 to nR
		for j = 0 to nK - 1
			nAcc = 0
			for e = aRp[r] + 1 to aRp[r + 1]
				nAcc += aVa[e] * aX[aCo[e] * nK + j + 1]
			next
			aOut + nAcc
		next
	next
	return aOut
