# GK1 SHAPE PROBE -- measurement BEFORE the shape-keyed store is built
# (SOFTANZA_GPU_PLAN.md, GK1). The kill line, written there first: if the
# shaped verdicts disagree with the FLAT threshold by < 20% on every class
# on both adapters, the shape dimension is not worth its complexity here.
#
# The flat store says: pairdist goes to the GPU from n*d >= T (T is the
# persisted calibration, one number). This probe walks a grid of
# (dimension d) x (corpus n) through the REAL seam, both routes forced,
# warm-min of 3 queries -- the same method as stzGpu.Calibrate() -- on
# every adapter, and prints per cell: cpu ms, gpu ms, the ratio, what the
# flat rule DECIDES, and what the measurement SAYS. Disagreements are the
# finding. The wall clock is the right clock here: routing pays the submit.

load "../../stzBase.ring"

pr()

decimals(3)

# the flat rule as the seam sees it today
StzGpuLoadCalibrationDefault()
nFlat = StzEngineGpuCalibGet("pairdist")
if nFlat = 0
	nFlat = 4000000
ok
? "flat threshold on disk: dispatch pairdist from n*d >= " + nFlat

aDims = [16, 64, 256, 1024]
aCounts = [1000, 4000, 16000]
nBudget = 4200000     # max n*d per cell -- Ring builds the corpus as nested lists

oG = new stzGpu
nAd = 0
if NOT oG.IsAvailable()
	? "NO GPU -- nothing to probe"
else
	nAd = StzEngineGpuAdapterCount()
ok
aSeen = []
for a = 0 to nAd - 1
	cName = StzEngineGpuAdapterName(a)
	if find(aSeen, cName) > 0
		loop     # the same card enumerated under a second backend
	ok
	aSeen + cName
	if StzEngineGpuSelectAdapter(a) = 0
		? "  adapter " + a + " (" + cName + "): could not open -- skipped"
		loop
	ok
	? ""
	? "== ADAPTER " + a + ": " + cName + " =="
	? "     d      n       n*d     cpu ms     gpu ms    cpu/gpu   flat says   measured   agree"
	nDisagree = 0
	nCells = 0
	aCross = []
	nDims = len(aDims)
	nCounts = len(aCounts)
	for di = 1 to nDims
		d = aDims[di]
		nCrossD = 0
		for ni = 1 to nCounts
			n = aCounts[ni]
			if n * d > nBudget
				loop
			ok
			aR = oG._CalibRung(n, d)
			nCpu = aR[1]
			nGpu = aR[2]
			nRatio = 0
			if nGpu > 0
				nRatio = nCpu / nGpu
			ok
			bFlat = (n * d >= nFlat)
			bMeas = (nGpu * 1.3 <= nCpu)
			bAgree = (bFlat = bMeas)
			nCells++
			if NOT bAgree
				nDisagree++
			ok
			if bMeas and nCrossD = 0
				nCrossD = n * d
			ok
			? "  " + pad(d, 4) + "  " + pad(n, 5) + "  " + pad(n * d, 8) + "  " +
				pad(nCpu, 9) + "  " + pad(nGpu, 9) + "  " + pad(nRatio, 8) + "   " +
				pad(yn(bFlat), 9) + "   " + pad(yn(bMeas), 8) + "   " + yn(bAgree)
		next
		aCross + [ d, nCrossD ]
	next
	? ""
	? "  cells " + nCells + ", flat rule WRONG on " + nDisagree
	? "  first n*d where the GPU wins (>= 1.3x), per dimension:"
	nMin = 0
	nMax = 0
	nCross = len(aCross)
	for ci = 1 to nCross
		cW = "never on this ladder"
		if aCross[ci][2] > 0
			cW = "" + aCross[ci][2]
			if nMin = 0 or aCross[ci][2] < nMin
				nMin = aCross[ci][2]
			ok
			if aCross[ci][2] > nMax
				nMax = aCross[ci][2]
			ok
		ok
		? "     d = " + pad(aCross[ci][1], 4) + "  ->  " + cW
	next
	if nMin > 0 and nMax > 0
		? "  crossover spread across dimensions: " + (nMax / nMin) + "x  (kill line: < 1.2x on every adapter = flat store stays)"
	ok
next

# restore the on-disk truth in this process (the rungs forced the knob)
StzEngineGpuCalibSet("pairdist", nFlat)

pf()

func pad v, w
	_pc_ = "" + v
	while len(_pc_) < w
		_pc_ = " " + _pc_
	end
	return _pc_

func yn b
	if b
		return "GPU"
	ok
	return "cpu"
