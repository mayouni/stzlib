# GS6f -- trustworthiness, the embedding witness (Venna & Kaski 2006, as
# scikit-learn computes it, as cuML's UMAP paper reports it beside every
# timing) -- exact on the CPU, the same number on the device past its gate.
#
#   T(k) = 1 - 2 / (n k (2n - 3k - 1)) * sum_i sum_{j in U_i^k} (r(i, j) - k)
#
# A neighbour a point gained in the embedding that was not among its k
# nearest in the input is charged by how far down the input ordering it sat;
# 1.0 means the layout invented nothing. It needs only the data and the
# embedding -- no labels, no blob generator -- and it is the number the field
# compares on. stzUMAP and stzTSNE answer it as Trustworthiness().
#
# What this guard asserts, mechanism first, negative sibling beside each:
#   - a hand-computed case answers EXACTLY 0.4 on both routes; an embedding
#     that keeps every neighbour answers exactly 1
#   - shapes outside the definition answer 0, not a number
#   - the device's witness is the CPU's on 2,000 real points within ONE RANK
#     UNIT (2 / (n k (2n - 3k - 1)), 5e-8 there): where f64 separates two input
#     distances that f32 cannot, the tie rule decides them differently, and
#     that is the whole of the gap -- measured, and bounded here at four units
#   - under the gate the CPU answers and the device counter stays still; past
#     it the device answers and the counter moves; forced, the device answers
#     under the gate
#   - the faces answer it for a fitted UMAP and a fitted t-SNE, and both fits
#     keep their neighbours (T(5) >= 0.97 on four blobs, 200 epochs)
#   - at 4,000 points the device witness is faster than the CPU's

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_TRUST = 5

pr()

decimals(5)

? "-- Scene 1: the definition, by hand --"
nHand = StzEngineEmbeddingTrustworthiness([0, 1, 2, 3, 10], 5, 1, [0, 1, 2, 3, 0.5], 1, 1, 1)
? "  five points on a line, the last folded back beside the first: T(1) = " + nHand
chk("the hand-computed case answers EXACTLY 0.4 on the CPU (three invented neighbours, rank 4 each, over 15)", nHand = 0.4)
chk("an embedding that keeps every neighbour answers exactly 1", StzEngineEmbeddingTrustworthiness([0, 0, 1, 0, 2, 0, 3, 0, 10, 0, 11, 0], 6, 2, [0, 1, 2, 3, 10, 11], 1, 2, 1) = 1)
chk("k >= n is outside the definition and answers 0", StzEngineEmbeddingTrustworthiness([0, 1, 2, 3], 4, 1, [0, 1, 2, 3], 1, 4, 1) = 0)
chk("2n < 3k + 1 (the normaliser's domain) answers 0", StzEngineEmbeddingTrustworthiness([0, 1, 2, 3], 4, 1, [0, 1, 2, 3], 1, 3, 1) = 0)
chk("a row count that does not match its list answers 0", StzEngineEmbeddingTrustworthiness([0, 1, 2], 4, 1, [0, 1, 2, 3], 1, 1, 1) = 0)

# four blobs in 8 dims
nD = 8
nN = 2000
aData = blobs(nN, nD)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? ""
	? "  NO GPU ON THIS MACHINE -- the CPU witness above is the coverage; the device route refuses silently"
	chk("forcing the device without one falls back to the CPU's number", StzEngineEmbeddingTrustworthiness([0, 1, 2, 3, 10], 5, 1, [0, 1, 2, 3, 0.5], 1, 1, 2) = 0.4)
