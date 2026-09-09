# GS4 -- the resident semantic index routed through the GPU
# (SOFTANZA_GPU_PLAN.md, GS4: the seam the survey found already paid for).
#
# stzSemanticIndex keeps its vectors in a RESIDENT engine dataset and
# answers exact top-k on it. When the corpus earns the GPU -- the shared
# "pairdist" calibration, consulted BEFORE any device exists -- the vectors
# go resident on the device as f32 once, and every search moves d floats
# in and k pairs out through the pairdist + top-k kernels the vector index
# seam already runs. The caller calls the SAME method and notices nothing
# but the speed. The CPU dataset stays built: it is the truth, and the
# fallback for every refusal.
#
# What this guard asserts -- BOTH SIDES of the line, mechanism first:
#   - below the line: no dispatch, nothing resident on the device, the
#     CPU answers (the negative side)
#   - forced above the line: the corpus IS resident (three device buffers),
#     a search MOVES the dispatch counter, the hits are the CPU's hits in the
#     CPU's order, and the scores agree within the f32 band
#   - THE SCORE IS A COSINE, on BOTH routes, checked independently: the
#     reported score of a hit equals the dot product of the query embedding
#     with that hit's stored vector (unit vectors: cos = 1 - d^2/2). The GPU
#     kernel ranks on SQUARED distance and the CPU top-k on euclidean; a
#     route that squared the wrong thing would fail here by a lot
#   - more searches = more dispatches; Close() frees the device buffers;
#     a device lost mid-life drops to the CPU with the same answer
#   - the seam's OWN calibration (stzGpu.CalibrateKnnResident) on a tiny
#     ladder stores classes under its own key, never the GPU op's, and the
#     machine's real calibration files are kept and put back
#   - (with the real MiniLM present) an 800 x 384 corpus, both routes timed
#     the same way with the device woken first -- informational
#
# tiny_bert.gguf (synthetic, 32-dim) carries every mechanism scene without a
# download; the MiniLM scene is skipped with a line when the file is absent.

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_DISP = 0
C_LIVE = 8

pr()

decimals(9)

# SIXTY DISTINCT UNIT VECTORS, no model: a synthetic model that maps every
# text to one vector (tiny_bert does) makes every score 1 and every hit a
# tie -- a scene on it proves the tie rule, not the seam. The face's
# bring-your-own-embedding door (AddEmbedded / SearchByVectorXT) carries
# the mechanism scenes on vectors built here, normalised in f64.
nDim = 32
acTexts = []
aVecs = []
for i = 1 to 60
	acTexts + ("text number " + i + " about topic " + (i % 7) + " and item " + (i % 11))
	aVecs + unitvec(i, nDim)
next

? ""
? "-- Scene 1: BELOW the line, the CPU keeps the corpus (the negative side) --"
StzEngineGpuCalibSet("knn_resident", 0)            # explicit and empty: the shipped state
StzEngineGpuCountersReset()
nLive0 = StzEngineGpuCounter(C_LIVE)
oCpu = new stzSemanticIndex([])
for i = 1 to 60
	oCpu.AddEmbedded(acTexts[i], aVecs[i])
next
aQ = aVecs[17]
aCpuHits = oCpu.SearchByVectorXT(aQ, 5)
chk("60 vectors indexed at 32 dims", oCpu.Count() = 60 and oCpu.EmbeddingDim() = 32)
chk("5 hits", len(aCpuHits) = 5)
chk("the index is NOT on the GPU (an uncalibrated key routes CPU by the engine's rule)", NOT oCpu.UsesGpu())
chk("NO dispatch happened (the counter is the witness)", StzEngineGpuCounter(C_DISP) = 0)
chk("nothing went resident on the device", StzEngineGpuCounter(C_LIVE) = nLive0)
chk("the query vector finds ITS text first, at score 1", aCpuHits[1][3] = 17 and fabs(aCpuHits[1][2] - 1) < 0.000000001)
chk("the CPU score IS the cosine: reported = dot(query, stored vector) within 1e-9",
	fabs(aCpuHits[1][2] - gsdot(aQ, oCpu.Vectors()[aCpuHits[1][3]])) < 0.000000001)
