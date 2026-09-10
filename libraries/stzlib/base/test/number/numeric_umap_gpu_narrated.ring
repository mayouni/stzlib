# GS6c -- UMAP's sparse form on the GPU: the exact k-NN and the epoch chain,
# silent seams inside umap.buildGraph and umap.run (SOFTANZA_GPU_PLAN.md GS6).
#
# stzUMAP.Fit() is unchanged. Inside the engine, when the corpus reaches the
# gates and a device answers: the neighbour table is built by an exact
# thread-per-row scan on the device (no n x n matrix, ever), and the epochs
# run as a gather-form chain -- one dispatch per epoch, batched into a few
# submits -- with the density term interleaved on the CPU when it is on.
# The CPU is the truth; any refusal restarts the fit there and is counted.
#
# What this guard asserts -- BOTH sides of each gate, mechanism first:
#   - under the gates: a fit runs entirely on the CPU (zero device epochs,
#     zero device neighbour tables, nothing counted as a refusal)
#   - the device's neighbour table is the CPU's exact one, row by row
#   - over the gates: EVERY epoch of a fit is served (the epoch counter
#     equals the epoch count), the table was built on the device, one fit
#   - the two routes agree where a stochastic layout can: each keeps its
#     blobs together (5-NN blob purity), and the device route is
#     deterministic under its seed (two fits, identical embeddings)
#   - the device route composes with density preservation (the term runs on
#     the CPU between device epochs; every epoch still served)
#   - the device fit is faster than the CPU fit at 4,000 points

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_EPOCHS = 0
C_FALLBACK = 1
C_FITS = 2
C_KNN = 3

pr()

decimals(4)

nD = 8
nN = 1000
aData = blobs(nN, nD)

nMin0 = StzEngineUmapGpuMinN()
nKnn0 = StzEngineUmapGpuKnnMinN()
chk("the shipped gates: epochs from 1,000 points (measured 2.3x there), k-NN from 1,024", nMin0 = 1000 and nKnn0 = 1024)

? ""
? "-- Scene 1: UNDER the gates, the CPU keeps everything (the negative side) --"
StzEngineUmapGpuSetMinN(1000000)
StzEngineUmapGpuSetKnnMinN(1000000)
StzEngineUmapGpuCountersReset()
oCpu = new stzUMAP(aData)
oCpu.SetEpochs(200)
oCpu.SetSeed(7)
nT0 = StzEngineWatchTimestampNs()
oCpu.Fit()
nCpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
chk("the CPU fit answers (1000 points, 2 dims)", oCpu.IsFitted() and len(oCpu.Embedding()) = nN and len(oCpu.Embedding()[1]) = 2)
chk("zero epochs and zero neighbour tables on the device", StzEngineUmapGpuCounter(C_EPOCHS) = 0 and StzEngineUmapGpuCounter(C_KNN) = 0)
chk("...and nothing counted as a refusal (ineligible is not refused)", StzEngineUmapGpuCounter(C_FALLBACK) = 0)
nPurCpu = purity(oCpu.Embedding(), 4, 5, 1)
? "  CPU 5-NN blob purity: " + nPurCpu
chk("the CPU embedding keeps the blobs together (purity >= 0.95)", nPurCpu >= 0.95)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? ""
	? "  NO GPU ON THIS MACHINE -- the seams can never engage; the CPU contract above is the coverage"
	StzEngineUmapGpuSetMinN(1)
	StzEngineUmapGpuSetKnnMinN(1)
	StzEngineUmapGpuCountersReset()
	oNo = new stzUMAP(aData)
	oNo.SetEpochs(20)
	oNo.Fit()
	chk("without a device an eligible fit falls back silently and COUNTS it",
		oNo.IsFitted() and StzEngineUmapGpuCounter(C_EPOCHS) = 0 and StzEngineUmapGpuCounter(C_FALLBACK) >= 1)