else
	? ""
	? "-- Scene 2: the device's witness is the CPU's, within one rank unit --"
	chk("the hand case answers 0.4 on the device too", StzEngineEmbeddingTrustworthiness([0, 1, 2, 3, 10], 5, 1, [0, 1, 2, 3, 0.5], 1, 1, 2) = 0.4)
	oU = new stzUMAP(aData)
	oU.SetEpochs(200)
	oU.SetSeed(7)
	oU.Fit()
	aE = oU.Embedding()
	nTc = StzEngineEmbeddingTrustworthiness(aData, nN, nD, aE, 2, 5, 1)
	nTg = StzEngineEmbeddingTrustworthiness(aData, nN, nD, aE, 2, 5, 2)
	? "  T(5) of a UMAP fit on 2,000 points: CPU " + nTc + "   device " + nTg
	? "  gap " + (nTc - nTg) + "   one rank unit here = " + (2 / (nN * 5 * (2 * nN - 16)))
	chk("the two routes agree within four rank units (f32 ties that f64 separates; measured at most one)", fabs(nTc - nTg) < 4 * 2 / (nN * 5 * (2 * nN - 16)))
	nT15c = StzEngineEmbeddingTrustworthiness(aData, nN, nD, aE, 2, 15, 1)
	nT15g = StzEngineEmbeddingTrustworthiness(aData, nN, nD, aE, 2, 15, 2)
	chk("...at k = 15 as well", fabs(nT15c - nT15g) < 4 * 2 / (nN * 15 * (2 * nN - 46)))
	chk("...and the witness moves with k (a different statistic, not the same number twice)", nT15c != nTc)

	? ""
	? "-- Scene 3: the gate, both sides --"
	nGate0 = StzEngineUmapGpuTrustMinN()
	chk("the shipped gate is 1,024 points (the CPU and the device cost the same at 1,000)", nGate0 = 1024)
	StzEngineUmapGpuSetTrustMinN(1000000)
	StzEngineUmapGpuCountersReset()
	StzEngineEmbeddingTrustworthiness(aData, nN, nD, aE, 2, 5, 0)
	chk("under the gate the engine's choice is the CPU: the device counter stays still", StzEngineUmapGpuCounter(C_TRUST) = 0)
	StzEngineUmapGpuSetTrustMinN(1)
	StzEngineUmapGpuCountersReset()
	nTa = StzEngineEmbeddingTrustworthiness(aData, nN, nD, aE, 2, 5, 0)
	chk("past the gate the device answers: the counter moved once", StzEngineUmapGpuCounter(C_TRUST) = 1)
	chk("...with the same number (the device's, to the bit)", nTa = nTg)
	StzEngineUmapGpuSetTrustMinN(nGate0)

	? ""
	? "-- Scene 4: the faces, and the fits they judge --"
	nTu = oU.Trustworthiness()
	? "  stzUMAP.Trustworthiness() = " + nTu + "   at k = 15: " + oU.TrustworthinessAt(15)
	chk("stzUMAP answers the witness on the data it fitted (the device route past the gate, to the bit)", nTu = nTg)
	chk("the UMAP fit keeps its neighbours (T(5) >= 0.97 on four blobs at 200 epochs)", nTu >= 0.97)
	aSmall = []
	for i = 1 to 800
		aSmall + aData[i]
	next
	oT = new stzTSNE(aSmall)
	oT.SetIterations(150)
	oT.SetSeed(7)
	oT.Fit()
	nTt = oT.Trustworthiness()
	? "  stzTSNE.Trustworthiness() = " + nTt
	chk("stzTSNE answers it too, and the fit keeps its neighbours (T(5) >= 0.97)", nTt >= 0.97)

	? ""
	? "-- Scene 5: the device witness is faster at 4,000 points --"
	nBig = 4000
	aBig = blobs(nBig, nD)
	oB = new stzUMAP(aBig)
	oB.SetEpochs(200)
	oB.SetSeed(7)
	oB.Fit()
	aEb = oB.Embedding()
	StzEngineEmbeddingTrustworthiness(aBig, nBig, nD, aEb, 2, 5, 2)
	nT0 = StzEngineWatchTimestampNs()
	nTbc = StzEngineEmbeddingTrustworthiness(aBig, nBig, nD, aEb, 2, 5, 1)
	nMsC = (StzEngineWatchTimestampNs() - nT0) / 1000000
	nT0 = StzEngineWatchTimestampNs()
	nTbg = StzEngineEmbeddingTrustworthiness(aBig, nBig, nD, aEb, 2, 5, 2)
	nMsG = (StzEngineWatchTimestampNs() - nT0) / 1000000
	? "  T(5) at 4,000: CPU " + nTbc + " in " + nMsC + " ms   device " + nTbg + " in " + nMsG + " ms   = " + (nMsC / nMsG) + "x"
	chk("the same number at 4,000 points within four rank units", fabs(nTbc - nTbg) < 4 * 2 / (nBig * 5 * (2 * nBig - 16)))
	chk("the device witness is at least 3x faster there", nMsC / nMsG >= 3)
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

func fabs n
	if n < 0 return -n ok
	return n

func blobs nN_, nD_
	_a_ = []
	for _i_ = 1 to nN_
		_b_ = (_i_ - 1) % 4
		_r_ = []
		for _k_ = 1 to nD_
			_r_ + (_b_ * 4 * ((_k_ + _b_) % 2) + sin(_i_ * 0.731 + _k_ * 1.37) * 0.5)
		next
		_a_ + _r_
	next
	return _a_
