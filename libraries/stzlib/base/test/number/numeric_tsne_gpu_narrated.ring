# GS6a -- the t-SNE epoch on the GPU, a silent seam inside tsne.run
# (SOFTANZA_GPU_PLAN.md GS6; the spike src/gs6_spike.zig measured it first).
#
# stzTSNE.Fit() is unchanged. Inside the engine, when the corpus reaches the
# gate and a device answers, the two n^2 passes of every epoch -- the q-sum
# and the gradient -- run on the GPU (P resident once as f32, the positions
# per epoch); momentum, gains, exaggeration, recentering and the density
# term stay on the CPU exactly as before. The stats DLL owns its own device
# (the neural precedent). Any refusal drops to the CPU block and is counted.
#
# What this guard asserts -- BOTH sides of the gate, mechanism first:
#   - under the gate: a fit runs entirely on the CPU (zero GPU epochs, the
#     device never asked)
#   - over the gate: EVERY epoch of a fit is served by the device (the
#     epoch counter equals the iteration count), one fit counted
#   - the two routes agree where a stochastic method can agree: each keeps
#     the blobs it was given together (nearest-neighbour blob purity), each
#     KL history descends, and the first-epoch KL -- the same P, the same
#     initial y, before any f32 divergence -- matches within the band
#   - the GPU fit is faster than the CPU fit by the spike's margin at
#     n = 1000 (>= 3x), both timed the same way
#   - without a device the seam refuses silently and counts (CI coverage)

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_EPOCHS = 0
C_FALLBACK = 1
C_FITS = 2

pr()

decimals(6)

# four blobs in 8 dims, 1000 points, deterministic
nN = 1000
nD = 8
nBlobs = 4
aData = []
for i = 1 to nN
	nB = (i - 1) % nBlobs
	aRow = []
	for k = 1 to nD
		aRow + (nB * 4 * ((k + nB) % 2) + sin(i * 0.731 + k * 1.37) * 0.5)
	next
	aData + aRow
next

nMin0 = StzEngineTsneGpuMinN()
chk("the shipped gate is 500 points (measured GO at 1,000; conservative)", nMin0 = 500)

? ""
? "-- Scene 1: UNDER the gate, the CPU keeps every epoch (the negative side) --"
StzEngineTsneGpuSetMinN(1000000)
StzEngineTsneGpuCountersReset()
oCpu = new stzTSNE(aData)
oCpu.SetIterations(150)
oCpu.SetSeed(7)
nT0 = StzEngineWatchTimestampNs()
oCpu.Fit()
nCpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
chk("the CPU fit answers (1000 points, 2 dims)", oCpu.IsFitted() and len(oCpu.Embedding()) = nN and len(oCpu.Embedding()[1]) = 2)
chk("zero epochs on the device", StzEngineTsneGpuCounter(C_EPOCHS) = 0)
chk("...and no fallback was counted (an ineligible fit is not a refusal)", StzEngineTsneGpuCounter(C_FALLBACK) = 0)
chk("the device was never asked (state untried)", StzEngineTsneGpuState() = 0)
aKlCpu = oCpu.KLHistory()
chk("the KL history descends on the CPU", aKlCpu[len(aKlCpu)] < aKlCpu[1])

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? ""
	? "  NO GPU ON THIS MACHINE -- the seam can never engage; the CPU contract above is the coverage"
	StzEngineTsneGpuSetMinN(1)
	StzEngineTsneGpuCountersReset()
	oNo = new stzTSNE(aData)
	oNo.SetIterations(20)
	oNo.Fit()
	chk("without a device an eligible fit falls back silently and COUNTS it",
		oNo.IsFitted() and StzEngineTsneGpuCounter(C_EPOCHS) = 0 and StzEngineTsneGpuCounter(C_FALLBACK) >= 1)
