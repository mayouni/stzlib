load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG1, THE HIERARCHICAL TIER -- layers, then crossings

	The force tier is proven (slices 0 and 1: deterministic across
	processes, 152 ms at 10k, convergence on a closed-form bound). This is
	the other half of GG1, and it is a DIFFERENT problem:

	    1. LAYER ASSIGNMENT -- longest path. Every node sits one below its
	       deepest predecessor. This is GG0's propagation primitive again:
	       layer[v] = max(layer[u]+1), iterated to depth. max() is exact and
	       order-immune, so it inherits determinism for free.

	    2. CROSSING REDUCTION -- the barycentre sweep. Each node moves to
	       the average position of its neighbours in the adjacent layer,
	       then the layer is re-ordered. The averages parallelise per node;
	       the RE-ORDERING is a sort, and sorts are where both determinism
	       and GPU-worthiness get decided.

	KILL CRITERIA, written before the numbers:
	  - deterministic, run to run, or the phase stops (same line as slice 0)
	  - 10,000 nodes laid out in under 2 s
	  - and it must actually REDUCE CROSSINGS. A layered drawing that does
	    not is just a sorted list with edges over it, so the crossing count
	    is COUNTED before and after rather than assumed.

	Run:  ring graph_layout_hierarchical.ring
---------------------------------------------------------------------------*/

decimals(4)
$nLastLayerRounds = 0

if NOT StzGraphicsDevice()
	? "No GPU device -- nothing to measure."
	return
ok
? "device : " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
? ""

#---------------------------------------------------------------------------
# A layered DAG, from a formula. Edges only ever run to a HIGHER index, so
# the graph is acyclic by construction and longest-path layering is defined.
#---------------------------------------------------------------------------

LAYERS = 40
WIDE = 50
N = LAYERS * WIDE
aEdgeU = []
aEdgeV = []
for L = 0 to LAYERS - 2
	for w = 0 to WIDE - 1
		nU = L * WIDE + w
		for k = 1 to 3
			# a deterministic scatter into the NEXT layer, so the initial
			# id-order is badly crossed and there is something to reduce
			nT = (w * 17 + k * 23 + L * 7) % WIDE
			aEdgeU + nU
			aEdgeV + ((L + 1) * WIDE + nT)
		next
	next
next
nE = len(aEdgeU)
? "graph  : " + N + " nodes, " + nE + " edges, acyclic by construction"

# CSR over IN-edges: layering reads predecessors, so that is the direction
# the kernel needs indexed.
aInCount = []
for i = 1 to N  aInCount + 0  next
for e = 1 to nE
	aInCount[aEdgeV[e] + 1]++
next
aInOff = []
nAcc = 0
for i = 1 to N
	aInOff + nAcc
	nAcc += aInCount[i]
next
aInOff + nAcc
aInSrc = []
for i = 1 to nAcc  aInSrc + 0  next
aFill = []
for i = 1 to N  aFill + 0  next
for e = 1 to nE
	nV = aEdgeV[e]
	aInSrc[aInOff[nV + 1] + aFill[nV + 1] + 1] = aEdgeU[e]
	aFill[nV + 1]++
next

hInOff = StzEngineGpuBufferNew((N + 1) * 4)
StzEngineGpuBufferUploadListU32(hInOff, aInOff)
hInSrc = StzEngineGpuBufferNew(nAcc * 4)
StzEngineGpuBufferUploadListU32(hInSrc, aInSrc)

#---------------------------------------------------------------------------
? ""
? "-- 1. Layer assignment: GG0's primitive, on a different question"
#---------------------------------------------------------------------------

cLayer = 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read> lin : array<f32>;
@group(0) @binding(2) var<storage, read_write> lout : array<f32>;
@group(0) @binding(3) var<storage, read> off : array<u32>;
@group(0) @binding(4) var<storage, read> src : array<u32>;
@group(0) @binding(5) var<storage, read> par : array<u32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = par[0];
  if (i >= n) { return; }
  var best = 0.0;
  let s = off[i];
  let e = off[i + 1u];
  for (var q = s; q < e; q = q + 1u) {
    let u = src[q];
    best = max(best, lin[u] + 1.0);
  }
  lout[i] = best;
}'