else
	? ""
	? "-- Scene 2: the device's neighbour table against the CPU's exact scan, row by row --"
	aX = []
	for i = 1 to nN
		for k = 1 to nD
			aX + aData[i][k]
		next
	next
	nK = 15
	aIc = StzEngineUmapKnn(aX, nN, nD, nK, 0)
	aIg = StzEngineUmapKnn(aX, nN, nD, nK, 1)
	chk("both builders answer n*k indices", len(aIc) = nN * nK and len(aIg) = nN * nK)
	nSame = 0
	nSameSet = 0
	for i = 1 to nN
		_ok_ = 1
		_set_ = 1
		for s = 1 to nK
			if aIc[(i - 1) * nK + s] != aIg[(i - 1) * nK + s] _ok_ = 0 ok
		next
		if _ok_ = 1
			nSame++
			nSameSet++
		else
			# the same SET in another order (near-ties in f32) still counts as the set
			for s = 1 to nK
				_v_ = aIg[(i - 1) * nK + s]
				_f_ = 0
				for t = 1 to nK
					if aIc[(i - 1) * nK + t] = _v_ _f_ = 1 ok
				next
				if _f_ = 0 _set_ = 0 ok
			next
			if _set_ = 1 nSameSet++ ok
		ok
	next
	? "  rows identical (order included): " + nSame + " of " + nN + "   rows with the same neighbour SET: " + nSameSet
	chk("at least 99% of rows are identical, order included", nSame >= 0.99 * nN)
	chk("every row has the same neighbour set", nSameSet = nN)
	chk("...the device table was counted once and nothing refused", StzEngineUmapGpuCounter(C_KNN) = 1 and StzEngineUmapGpuCounter(C_FALLBACK) = 0)

	? ""
	? "-- Scene 3: OVER the gates, every epoch is served and the table built there --"
	StzEngineUmapGpuSetMinN(1)
	StzEngineUmapGpuSetKnnMinN(1)
	StzEngineUmapGpuCountersReset()
	oGpu = new stzUMAP(aData)
	oGpu.SetEpochs(200)
	oGpu.SetSeed(7)
	nT0 = StzEngineWatchTimestampNs()
	oGpu.Fit()
	nGpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
	chk("the GPU fit answers", oGpu.IsFitted() and len(oGpu.Embedding()) = nN)
	? "  epochs on the device: " + StzEngineUmapGpuCounter(C_EPOCHS) + "   tables: " + StzEngineUmapGpuCounter(C_KNN) + "   fits: " + StzEngineUmapGpuCounter(C_FITS) + "   fallbacks: " + StzEngineUmapGpuCounter(C_FALLBACK)
	chk("EVERY epoch was served by the device (200 of 200)", StzEngineUmapGpuCounter(C_EPOCHS) = 200)
	chk("the neighbour table was built on the device, one fit served, zero fallbacks",
		StzEngineUmapGpuCounter(C_KNN) = 1 and StzEngineUmapGpuCounter(C_FITS) = 1 and StzEngineUmapGpuCounter(C_FALLBACK) = 0)
	nPurGpu = purity(oGpu.Embedding(), 4, 5, 1)
	? "  5-NN blob purity: CPU " + nPurCpu + "   GPU " + nPurGpu
	chk("the GPU embedding keeps the blobs together too (purity >= 0.95)", nPurGpu >= 0.95)
	bFinite = TRUE
	for i = 1 to nN
		if fabs(oGpu.Embedding()[i][1]) > 1000000 or fabs(oGpu.Embedding()[i][2]) > 1000000 bFinite = FALSE ok
	next
	chk("every coordinate stays finite (the clip holds on the device)", bFinite)
	? "  fit at 1000 points: CPU " + nCpuMs + " ms   GPU " + nGpuMs + " ms"

	? ""
	? "-- Scene 3b: the device route is deterministic under its seed --"
	oAgain = new stzUMAP(aData)
	oAgain.SetEpochs(200)
	oAgain.SetSeed(7)
	oAgain.Fit()
	bSame = TRUE
	for i = 1 to nN
		if oAgain.Embedding()[i][1] != oGpu.Embedding()[i][1] or oAgain.Embedding()[i][2] != oGpu.Embedding()[i][2] bSame = FALSE ok
	next
	chk("the same seed gives the SAME embedding on the device (bit for bit)", bSame)
	oOther = new stzUMAP(aData)
	oOther.SetEpochs(200)
	oOther.SetSeed(8)
	oOther.Fit()
	chk("...and another seed gives another (the negative sibling)", oOther.Embedding()[1][1] != oGpu.Embedding()[1][1])

	? ""
	? "-- Scene 4: density preservation composes with the device route --"
	StzEngineUmapGpuCountersReset()
	oDens = new stzUMAP(aData)
	oDens.SetEpochs(200)
	oDens.SetSeed(7)
	oDens.PreserveDensity()
	oDens.Fit()
	nCorr = oDens.DensityCorrelation()
	? "  epochs on the device with the density term on: " + StzEngineUmapGpuCounter(C_EPOCHS) + "   density correlation: " + nCorr
	chk("every epoch still served (the term runs on the CPU between device epochs)", StzEngineUmapGpuCounter(C_EPOCHS) = 200 and StzEngineUmapGpuCounter(C_FALLBACK) = 0)
	chk("the density correlation is a number, and the term achieved something (> 0)", isNumber(nCorr) and nCorr > 0)
	chk("...and the local radii are still a data product (1000 of them)", len(oDens.LocalRadii()) = nN)

	? ""
	? "-- Scene 5: the margin at 4,000 points, both fits timed the same way --"
	nBig = 4000
	aBig = blobs(nBig, nD)
	StzEngineUmapGpuSetMinN(1000000)
	StzEngineUmapGpuSetKnnMinN(1000000)
	oC4 = new stzUMAP(aBig)
	oC4.SetEpochs(200)
	oC4.SetSeed(7)
	nT0 = StzEngineWatchTimestampNs()
	oC4.Fit()
	nC4 = (StzEngineWatchTimestampNs() - nT0) / 1000000
	StzEngineUmapGpuSetMinN(1)
	StzEngineUmapGpuSetKnnMinN(1)
	StzEngineUmapGpuCountersReset()
	oG4 = new stzUMAP(aBig)
	oG4.SetEpochs(200)
	oG4.SetSeed(7)
	nT0 = StzEngineWatchTimestampNs()
	oG4.Fit()
	nG4 = (StzEngineWatchTimestampNs() - nT0) / 1000000
	? "  4000 points x 200 epochs: CPU " + nC4 + " ms   GPU " + nG4 + " ms   = " + (nC4 / nG4) + "x   (device epochs " + StzEngineUmapGpuCounter(C_EPOCHS) + ", tables " + StzEngineUmapGpuCounter(C_KNN) + ")"
	chk("the device fit is at least 2x faster at 4,000 points, graph build included", nC4 / nG4 >= 2)
	chk("...with every epoch served", StzEngineUmapGpuCounter(C_EPOCHS) = 200)
	nP4c = purity(oC4.Embedding(), 4, 5, 10)
	nP4g = purity(oG4.Embedding(), 4, 5, 10)
	? "  5-NN blob purity (every 10th point as a query): CPU " + nP4c + "   GPU " + nP4g
	chk("both 4,000-point embeddings keep the blobs together (purity >= 0.95)", nP4c >= 0.95 and nP4g >= 0.95)

	? ""
	? "-- Scene 6: the gates restored; a small fit stays CPU --"
	StzEngineUmapGpuSetMinN(nMin0)
	StzEngineUmapGpuSetKnnMinN(nKnn0)
	StzEngineUmapGpuCountersReset()
	aSmall = []
	for i = 1 to 300
		aSmall + aData[i]
	next
	oS = new stzUMAP(aSmall)
	oS.SetEpochs(30)
	oS.Fit()
	chk("300 points fall under both gates: zero device epochs, zero device tables", StzEngineUmapGpuCounter(C_EPOCHS) = 0 and StzEngineUmapGpuCounter(C_KNN) = 0)