chk("...for the fifth hit too (not only the perfect match)",
	fabs(aCpuHits[5][2] - gsdot(aQ, oCpu.Vectors()[aCpuHits[5][3]])) < 0.000000001)
chk("...and the fifth hit is a different text scoring strictly below 1", aCpuHits[5][3] != 17 and aCpuHits[5][2] < 0.99)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? ""
	? "  NO GPU ON THIS MACHINE -- the seam can never engage; the CPU contract above is the coverage"
else
	? ""
	? "  device: " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
	? ""
	? "-- Scene 2: forced ABOVE the line, the GPU takes the corpus (the positive side) --"
	StzEngineGpuCalibSet("knn_resident", 1)
	StzEngineGpuCountersReset()
	nLive0 = StzEngineGpuCounter(C_LIVE)
	oGpu = new stzSemanticIndex([])
	for i = 1 to 60
		oGpu.AddEmbedded(acTexts[i], aVecs[i])
	next
	aGpuHits = oGpu.SearchByVectorXT(aQ, 5)
	chk("the index IS on the GPU", oGpu.UsesGpu())
	chk("three device buffers live (corpus + query + distances)", StzEngineGpuCounter(C_LIVE) = nLive0 + 3)
	nDisp1 = StzEngineGpuCounter(C_DISP)
	chk("the search MOVED the dispatch counter (the mechanism, not the vibe)", nDisp1 > 0)
	chk("5 hits", len(aGpuHits) = 5)
	bSameOrder = TRUE
	nMaxD = 0
	for i = 1 to 5
		if aGpuHits[i][3] != aCpuHits[i][3]
			bSameOrder = FALSE
		ok
		_d_ = fabs(aGpuHits[i][2] - aCpuHits[i][2])
		if _d_ > nMaxD
			nMaxD = _d_
		ok
	next
	? "  max |score gpu - cpu| over the 5 hits: " + nMaxD
	chk("GPU and CPU name the SAME texts in the SAME order", bSameOrder)
	chk("...with scores inside the f32 band (< 1e-5)", nMaxD < 0.00001)
	chk("the GPU score IS the cosine too: reported = dot(query, stored) within 1e-5",
		fabs(aGpuHits[1][2] - gsdot(aQ, oGpu.Vectors()[aGpuHits[1][3]])) < 0.00001 and
		fabs(aGpuHits[5][2] - gsdot(aQ, oGpu.Vectors()[aGpuHits[5][3]])) < 0.00001)
	chk("the query vector finds ITS text first at ~1 on the GPU route too", aGpuHits[1][3] = 17 and aGpuHits[1][2] > 0.99999)

	? ""
	? "-- Scene 3: every search dispatches; Close() gives the device back --"
	nDispB = StzEngineGpuCounter(C_DISP)
	for q = 1 to 5
		oGpu.SearchByVectorXT(aVecs[q * 9], 3)
	next
	chk("5 more searches = 5 more dispatches", StzEngineGpuCounter(C_DISP) = nDispB + 5)
	oGpu.Close()
	chk("Close() freed the three device buffers", StzEngineGpuCounter(C_LIVE) = nLive0)
	chk("...and the index no longer claims the GPU", NOT oGpu.UsesGpu())

	? ""
	? "-- Scene 4: the device goes away mid-life; the answer does not --"
	oMid = new stzSemanticIndex([])
	for i = 1 to 60
		oMid.AddEmbedded(acTexts[i], aVecs[i])
	next
	aBefore = oMid.SearchByVectorXT(aVecs[40], 3)
	chk("routed to the GPU before the loss", oMid.UsesGpu())
	StzEngineGpuShutdown()
	aAfter = oMid.SearchByVectorXT(aVecs[40], 3)
	chk("after the loss the search still answers (CPU fallback, same contract)",
		len(aAfter) = 3 and aAfter[1][3] = aBefore[1][3] and aAfter[2][3] = aBefore[2][3])
	chk("...and the index dropped its GPU claim", NOT oMid.UsesGpu())
	oMid.Close()
	oCpu.Close()

	? ""
	? "-- Scene 5: the seam's OWN calibration, on a tiny ladder (files kept and restored) --"
	StzEngineGpuInit($cStzGpuRuntime)
	oGk = new stzGpu
	cBakA = ""
	cBakD = ""
	if fexists(StzGpuCalibFileForAdapter())
		cBakA = read(StzGpuCalibFileForAdapter())
	ok
	if fexists(StzGpuCalibFileDefault())
		cBakD = read(StzGpuCalibFileDefault())
	ok
	aRep = oGk.CalibrateKnnResidentWith([200, 800], 32)
	nCells = len(aRep[:cells])
	for i = 1 to nCells
		c = aRep[:cells][i]
		? "  n " + c[2] + " x " + c[1] + "  cpu " + c[3] + " ms  gpu " + c[4] + " ms  ratio " + c[5]
	next
	? "  flat line " + aRep[:flat] + " (" + aRep[:flatwhy] + ")  confounded " + aRep[:confounded]
	chk("two rungs measured, both routes ran (all four times > 0)",
		nCells = 2 and aRep[:cells][1][3] > 0 and aRep[:cells][1][4] > 0 and aRep[:cells][2][3] > 0 and aRep[:cells][2][4] > 0)
	chk("the control ran (8 fields)", len(aRep[:control]) = 8)
	if aRep[:confounded]
		chk("a confounded ladder stores nothing and says so", aRep[:flat] = 0 and StzEngineGpuCalibGetShaped("knn_resident", 200, 32) = 0)
	else
		chk("each rung stored its class under the seam's OWN key",
			StzEngineGpuCalibGetShaped("knn_resident", 200, 32) > 0 and StzEngineGpuCalibGetShaped("knn_resident", 800, 32) > 0)
		chk("...and NOT under the GPU op's key (a line is a comparison, and this one has its own CPU side)",
			StzEngineGpuCalibGetShaped("pairdist", 200, 32) = 0)
		chk("the flat line is a crossover or beyond the ladder, never a seed",
			aRep[:flat] > 0 and (aRep[:flatwhy] = "crossover" or aRep[:flatwhy] = "beyond-ladder"))
		cF = read(StzGpuCalibFileForAdapter())
		chk("the per-adapter file carries the seam's line, its shapes and its ladder",
			StzFindFirst("knn_resident" + char(9), cF) > 0 and StzFindFirst("shape" + char(9) + "knn_resident", cF) > 0 and StzFindFirst("ladder" + char(9) + "knn_resident", cF) > 0)
	ok
	# put the machine's real calibration back
	if cBakA != ""
		write(StzGpuCalibFileForAdapter(), cBakA)
	else
		if fexists(StzGpuCalibFileForAdapter())
			remove(StzGpuCalibFileForAdapter())
		ok
	ok
	if cBakD != ""
		write(StzGpuCalibFileDefault(), cBakD)
	ok
	StzEngineGpuCalibSet("knn_resident", 0)
	StzEngineGpuCalibSetShaped("knn_resident", 200, 32, 0)
	StzEngineGpuCalibSetShaped("knn_resident", 800, 32, 0)

	cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"
	if fexists(cModel)
		? ""
		? "-- Scene 6: a real MiniLM corpus, both routes timed the same way (informational) --"
		chk("MiniLM loads", StzEngineNeuralModelLoad(cModel) = 1)
		StzEngineGpuInit($cStzGpuRuntime)
		acBig = []
		for i = 1 to 800
			acBig + ("sentence " + i + " speaks of subject " + (i % 23) + " in tone " + (i % 5) + " with detail " + (i * 7 % 101))
		next
		StzEngineGpuCalibSet("knn_resident", 999999999999)
		oC = new stzSemanticIndex(acBig)
		# the route is decided at the FIRST search: settle the CPU twin under
		# its own knob before the knob moves for the GPU one
		oC.SearchXT("warm", 1)
		chk("the CPU twin stayed on the CPU", NOT oC.UsesGpu())
		StzEngineGpuCalibSet("knn_resident", 1)
		oGpuB = new stzSemanticIndex(acBig)
		oGpuB.SearchXT("warm", 1)
		if NOT oGpuB.UsesGpu()
			? "  NOT resident: avail " + StzEngineGpuIsAvailable() + "  route " + StzEngineGpuCalibRouteShaped("pairdist", 800, 384) +
				"  gate " + StzEngineGpuShouldDispatchShaped("pairdist", 800, 384) + "  err '" + StzEngineGpuLastError() + "'"
		ok
		chk("800 x 384 resident on the GPU", oGpuB.UsesGpu() and oGpuB.EmbeddingDim() = 384)
		cQ = "a sentence about subject 9 in tone 2"
		aC = oC.SearchXT(cQ, 5)
		aG = oGpuB.SearchXT(cQ, 5)
		bSame = TRUE
		for i = 1 to 5
			if aC[i][3] != aG[i][3] bSame = FALSE ok
		next
		chk("same five texts, same order, at MiniLM scale", bSame)
		StzEngineGpuWake(400)
		nEmbMs = minembed(cQ)
		nCpuMs = minsearch(oC, cQ)
		nGpuMs = minsearch(oGpuB, cQ)
		aQb = StzNeuralEmbeddingOf(cQ)
		nCpuSeam = minvsearch(oC, aQb)
		nGpuSeam = minvsearch(oGpuB, aQb)
		? "  per text search: CPU route " + nCpuMs + " ms, GPU route " + nGpuMs + " ms; the query embedding alone " + nEmbMs + " ms"
		? "  the seam alone (search by vector, embedding excluded): CPU top-k " + nCpuSeam + " ms vs GPU pairdist+top-k " + nGpuSeam + " ms at 800 x 384 -- informational; the line is calibrated, not assumed"
		oC.Close()
		oGpuB.Close()
	else
		? ""
		? "  MiniLM not present (" + cModel + ") -- the scale scene is skipped, and says so"
	ok