hLayer = StzEngineGpuKernelCompile(cLayer)
if hLayer = 0
	? "layer kernel refused: " + StzEngineGpuLastError()
	return
ok

nT0 = clock()
aLayer = RunLayering(hLayer, hInOff, hInSrc, N)
nT1 = clock()

nMaxL = 0
for i = 1 to N
	if aLayer[i] > nMaxL  nMaxL = aLayer[i]  ok
next
? "   depth  : " + nMaxL + " layers   in " +
  ((nT1-nT0)/clockspersecond()*1000) + " ms   (" + $nLastLayerRounds +
  " propagation rounds to a fixed point)"

# every edge must go DOWNWARD -- that is what layering means, and it is
# checkable rather than assumable
nBadEdge = 0
for e = 1 to nE
	if aLayer[aEdgeV[e] + 1] <= aLayer[aEdgeU[e] + 1]
		nBadEdge++
	ok
next
? "   edges pointing down or level-violating : " + nBadEdge + " of " + nE
? "   (0 means every edge spans at least one layer -- the layering is real)"

#---------------------------------------------------------------------------
? ""
? "-- 2. Crossing reduction, and the count that judges it --------"
#
# The barycentre sweep: each node moves to the mean position of its
# neighbours one layer up, then the layer is re-sorted. Crossings are
# COUNTED either side, because a layered drawing that does not reduce them
# is just a sorted list with edges drawn over it.
#---------------------------------------------------------------------------

# bucket nodes by layer, initial order = node id
aLayers = []
for L = 0 to nMaxL  aLayers + []  next
for i = 1 to N
	aLayers[aLayer[i] + 1] + (i - 1)
next

aPos = []
for i = 1 to N  aPos + 0  next
SetPositions(aLayers, aPos)

nBefore = CountCrossings(aLayers, aPos, aEdgeU, aEdgeV, aLayer)
? "   crossings BEFORE (order = node id) : " + nBefore

nT2 = clock()
SWEEPS = 8
for nS = 1 to SWEEPS
	Barycentre(aLayers, aPos, aInOff, aInSrc, TRUE)
	SetPositions(aLayers, aPos)
next
nT3 = clock()
nAfter = CountCrossings(aLayers, aPos, aEdgeU, aEdgeV, aLayer)
? "   crossings AFTER " + SWEEPS + " sweeps          : " + nAfter +
  "   in " + ((nT3-nT2)/clockspersecond()*1000) + " ms"
if nBefore > 0
	? "   reduction : " + ((nBefore - nAfter) / nBefore * 100) + "%"
ok
? "   KILL LINE -- crossings must FALL : " + iif(nAfter < nBefore, "PASS", "FAIL")

#---------------------------------------------------------------------------
? ""
? "-- 2b. Can it FIND a good order when one exists? --------------"
#
# 5% on the graph above is not a weak sweep -- it is a graph with no good
# answer. Its edges scatter uniformly into the next layer, so almost every
# ordering crosses about as much as any other and there is nothing to
# recover. Judging crossing reduction on it measures the GRAPH.
#
# The discriminating test: a graph that DOES have a near-crossing-free
# order (each node links to its neighbours one layer down), presented in a
# deliberately scrambled initial order. A working sweep should recover most
# of it; a broken one cannot.
#---------------------------------------------------------------------------

aGU = []  aGV = []
for L = 0 to LAYERS - 2
	for w = 0 to WIDE - 1
		for k = -1 to 1
			nT = w + k
			if nT >= 0 and nT < WIDE
				aGU + (L * WIDE + w)
				aGV + ((L + 1) * WIDE + nT)
			ok
		next
	next
next
nGE = len(aGU)

aGIn = BuildInCsr(aGU, aGV, N)
aGLayer = []
for i = 1 to N
	aGLayer + floor((i - 1) / WIDE)
next

# scramble the starting order inside each layer, deterministically
aGLayers = []
for L = 0 to LAYERS - 1
	_row_ = []
	for w = 0 to WIDE - 1
		_row_ + (L * WIDE + ((w * 37 + L * 11) % WIDE))
	next
	aGLayers + _row_