ok
StzEngineUmapGpuSetMinN(nMin0)
StzEngineUmapGpuSetKnnMinN(nKnn0)

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

# fraction of each query point's k nearest embedded neighbours that share its
# blob (blob = (index - 1) % nBlobs); every nStride-th point is a query, so the
# 2-D scan stays affordable at 4,000 points
func purity aEmb, nBlobs_, k_, nStride_
	_n_ = len(aEmb)
	_hits_ = 0
	_q_ = 0
	for _i_ = 1 to _n_ step nStride_
		_q_++
		_bi_ = (_i_ - 1) % nBlobs_
		_aBest_ = []
		_xi_ = aEmb[_i_][1]
		_yi_ = aEmb[_i_][2]
		for _j_ = 1 to _n_
			if _j_ = _i_ loop ok
			_dx_ = _xi_ - aEmb[_j_][1]
			_dy_ = _yi_ - aEmb[_j_][2]
			_d_ = _dx_ * _dx_ + _dy_ * _dy_
			_pos_ = len(_aBest_) + 1
			while _pos_ > 1 and _aBest_[_pos_ - 1][1] > _d_
				_pos_--
			end
			if _pos_ <= k_
				ring_insert(_aBest_, _pos_, [_d_, (_j_ - 1) % nBlobs_])
				if len(_aBest_) > k_
					del(_aBest_, len(_aBest_))
				ok
			ok
		next
		for _m_ = 1 to len(_aBest_)
			if _aBest_[_m_][2] = _bi_ _hits_++ ok
		next
	next
	return _hits_ / (_q_ * k_)

# four blobs in 8 dims, deterministic
func blobs nN, nD
	_a_ = []
	for _i_ = 1 to nN
		_b_ = (_i_ - 1) % 4
		_r_ = []
		for _k_ = 1 to nD
			_r_ + (_b_ * 4 * ((_k_ + _b_) % 2) + sin(_i_ * 0.731 + _k_ * 1.37) * 0.5)
		next
		_a_ + _r_
	next
	return _a_