ok

StzEngineNeuralModelFree()

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

func gsdot a, b
	_s_ = 0
	_n_ = len(a)
	for _i_ = 1 to _n_
		_s_ += a[_i_] * b[_i_]
	next
	return _s_

func minsearch oI, cQ
	_best_ = 999999
	for _r_ = 1 to 3
		_t0_ = StzEngineWatchTimestampNs()
		oI.SearchXT(cQ, 5)
		_ms_ = (StzEngineWatchTimestampNs() - _t0_) / 1000000
		if _ms_ < _best_ _best_ = _ms_ ok
	next
	return _best_

func minembed cQ
	_best_ = 999999
	for _r_ = 1 to 3
		_t0_ = StzEngineWatchTimestampNs()
		StzNeuralEmbeddingOf(cQ)
		_ms_ = (StzEngineWatchTimestampNs() - _t0_) / 1000000
		if _ms_ < _best_ _best_ = _ms_ ok
	next
	return _best_

func minvsearch oI, aQ
	_best_ = 999999
	for _r_ = 1 to 5
		_t0_ = StzEngineWatchTimestampNs()
		oI.SearchByVectorXT(aQ, 5)
		_ms_ = (StzEngineWatchTimestampNs() - _t0_) / 1000000
		if _ms_ < _best_ _best_ = _ms_ ok
	next
	return _best_

# a deterministic, distinct unit vector per index: a smooth signature that
# no two indices share, normalised in f64
func unitvec i, d
	_v_ = []
	_ss_ = 0
	for _j_ = 1 to d
		_x_ = sin(i * 0.37 + _j_ * 1.13) + 0.5 * cos(i * _j_ * 0.071)
		_v_ + _x_
		_ss_ += _x_ * _x_
	next
	_n_ = sqrt(_ss_)
	for _j_ = 1 to d
		_v_[_j_] = _v_[_j_] / _n_
	next
	return _v_
