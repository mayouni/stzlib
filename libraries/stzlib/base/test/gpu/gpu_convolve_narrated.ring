# GS1 -- FFT CONVOLUTION ON THE GPU, the GPU plane's op (SOFTANZA_GPU_PLAN.md
# GS1; the sound plan's SN0 criterion #3, signed and never wired).
#
# The linear convolution of two real signals as ONE batched pass on the
# device: pack, forward transforms of both operands (Stockham radix-2,
# twiddles from a TABLE computed in f64), a pointwise product, the inverse
# chain, the scaled real part. Verified here against fft.zig's f64
# convolveReal -- the CPU capability as shipped, an INDEPENDENT reference --
# and timed against it with the device woken first.
#
# What this guard asserts, mechanism first, negative siblings beside:
#   - small integer signals convolve to the exact integers (within f32)
#   - a 1 s signal against a 1 s impulse response matches fft.zig within
#     the measured band on BOTH adapters -- the iGPU included, which is the
#     prerequisite SN0 named (per-butterfly cos/sin there read 2.75e-5)
#   - the chain is ONE batched submit of exactly 4 + 3*log2(N) dispatches
#     (the counters are the witness), the twiddle table is built once and
#     reused (live buffers do not grow on the second run), and a wrong size
#     is refused before any dispatch
#   - the RESIDENT chain at 1 s (signals already on the device) is timed
#     against SN0's numbers, device woken; the Ring-list doorway is timed
#     against fft.zig through the same lists and named for what it is
#     (list marshalling on both sides); a 60 s render is timed on the
#     device without a Ring list (informational, beside SN0's 62 ms)
#   - without a device the op refuses (a counted fallback) and the face
#     raises by name

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_DISP = 0
C_FALLBACK = 3
C_SUBMIT = 6
C_LIVE = 8

pr()

decimals(9)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? "  NO GPU ON THIS MACHINE -- asserting the refusal contract only"
	StzEngineGpuCountersReset()
	chk("the op refuses without a device", StzEngineGpuOpConvolveReal(1, 4, 1, 4, 1) != 0)
	chk("...and counts the fallback", StzEngineGpuCounter(C_FALLBACK) >= 1)
	oG0 = new stzGpu
	bRaised = FALSE
	try
		oG0.ConvolveReal([1, 2, 3], [1, 1])
	catch
		bRaised = StzFindFirst("no GPU device", cCatchError) > 0
	done
	chk("the face raises by name", bRaised)
