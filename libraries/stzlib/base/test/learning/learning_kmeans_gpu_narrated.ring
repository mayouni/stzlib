# GS7 -- Lloyd's k-means on the GPU, a silent seam inside cluster.kmeansRun
# (SOFTANZA_GPU_PLAN.md GS7).
#
# stzKMeans.Run() is unchanged. Inside the engine, when one iteration's work
# (n x k x d) reaches the gate and a device answers, the assignment runs as
# one thread per point with the argmin fused (no n x k matrix); a point whose
# two best centroids sit within f32's rounding is FLAGGED and the CPU decides
# it in f64 with its own rule; the CPU runs the update in f64 with its own
# code. So the labels and the centroids are the CPU's BITS -- k-means is
# deterministic by law here, and a device that answered differently on the
# same data would have broken it. Any refusal drops to the CPU loop, counted.
#
# What this guard asserts -- BOTH sides of the gate, mechanism first:
#   - under the gate: a run stays on the CPU (zero device iterations, nothing
#     counted as a refusal)
#   - the device's answer IS the CPU's: the same labels for every point, the
#     same iteration count, the same centroid bits
#   - the tie rule holds through the device: a point exactly between two
#     centroids goes to the lower-numbered one (flagged, decided by the CPU)
#   - over the gate, on the seed that makes f32 fail (every seed in one blob,
#     near-ties everywhere in the first iteration): served end to end, every
#     label the CPU's, the resolved-point counter says how many f32 could not
#     certify, and the call is faster at 20,000 x 256 into 64

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_ITERS = 0
C_FALLBACK = 1
C_RUNS = 2
C_RESOLVED = 3

pr()

decimals(6)

nGate0 = StzEngineKMeansGpuMinWork()
chk("the shipped gate is 64 million distance terms per iteration", nGate0 = 64000000)

# eight blobs in 16 dims, deterministic; the blob's mean sits at 6 * b on the
# dimensions of its parity, plus a small deterministic wobble
nD = 16
nK = 8

? ""
? "-- Scene 1: UNDER the gate, the CPU keeps the run (the negative side) --"
StzEngineKMeansGpuSetMinWork(1000000000000)
StzEngineKMeansGpuCountersReset()
aSmall = blobs(2000, nD, nK)
oC = new stzKMeans(aSmall)
oC.SetK(nK)
oC.Run(100)
chk("the CPU run answers (2000 points, 8 clusters)", len(oC.Centroids()) = nK and oC.Iterations() >= 1)
chk("zero device iterations, nothing counted as a refusal", StzEngineKMeansGpuCounter(C_ITERS) = 0 and StzEngineKMeansGpuCounter(C_FALLBACK) = 0)
aClCpu = oC.Clusters()
nBiggest = 0
for c = 1 to nK
	if len(aClCpu[c]) > nBiggest nBiggest = len(aClCpu[c]) ok
next
chk("...and the eight blobs are eight clusters of 250 (the data is what it says)", nBiggest = 250)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? ""
	? "  NO GPU ON THIS MACHINE -- the seam can never engage; the CPU contract above is the coverage"
	StzEngineKMeansGpuSetMinWork(1)
	StzEngineKMeansGpuCountersReset()
	oNo = new stzKMeans(aSmall)
	oNo.SetK(nK)
	oNo.Run(20)
	chk("without a device an eligible run falls back silently and COUNTS it",
		len(oNo.Centroids()) = nK and StzEngineKMeansGpuCounter(C_ITERS) = 0 and StzEngineKMeansGpuCounter(C_FALLBACK) >= 1)