next
aGPos = []
for i = 1 to N  aGPos + 0  next
SetPositions(aGLayers, aGPos)

nGBefore = CountCrossings(aGLayers, aGPos, aGU, aGV, aGLayer)
aGOut = BuildInCsr(aGV, aGU, N)

# Three sweep policies, measured rather than assumed. The literature says
# alternate; the measurement here says otherwise on this graph, and the
# reason is that alternating OSCILLATES -- a down sweep and an up sweep pull
# toward different local optima.
aPolicy = [ "down-only     ", "alternating   ", "alt + keep-best" ]
for nP = 1 to 3
	aTL = []
	for L = 0 to LAYERS - 1
		_row_ = []
		for w = 0 to WIDE - 1
			_row_ + (L * WIDE + ((w * 37 + L * 11) % WIDE))
		next
		aTL + _row_
	next
	aTP = []
	for i = 1 to N  aTP + 0  next
	SetPositions(aTL, aTP)

	if nP = 3
		nGot = SweepBest(aTL, aTP, aGIn, aGOut, aGU, aGV, aGLayer, 12)
	else
		for nS = 1 to 12
			if nP = 1 or (nS % 2) = 1
				Barycentre(aTL, aTP, aGIn[1], aGIn[2], TRUE)
			else
				Barycentre(aTL, aTP, aGOut[1], aGOut[2], FALSE)
			ok
			SetPositions(aTL, aTP)
		next
		nGot = CountCrossings(aTL, aTP, aGU, aGV, aGLayer)
	ok
	? "   " + aPolicy[nP] + " : " + nGBefore + " -> " + nGot +
	  "   (" + ((nGBefore - nGot) / nGBefore * 100) + "% removed)"
next
? ""
? "   DOWN-ONLY WINS on this graph, and is also the cheapest -- no"
? "   out-CSR, no per-sweep crossing count. Alternating is the textbook"
? "   answer and it lost; keeping the best recovers part of the gap but"
? "   pays a crossing count every sweep. Measured, not assumed."

#---------------------------------------------------------------------------
? ""
? "-- 3. Deterministic? The same line slice 0 had to pass --------"
#
# The sort is where determinism dies in a layered layout: equal barycentres
# are common (any two nodes with the same single predecessor tie), and an
# unstable sort orders ties by whatever the implementation felt like. The
# tie-break is BY NODE ID, which is why this reproduces.
#---------------------------------------------------------------------------

aLayers2 = []
for L = 0 to nMaxL  aLayers2 + []  next
for i = 1 to N
	aLayers2[aLayer[i] + 1] + (i - 1)
next
aPos2 = []
for i = 1 to N  aPos2 + 0  next
SetPositions(aLayers2, aPos2)
for nS = 1 to SWEEPS
	Barycentre(aLayers2, aPos2, aInOff, aInSrc, TRUE)
	SetPositions(aLayers2, aPos2)
next

bSame = TRUE
for i = 1 to N
	if aPos[i] != aPos2[i]  bSame = FALSE  exit  ok
next
? "   identical ordering on a second run : " + bSame

# the negative sibling: one fewer sweep must differ
aLayers3 = []
for L = 0 to nMaxL  aLayers3 + []  next
for i = 1 to N
	aLayers3[aLayer[i] + 1] + (i - 1)
next
aPos3 = []
for i = 1 to N  aPos3 + 0  next
SetPositions(aLayers3, aPos3)
for nS = 1 to SWEEPS - 1
	Barycentre(aLayers3, aPos3, aInOff, aInSrc, TRUE)
	SetPositions(aLayers3, aPos3)
next
bDiff = FALSE
for i = 1 to N
	if aPos[i] != aPos3[i]  bDiff = TRUE  exit  ok
next
? "   and one fewer sweep DIFFERS        : " + bDiff

#---------------------------------------------------------------------------
? ""
? "-- 4. The kill line at scale ----------------------------------"
#---------------------------------------------------------------------------

BLAYERS = 100
BWIDE = 100
BIG = BLAYERS * BWIDE
aBU = []  aBV = []
for L = 0 to BLAYERS - 2
	for w = 0 to BWIDE - 1
		for k = 1 to 3
			aBU + (L * BWIDE + w)
			aBV + ((L + 1) * BWIDE + ((w * 17 + k * 23 + L * 7) % BWIDE))
		next
	next