else
	oG = new stzGpu
	? "  device: " + oG.DeviceName()

	? ""
	? "-- Scene 1: small integers, exact --"
	aC = oG.ConvolveReal([1, 2, 3], [1, 1])
	? "  [1,2,3] * [1,1] = " + aC[1] + ", " + aC[2] + ", " + aC[3] + ", " + aC[4]
	chk("four samples out (3 + 2 - 1)", len(aC) = 4)
	chk("[1,3,5,3] within 1e-5 (f32 through an 8-point transform)",
		near(aC[1], 1) and near(aC[2], 3) and near(aC[3], 5) and near(aC[4], 3))
	aD = oG.ConvolveReal([2, 0, 0, 0, 0], [1, 2, 3, 4])
	chk("a scaled impulse reproduces the other operand: 2*[1,2,3,4] then zeros",
		near(aD[1], 2) and near(aD[2], 4) and near(aD[3], 6) and near(aD[4], 8) and near(aD[5], 0) and near(aD[8], 0))
	aE = oG.ConvolveReal([1, 2, 3], [4, 5, 6])
	aR = StzEngineConvolveReal([1, 2, 3], [4, 5, 6])
	chk("...and agrees with fft.zig's f64 answer on a non-power-of-two case", maxreldiff(aE, aR) < 0.00001)

	? ""
	? "-- Scene 2: one second against a one-second impulse response, vs fft.zig --"
	nSr = 48000
	aSig = []
	aIr = []
	for i = 1 to nSr
		aSig + (sin(i * 0.0137) * 0.6 + sin(i * 0.211) * 0.3 + ((i * 7919) % 101) / 101.0 - 0.5)
		aIr + (((i * 31) % 17 - 8) / 8.0) * (1 - (i - 1) / nSr) * (1 - (i - 1) / nSr)
	next
	nM = StzEngineGpuConvolveSize(nSr, nSr)
	chk("the transform size for 2 x 48000 is 131072", nM = 131072)
	aRef = StzEngineConvolveReal(aSig, aIr)
	StzEngineGpuCountersReset()
	nLive0 = StzEngineGpuCounter(C_LIVE)
	aGpu = oG.ConvolveReal(aSig, aIr)
	chk("95999 samples out", len(aGpu) = 2 * nSr - 1 and len(aRef) = len(aGpu))
	nErr = maxreldiff(aGpu, aRef)
	? "  max relative error vs fft.zig f64 (relative to the output's peak): " + nErr
	chk("within 1e-5 of the f64 reference (SN0 measured 1.47e-6 on this card)", nErr < 0.00001)
	nDisp = StzEngineGpuCounter(C_DISP)
	? "  dispatches " + nDisp + "   submits " + StzEngineGpuCounter(C_SUBMIT)
	chk("exactly 4 + 3*log2(N) = 55 dispatches for N = 131072 (pack x2, 17 x2 forward, product, 17 inverse, unpack)", nDisp = 55)
	chk("ONE submit for the whole chain (+1 for the readback copy)", StzEngineGpuCounter(C_SUBMIT) <= 2)
	# the twiddle CACHE: one table, replaced on a size change, never accumulated
	nLive1 = StzEngineGpuCounter(C_LIVE)
	aGpu2 = oG.ConvolveReal(aSig, aIr)
	chk("a second run at the same size builds no second table (live buffers unchanged)", StzEngineGpuCounter(C_LIVE) = nLive1)
	chk("...and answers identically (the chain is deterministic)", maxreldiff(aGpu, aGpu2) = 0)
	oG.ConvolveReal([1, 2, 3], [1, 1])
	chk("a run at another size REPLACES the table rather than adding one (live buffers unchanged)", StzEngineGpuCounter(C_LIVE) = nLive1)

	? ""
	? "-- Scene 3: a wrong size is refused BEFORE any dispatch --"
	hA = StzEngineGpuBufferNew(16)
	hB = StzEngineGpuBufferNew(16)
	hS = StzEngineGpuBufferNew(8)     # room for 2 floats, the answer needs 7
	nD0 = StzEngineGpuCounter(C_DISP)
	chk("an output buffer too small for na+nb-1 is refused", StzEngineGpuOpConvolveReal(hA, 4, hB, 4, hS) != 0)
	chk("...with no dispatch", StzEngineGpuCounter(C_DISP) = nD0)
	StzEngineGpuBufferFree(hA)  StzEngineGpuBufferFree(hB)  StzEngineGpuBufferFree(hS)

	? ""
	? "-- Scene 4: the SN0 margin at 1 s, both timed the same way, device woken --"
	oG.Wake(400)
	nCpu = 999999
	for r = 1 to 3
		t0 = StzEngineWatchTimestampNs()
		StzEngineConvolveReal(aSig, aIr)
		ms = (StzEngineWatchTimestampNs() - t0) / 1000000
		if ms < nCpu nCpu = ms ok
	next
	nGpu = 999999
	for r = 1 to 3
		t0 = StzEngineWatchTimestampNs()
		oG.ConvolveReal(aSig, aIr)
		ms = (StzEngineWatchTimestampNs() - t0) / 1000000
		if ms < nGpu nGpu = ms ok
	next
	# the RESIDENT form -- the seam's real shape: signals already on the
	# device, the chain alone timed (upload once, outside the clock)
	hRa = StzEngineGpuBufferNew(nSr * 4)
	hRb = StzEngineGpuBufferNew(nSr * 4)
	hRo = StzEngineGpuBufferNew((2 * nSr - 1) * 4)
	StzEngineGpuBufferUploadList(hRa, aSig)
	StzEngineGpuBufferUploadList(hRb, aIr)
	StzEngineGpuOpConvolveReal(hRa, nSr, hRb, nSr, hRo)
	StzEngineGpuSync()
	nChain = 999999
	for r = 1 to 5
		t0 = StzEngineWatchTimestampNs()
		StzEngineGpuOpConvolveReal(hRa, nSr, hRb, nSr, hRo)
		StzEngineGpuSync()
		ms = (StzEngineWatchTimestampNs() - t0) / 1000000
		if ms < nChain nChain = ms ok
	next
	StzEngineGpuBufferFree(hRa)  StzEngineGpuBufferFree(hRb)  StzEngineGpuBufferFree(hRo)
	? "  1 s through Ring LISTS on both sides: fft.zig " + nCpu + " ms vs GPU doorway " + nGpu + " ms (" + (nCpu / nGpu) + "x) -- list marshalling dominates both"
	? "  1 s RESIDENT: the chain + sync alone " + nChain + " ms   (SN0: fft.zig's own compute 24-25 ms, the GPU 1.74 ms with transfer)"
	chk("the doorway is no slower than fft.zig through the same lists", nCpu / nGpu >= 1)
	chk("the RESIDENT chain at 1 s is under 10 ms -- the seam's shape (SN0 measured 1.74 ms with transfer)", nChain < 10)

	? ""
	? "-- Scene 5: sixty seconds on the device, no Ring list (informational) --"
	nBig = 2880000
	hX = StzEngineGpuBufferNew(nBig * 4)
	hH = StzEngineGpuBufferNew(nSr * 4)
	hY = StzEngineGpuBufferNew((nBig + nSr - 1) * 4)
	chk("2.88 M + 48 k samples staged on the device", StzEngineGpuBufferFillLcg(hX, nBig, 7) = 0 and StzEngineGpuBufferFillLcg(hH, nSr, 11) = 0)
	oG.Wake(400)
	StzEngineGpuOpConvolveReal(hX, nBig, hH, nSr, hY)
	StzEngineGpuSync()
	nBest = 999999
	for r = 1 to 3
		t0 = StzEngineWatchTimestampNs()
		StzEngineGpuOpConvolveReal(hX, nBig, hH, nSr, hY)
		StzEngineGpuSync()
		ms = (StzEngineWatchTimestampNs() - t0) / 1000000
		if ms < nBest nBest = ms ok
	next
	? "  60 s of audio, N = " + StzEngineGpuConvolveSize(nBig, nSr) + ": chain + sync " + nBest + " ms on the device (SN0 measured 62 ms incl. transfer; fft.zig 1,390-1,464 ms)"
	chk("the 60 s chain ran (a real number, under a second)", nBest > 0 and nBest < 1000)
	StzEngineGpuBufferFree(hX)  StzEngineGpuBufferFree(hH)  StzEngineGpuBufferFree(hY)

	? ""
	? "-- Scene 6: the iGPU, where per-butterfly cos/sin read 2.75e-5 -- the table fixes it --"
	nAd = StzEngineGpuAdapterCount()
	nIntel = -1
	for a = 0 to nAd - 1
		if StzFindFirst("Intel", StzEngineGpuAdapterName(a)) > 0 and nIntel < 0
			nIntel = a
		ok
	next
	if nIntel < 0
		? "  no second adapter on this machine -- scene skipped, and says so"
	else
		if StzEngineGpuSelectAdapter(nIntel) = 1
			? "  device: " + StzEngineGpuAdapterName(nIntel)
			oG2 = new stzGpu
			aGpuI = oG2.ConvolveReal(aSig, aIr)
			nErrI = maxreldiff(aGpuI, aRef)
			? "  max relative error vs fft.zig f64 on the iGPU: " + nErrI
			chk("the iGPU is inside 1e-5 too (SN0 read 2.75e-5 with cos/sin per butterfly; the table is the fix)", nErrI < 0.00001)
		else
			? "  the second adapter could not be opened -- scene skipped, and says so"
		ok
	ok
ok

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

func near a, b
	_d_ = a - b
	if _d_ < 0 _d_ = -_d_ ok
	return _d_ < 0.00001

# max |got - want| relative to the reference's peak magnitude
func maxreldiff aGot, aWant
	_n_ = len(aWant)
	_peak_ = 0
	for _i_ = 1 to _n_
		_v_ = aWant[_i_]
		if _v_ < 0 _v_ = -_v_ ok
		if _v_ > _peak_ _peak_ = _v_ ok
	next
	if _peak_ = 0 _peak_ = 1 ok
	_m_ = 0
	for _i_ = 1 to _n_
		_d_ = aGot[_i_] - aWant[_i_]
		if _d_ < 0 _d_ = -_d_ ok
		if _d_ > _m_ _m_ = _d_ ok
	next
	return _m_ / _peak_