else
	? ""
	? "-- Scene 2: the device's answer against the CPU's, point by point --"
	aFlat = []
	for i = 1 to 2000
		for t = 1 to nD
			aFlat + aSmall[i][t]
		next
	next
	aRc = StzEngineKMeansRun(aFlat, 2000, nD, nK, 100)
	StzEngineKMeansGpuCountersReset()
	aRg = StzEngineKMeansGpuRun(aFlat, 2000, nD, nK, 100)
	chk("both answer the same shape (iterations, seeded, inertia, 8 x 16 centroids, 2000 labels)", isList(aRg) and len(aRg) = len(aRc) and len(aRg) = 3 + nK * nD + 2000)
	? "  iterations: CPU " + aRc[1] + "   device " + aRg[1] + "   (device iterations counted: " + StzEngineKMeansGpuCounter(C_ITERS) + ")"
	chk("the same iteration count (convergence checked before the update, on both)", aRg[1] = aRc[1])
	chk("...and the device counted exactly that many", StzEngineKMeansGpuCounter(C_ITERS) = aRg[1])
	nDiffLabels = 0
	for i = 1 to 2000
		if aRg[3 + nK * nD + i] != aRc[3 + nK * nD + i] nDiffLabels++ ok
	next
	chk("EVERY label is the CPU's (0 of 2000 differ)", nDiffLabels = 0)
	nMaxRel = 0
	for j = 1 to nK * nD
		_c_ = aRc[3 + j]
		_g_ = aRg[3 + j]
		_r_ = fabs(_g_ - _c_) / (fabs(_c_) + 1)
		if _r_ > nMaxRel nMaxRel = _r_ ok
	next
	? "  centroids: max |device - cpu| = " + nMaxRel + "   points f32 could not certify, decided by the CPU: " + StzEngineKMeansGpuCounter(C_RESOLVED)
	chk("the centroids are the SAME BITS (the update is the CPU's own f64 code on the same labels)", nMaxRel = 0)
	? "  inertia: CPU " + aRc[3] + "   device " + aRg[3]
	chk("...and so is the inertia the engine now returns with the run", aRg[3] = aRc[3])

	? ""
	? "-- Scene 3: the tie rule -- a point exactly between two centroids goes LOWER --"
	# four points: two seeds at 0 and 10, a third at 5 (equidistant), a fourth near 10
	aTie = [ 0, 0, 10, 0, 5, 0, 9, 0 ]
	aRt = StzEngineKMeansGpuRun(aTie, 4, 2, 2, 1)
	chk("the device answers the tiny run (forced past the gate)", isList(aRt))
	? "  labels on the device: " + aRt[3 + 2 * 2 + 1] + " " + aRt[3 + 2 * 2 + 2] + " " + aRt[3 + 2 * 2 + 3] + " " + aRt[3 + 2 * 2 + 4]
	chk("the equidistant point took cluster 1, the lower-numbered (flagged by the device, decided by the CPU's strict <)", aRt[3 + 2 * 2 + 3] = 1)
	chk("...the point near 10 took cluster 2", aRt[3 + 2 * 2 + 4] = 2)

	? ""
	? "-- Scene 4: OVER the gate, served end to end and faster -- on data that makes Lloyd's WORK --"
	# the blobs in CONTIGUOUS blocks, so the first 8 distinct points -- the seed --
	# all sit in blob 0 and the centroids have to migrate out; interleaved blobs
	# seed one centroid per blob and converge in two iterations, which measures
	# the Ring lists and nothing else
	nBig = 20000
	nDb = 256
	nKb = 64
	aBig = blocks(nBig, nDb, nKb)
	aFlatBig = []
	for i = 1 to nBig
		for t = 1 to nDb
			aFlatBig + aBig[i][t]
		next
	next
	StzEngineKMeansGpuSetMinWork(1000000000000)
	nT0 = StzEngineWatchTimestampNs()
	aRc = StzEngineKMeansRun(aFlatBig, nBig, nDb, nKb, 100)
	nCpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
	StzEngineKMeansGpuSetMinWork(nGate0)
	StzEngineKMeansGpuCountersReset()
	nT0 = StzEngineWatchTimestampNs()
	aRg = StzEngineKMeansRun(aFlatBig, nBig, nDb, nKb, 100)
	nGpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
	? "  20000 x 256 into 64 (328 M terms per iteration), one engine call each: CPU " + nCpuMs + " ms (" + aRc[1] + " it, " + (nCpuMs / aRc[1]) + " ms/it)   device " + nGpuMs + " ms (" + aRg[1] + " it, " + (nGpuMs / aRg[1]) + " ms/it)   = " + (nCpuMs / nGpuMs) + "x"
	? "  device iterations " + StzEngineKMeansGpuCounter(C_ITERS) + "   runs " + StzEngineKMeansGpuCounter(C_RUNS) + "   fallbacks " + StzEngineKMeansGpuCounter(C_FALLBACK) + "   points decided by the CPU in f64: " + StzEngineKMeansGpuCounter(C_RESOLVED)
	chk("the seed forced real work (at least 5 iterations on the CPU)", aRc[1] >= 5)
	chk("f32 could not certify some points and said so (the resolved counter moved)", StzEngineKMeansGpuCounter(C_RESOLVED) > 0)
	chk("the run reached the gate and was served end to end: one run, zero refusals",
		StzEngineKMeansGpuCounter(C_RUNS) = 1 and StzEngineKMeansGpuCounter(C_FALLBACK) = 0)
	chk("...with every iteration counted", StzEngineKMeansGpuCounter(C_ITERS) = aRg[1])
	chk("the same iteration count as the CPU", aRg[1] = aRc[1])
	nDiffBig = 0
	for i = 1 to nBig
		if aRg[3 + nKb * nDb + i] != aRc[3 + nKb * nDb + i] nDiffBig++ ok
	next
	? "  labels differing: " + nDiffBig + " of " + nBig
	chk("EVERY label is the CPU's after the migration (0 of 20000 differ)", nDiffBig = 0)
	chk("the device run is at least 2x faster than the CPU's, same engine call, same list", nCpuMs / nGpuMs >= 2)
	# and the face, for the record: what a caller of stzKMeans.Run() sees
	StzEngineKMeansGpuSetMinWork(1000000000000)
	oCb = new stzKMeans(aBig)
	oCb.SetK(nKb)
	nT0 = StzEngineWatchTimestampNs()
	oCb.Run(100)
	nCpuFace = (StzEngineWatchTimestampNs() - nT0) / 1000000
	StzEngineKMeansGpuSetMinWork(nGate0)
	oGb = new stzKMeans(aBig)
	oGb.SetK(nKb)
	nT0 = StzEngineWatchTimestampNs()
	oGb.Run(100)
	nGpuFace = (StzEngineWatchTimestampNs() - nT0) / 1000000
	? "  through stzKMeans.Run() (the rows go to the bridge as they are since the flattening tax went): CPU " + nCpuFace + " ms   device " + nGpuFace + " ms   = " + (nCpuFace / nGpuFace) + "x"
	chk("the face is faster too", nGpuFace < nCpuFace)

	? ""
	? "-- Scene 5: the gate restored; a small run stays CPU --"
	StzEngineKMeansGpuCountersReset()
	oS = new stzKMeans(aSmall)
	oS.SetK(nK)
	oS.Run(50)
	chk("2000 x 16 x 8 = 256 k terms fall under the gate: zero device iterations", StzEngineKMeansGpuCounter(C_ITERS) = 0)
ok
StzEngineKMeansGpuSetMinWork(nGate0)

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

# nBlobs blobs in nDim dims, nN points, blob = (i - 1) % nBlobs; deterministic
func blobs nN, nDim, nBlobs
	_a_ = []
	for _i_ = 1 to nN
		_b_ = (_i_ - 1) % nBlobs
		_r_ = []
		for _k_ = 1 to nDim
			_r_ + (6 * _b_ * ((_k_ + _b_) % 2) + sin(_i_ * 0.731 + _k_ * 1.37) * 0.4)
		next
		_a_ + _r_
	next
	return _a_

# the same blobs in CONTIGUOUS blocks: blob = floor((i - 1) / (nN / nBlobs))
func blocks nN, nDim, nBlobs
	_a_ = []
	_per_ = floor(nN / nBlobs)
	for _i_ = 1 to nN
		_b_ = floor((_i_ - 1) / _per_)
		if _b_ >= nBlobs _b_ = nBlobs - 1 ok
		_r_ = []
		for _k_ = 1 to nDim
			_r_ + (6 * _b_ * ((_k_ + _b_) % 2) + sin(_i_ * 0.731 + _k_ * 1.37) * 0.4)
		next
		_a_ + _r_
	next
	return _a_