else
	? ""
	? "-- Scene 2: OVER the gate, every epoch is served by the device --"
	StzEngineTsneGpuSetMinN(1)
	StzEngineTsneGpuCountersReset()
	oGpu = new stzTSNE(aData)
	oGpu.SetIterations(150)
	oGpu.SetSeed(7)
	nT0 = StzEngineWatchTimestampNs()
	oGpu.Fit()
	nGpuMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
	chk("the GPU fit answers", oGpu.IsFitted() and len(oGpu.Embedding()) = nN)
	? "  epochs on the device: " + StzEngineTsneGpuCounter(C_EPOCHS) + "   fallbacks: " + StzEngineTsneGpuCounter(C_FALLBACK) + "   fits served: " + StzEngineTsneGpuCounter(C_FITS)
	chk("EVERY epoch was served by the device (150 of 150)", StzEngineTsneGpuCounter(C_EPOCHS) = 150)
	chk("one fit served, zero fallbacks", StzEngineTsneGpuCounter(C_FITS) = 1 and StzEngineTsneGpuCounter(C_FALLBACK) = 0)
	chk("the device is live", StzEngineTsneGpuState() = 1)

	? ""
	? "-- Scene 3: the two routes agree where a stochastic method can --"
	aKlGpu = oGpu.KLHistory()
	? "  first-epoch KL: CPU " + aKlCpu[1] + "   GPU " + aKlGpu[1] + "   final: CPU " + aKlCpu[150] + "   GPU " + aKlGpu[150]
	chk("the FIRST epoch's KL matches within 1e-5 relative (same P, same y0, before any f32 divergence)",
		fabs(aKlGpu[1] - aKlCpu[1]) / aKlCpu[1] < 0.00001)
	chk("the KL history descends on the GPU too", aKlGpu[150] < aKlGpu[1])
	nPurCpu = purity(oCpu.Embedding(), nBlobs, 5)
	nPurGpu = purity(oGpu.Embedding(), nBlobs, 5)
	? "  nearest-neighbour blob purity (5-NN): CPU " + nPurCpu + "   GPU " + nPurGpu
	chk("the CPU embedding keeps the blobs together (purity >= 0.95)", nPurCpu >= 0.95)
	chk("the GPU embedding keeps the blobs together too (purity >= 0.95)", nPurGpu >= 0.95)

	? ""
	? "-- Scene 4: the spike's margin, both fits timed the same way --"
	? "  CPU fit " + nCpuMs + " ms   GPU fit " + nGpuMs + " ms   = " + (nCpuMs / nGpuMs) + "x  (150 epochs at 1000 points, P build included in both)"
	chk("the GPU fit is at least 3x faster (the spike measured 12x per epoch at this size)", nCpuMs / nGpuMs >= 3)

	? ""
	? "-- Scene 5: the gate restored; a second fit under it stays CPU --"
	StzEngineTsneGpuSetMinN(nMin0)
	StzEngineTsneGpuCountersReset()
	aSmall = []
	for i = 1 to 120
		aSmall + aData[i]
	next
	oS = new stzTSNE(aSmall)
	oS.SetIterations(30)
	oS.Fit()
	chk("120 points fall under the 500 gate: zero device epochs", StzEngineTsneGpuCounter(C_EPOCHS) = 0)
ok
StzEngineTsneGpuSetMinN(nMin0)

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

# fraction of each point's k nearest embedded neighbours that share its blob
# (blob = (index - 1) % nBlobs); a 2-D scan, fine at 1000 points
func purity aEmb, nBlobs_, k_
	_n_ = len(aEmb)
	_hits_ = 0
	for _i_ = 1 to _n_
		_bi_ = (_i_ - 1) % nBlobs_
		_aBest_ = []
		for _j_ = 1 to _n_
			if _j_ = _i_ loop ok
			_dx_ = aEmb[_i_][1] - aEmb[_j_][1]
			_dy_ = aEmb[_i_][2] - aEmb[_j_][2]
			_d_ = _dx_ * _dx_ + _dy_ * _dy_
			# bounded insertion, k entries [dist, blob]
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
	return _hits_ / (_n_ * k_)