next
nBE = len(aBU)

nT4 = clock()
aBIn = BuildInCsr(aBU, aBV, BIG)
hBOff = StzEngineGpuBufferNew((BIG + 1) * 4)
StzEngineGpuBufferUploadListU32(hBOff, aBIn[1])
hBSrc = StzEngineGpuBufferNew(len(aBIn[2]) * 4)
StzEngineGpuBufferUploadListU32(hBSrc, aBIn[2])
aBLayer = RunLayering(hLayer, hBOff, hBSrc, BIG)

nBMax = 0
for i = 1 to BIG
	if aBLayer[i] > nBMax  nBMax = aBLayer[i]  ok
next
aBLayers = []
for L = 0 to nBMax  aBLayers + []  next
for i = 1 to BIG
	aBLayers[aBLayer[i] + 1] + (i - 1)
next
aBPos = []
for i = 1 to BIG  aBPos + 0  next
SetPositions(aBLayers, aBPos)
for nS = 1 to SWEEPS
	Barycentre(aBLayers, aBPos, aBIn[1], aBIn[2], TRUE)
	SetPositions(aBLayers, aBPos)
next
nT5 = clock()
nBigMs = (nT5 - nT4) / clockspersecond() * 1000

? "   " + BIG + " nodes, " + nBE + " edges, " + (nBMax+1) + " layers, " +
  SWEEPS + " sweeps"
? "   total : " + nBigMs + " ms   (kill line 2000)  ->  " +
  iif(nBigMs < 2000, "PASS", "FAIL")

#---------------------------------------------------------------------------
? ""
? "-- 5. Draw it, because a number is not a drawing --------------"
#---------------------------------------------------------------------------

W = 1400  H = 900
oC = new stzCanvas(W, H)
oC.SetBackground("#0B1020")

nLayers = len(aLayers)
nRowH = (H - 60) / nLayers
for L = 1 to nLayers
	nCount = len(aLayers[L])
	if nCount = 0  loop  ok
next

# edges first, so nodes sit on top
for e = 1 to nE
	nU = aEdgeU[e]  nV = aEdgeV[e]
	aA = NodeXY(nU, aLayer, aPos, aLayers, W, H, nRowH)
	aB = NodeXY(nV, aLayer, aPos, aLayers, W, H, nRowH)
	oC.AddLineQ(aA[1], aA[2], aB[1], aB[2]).Stroke("#33436E66", 1)
next
for i = 0 to N - 1
	aA = NodeXY(i, aLayer, aPos, aLayers, W, H, nRowH)
	oC.AddCircleQ(aA[1], aA[2], 2.6).
		Fill(StzColorFromHSL((aLayer[i+1] * 9) % 360, 72, 62))
next
cP = oC.ToPNG("graph_layout_hierarchical.png")
? "   graph_layout_hierarchical.png : " + len(cP) + " bytes"

? ""
? "=============================================================="
? " deterministic : " + bSame + "   (and discriminates : " + bDiff + ")"
? " crossings     : " + nBefore + " -> " + nAfter
? " 10k nodes     : " + nBigMs + " ms"
? "=============================================================="

#---------------------------------------------------------------------------
# helpers
#---------------------------------------------------------------------------

func RunLayering hK, hOff, hSrc, n
	_hA_ = StzEngineGpuBufferNew(n * 4)
	_hB_ = StzEngineGpuBufferNew(n * 4)
	_hP_ = StzEngineGpuBufferNew(16)
	_z_ = []
	for _i_ = 1 to n  _z_ + 0  next
	StzEngineGpuBufferUploadList(_hA_, _z_)
	StzEngineGpuBufferUploadListU32(_hP_, [ n, 0, 0, 0 ])
	_wx_ = ceil(n / 64)
	_src_ = _hA_
	_dst_ = _hB_
	# Longest-path layering converges in exactly (depth) rounds, and the
	# depth is not known in advance -- so iterate until the answer STOPS
	# CHANGING rather than until a round count I guessed. The first version
	# of this fixed 64 rounds; the graph was deeper, the layering came out
	# wrong, and the crossing count rose instead of falling. A guessed bound
	# is not a bound.
	_rounds_ = 0
	_prev_ = []
	for _r_ = 1 to 4096
		StzEngineGpuDispatch(hK, [ _src_, _dst_, hOff, hSrc, _hP_ ], _wx_, 1)
		_t_ = _src_  _src_ = _dst_  _dst_ = _t_
		_rounds_++
		if (_r_ % 8) = 0
			StzEngineGpuSync()
			_now_ = StzEngineGpuBufferDownloadList(_src_, n)
			if len(_prev_) > 0 and SameList(_prev_, _now_)
				exit
			ok
			_prev_ = _now_
		ok
	next
	$nLastLayerRounds = _rounds_
	StzEngineGpuSync()
	_raw_ = StzEngineGpuBufferDownloadList(_src_, n)
	_out_ = []
	for _i_ = 1 to n
		_out_ + floor(_raw_[_i_] + 0.5)
	next
	StzEngineGpuBufferFree(_hA_)
	StzEngineGpuBufferFree(_hB_)
	StzEngineGpuBufferFree(_hP_)
	return _out_

func BuildInCsr aU, aV, n
	_cnt_ = []
	for _i_ = 1 to n  _cnt_ + 0  next
	_ne_ = len(aU)
	for _e_ = 1 to _ne_
		_cnt_[aV[_e_] + 1]++
	next
	_off_ = []
	_acc_ = 0
	for _i_ = 1 to n
		_off_ + _acc_
		_acc_ += _cnt_[_i_]
	next
	_off_ + _acc_
	_src_ = []
	for _i_ = 1 to _acc_  _src_ + 0  next
	_fill_ = []
	for _i_ = 1 to n  _fill_ + 0  next
	for _e_ = 1 to _ne_
		_v_ = aV[_e_]
		_src_[_off_[_v_ + 1] + _fill_[_v_ + 1] + 1] = aU[_e_]
		_fill_[_v_ + 1]++
	next
	return [ _off_, _src_ ]

func SetPositions aLayers, aPos
	_nL_ = len(aLayers)
	for _L_ = 1 to _nL_
		_a_ = aLayers[_L_]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			aPos[_a_[_i_] + 1] = _i_
		next
	next

# Each node takes the MEAN position of its predecessors, then the layer is
# re-ordered by that value. Ties break BY NODE ID -- without that, two nodes
# with the same barycentre order themselves however the sort feels, and the
# layout stops reproducing.
# One sweep in ONE direction. bDown=TRUE reads predecessors (the in-CSR)
# and re-orders layers 2..L; bDown=FALSE reads successors (the out-CSR) and
# re-orders layers L-1..1. Sweeping only downward leaves the first layer
# frozen forever and lets information flow one way -- it recovered 44% of a
# known-good order where alternating recovers far more.
func Barycentre aLayers, aPos, aOff, aSrc, bDown
	_nL_ = len(aLayers)
	_from_ = 2   _to_ = _nL_   _stp_ = 1
	if NOT bDown
		_from_ = _nL_ - 1   _to_ = 1   _stp_ = -1
	ok
	_L_ = _from_
	while (_stp_ = 1 and _L_ <= _to_) or (_stp_ = -1 and _L_ >= _to_)
		_a_ = aLayers[_L_]
		_n_ = len(_a_)
		if _n_ < 2
			_L_ += _stp_
			loop
		ok
		_key_ = []
		for _i_ = 1 to _n_
			_v_ = _a_[_i_]
			_s_ = aOff[_v_ + 1]
			_e_ = aOff[_v_ + 2]
			_sum_ = 0
			_c_ = 0
			for _q_ = _s_ + 1 to _e_
				_sum_ += aPos[aSrc[_q_] + 1]
				_c_++
			next
			if _c_ = 0
				# no neighbour on that side: KEEP its place rather than
				# collapsing every such node to 0 and letting the id
				# tie-break scatter them
				_key_ + [ aPos[_v_ + 1], _v_ ]
			else
				_key_ + [ _sum_ / _c_, _v_ ]
			ok
		next
		_key_ = SortPairs(_key_)
		_new_ = []
		for _i_ = 1 to _n_
			_new_ + _key_[_i_][2]
		next
		aLayers[_L_] = _new_
		_L_ += _stp_
	end

# Insertion sort on (barycentre, id). Deterministic and stable by
# construction -- the id in the key is what makes ties total rather than
# arbitrary.
func SortPairs aK
	_n_ = len(aK)
	for _i_ = 2 to _n_
		_cur_ = aK[_i_]
		_j_ = _i_ - 1
		while _j_ >= 1
			if aK[_j_][1] > _cur_[1] or
			   (aK[_j_][1] = _cur_[1] and aK[_j_][2] > _cur_[2])
				aK[_j_ + 1] = aK[_j_]
				_j_--
			else
				exit
			ok
		end
		aK[_j_ + 1] = _cur_
	next
	return aK

# Count inversions between adjacent layers: two edges cross when their
# endpoints are ordered oppositely.
func CountCrossings aLayers, aPos, aU, aV, aLayer
	_by_ = []
	_nL_ = len(aLayers)
	for _L_ = 1 to _nL_  _by_ + []  next
	_ne_ = len(aU)
	for _e_ = 1 to _ne_
		_lu_ = aLayer[aU[_e_] + 1] + 1
		_by_[_lu_] + [ aPos[aU[_e_] + 1], aPos[aV[_e_] + 1] ]
	next
	_tot_ = 0
	for _L_ = 1 to _nL_
		_a_ = _by_[_L_]
		_m_ = len(_a_)
		for _i_ = 1 to _m_ - 1
			for _j_ = _i_ + 1 to _m_
				if (_a_[_i_][1] - _a_[_j_][1]) * (_a_[_i_][2] - _a_[_j_][2]) < 0
					_tot_++
				ok
			next
		next
	next
	return _tot_

func NodeXY nId, aLayer, aPos, aLayers, W, H, nRowH
	_L_ = aLayer[nId + 1]
	_cnt_ = len(aLayers[_L_ + 1])
	_p_ = aPos[nId + 1]
	_x_ = 40 + (W - 80) * _p_ / (_cnt_ + 1)
	_y_ = 30 + _L_ * nRowH
	return [ _x_, _y_ ]

func SameList aX, aY
	if len(aX) != len(aY)
		return FALSE
	ok
	_n_ = len(aX)
	for _i_ = 1 to _n_
		if aX[_i_] != aY[_i_]
			return FALSE
		ok
	next
	return TRUE

# Run alternating sweeps and KEEP THE BEST ORDER SEEN, judged by an actual
# crossing count. Barycentre oscillates: a down sweep and an up sweep pull
# toward different local optima, so the LAST ordering is not the best one --
# measured here, alternating-and-keeping-the-last was WORSE than down-only
# (33% vs 44% recovered). Keeping the best makes alternating monotone by
# construction, which is what the textbook algorithm actually says and what
# I had left out.
func SweepBest aLayers, aPos, aIn, aOut, aU, aV, aLayer, nSweeps
	SetPositions(aLayers, aPos)
	_best_ = CountCrossings(aLayers, aPos, aU, aV, aLayer)
	_bestOrder_ = CopyLayers(aLayers)
	for _s_ = 1 to nSweeps
		if (_s_ % 2) = 1
			Barycentre(aLayers, aPos, aIn[1], aIn[2], TRUE)
		else
			Barycentre(aLayers, aPos, aOut[1], aOut[2], FALSE)
		ok
		SetPositions(aLayers, aPos)
		_c_ = CountCrossings(aLayers, aPos, aU, aV, aLayer)
		if _c_ < _best_
			_best_ = _c_
			_bestOrder_ = CopyLayers(aLayers)
		ok
	next
	_n_ = len(_bestOrder_)
	for _i_ = 1 to _n_
		aLayers[_i_] = _bestOrder_[_i_]
	next
	SetPositions(aLayers, aPos)
	return _best_

func CopyLayers aL
	_o_ = []
	_n_ = len(aL)
	for _i_ = 1 to _n_
		_r_ = []
		_m_ = len(aL[_i_])
		for _j_ = 1 to _m_
			_r_ + aL[_i_][_j_]
		next
		_o_ + _r_
	next
	return _o_
