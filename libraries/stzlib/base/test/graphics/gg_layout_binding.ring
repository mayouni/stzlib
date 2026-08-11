load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE LAYOUT BINDING -- is position[i] the position OF node[i]?

	SOFTANZA_GRAPH_PLANE_PLAN.md section 4 names determinism as a risk, and
	graph_layout_determinism.ring answers it well: bit-identical within a
	process, bit-identical ACROSS processes, negative siblings that prove
	the check discriminates.

	None of that touches the question underneath it. A layout can reproduce
	perfectly and still hang every coordinate on the wrong node. That
	failure is WORSE than a jittery layout: it is stable, it looks like a
	picture, and the determinism guard salutes it.

	Three ways the binding can break, all of them silent:

	  DROPPED EDGES   the canvas maps each endpoint through a name->index
	                  map and skips the edge when a lookup misses. A graph
	                  whose ids fold differently from its edge endpoints
	                  would lay out with FEWER edges than it has.
	  PERMUTED        positions returned in engine order, read in face
	                  order.
	  ORDER-SENSITIVE the same graph built in a different insertion order
	                  giving a different SHAPE, not just different numbers.

	Run:  ring gg_layout_binding.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " THE LAYOUT BINDING -- deterministic is not the same as right"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. Every edge must REACH the layout ----------------------"
#
# The canvas skips an edge whose endpoint it cannot find. That is the right
# thing to do with a broken edge and the wrong thing to do quietly: a graph
# laid out with half its edges is a different graph, drawn confidently.
#
# MixedCase ids on purpose. stzGraph folds ids to lowercase, so if Edges()
# ever answered unfolded endpoints the map would miss EVERY edge and the
# layout would be pure repulsion -- an even disc, which is exactly what a
# correct layout of an edgeless graph looks like.
#---------------------------------------------------------------------------

oG = new stzGraph("mixed")
aNames = [ "Alpha", "BETA", "gamma", "DeltaOne", "Epsilon_2" ]
for c in aNames
	oG.AddNode(c)
next
oG.AddEdge("Alpha", "BETA")
oG.AddEdge("BETA", "gamma")
oG.AddEdge("gamma", "DeltaOne")
oG.AddEdge("DeltaOne", "Epsilon_2")

? "   ids as declared : " + @@(aNames)
? "   ids as stored   : " + @@(oG.NodesIds())
? "   edges in graph   : " + len(oG.Edges())

# Every endpoint the layout will look up must be findable among the ids the
# layout indexes by. This is the exact lookup _IndexOf does.
aIds = oG.NodesIds()
nMissed = 0
for aE in oG.Edges()
	if _At(aIds, "" + aE[:from]) = 0  nMissed++  ok
	if _At(aIds, "" + aE[:to]) = 0    nMissed++  ok
next
? "   endpoints that would NOT be found : " + nMissed
chkeq("no edge is silently dropped by the name lookup", nMissed, 0)

#---------------------------------------------------------------------------
? ""
? "-- 2. The binding itself: neighbours must land NEAR ---------"
#
# The structural proof, and the one a permutation cannot survive. Two
# cliques joined by a single bridge: inside a clique every pair is an edge,
# between them almost nothing. If coordinates were attached to the wrong
# ids, the two groups would interleave and the ratio would collapse to ~1.
#
# This asserts a RATIO, not coordinates. Coordinates are a property of the
# schedule; the ratio is a property of the graph, and it is the thing a
# reader of the picture actually relies on.
#---------------------------------------------------------------------------

oTwo = new stzGraph("two")
for i = 1 to 30
	oTwo.AddNode("L" + i)
	oTwo.AddNode("R" + i)
next
for i = 1 to 30
	for j = i + 1 to 30
		oTwo.AddEdge("L" + i, "L" + j)
		oTwo.AddEdge("R" + i, "R" + j)
	next
next
oTwo.AddEdge("L1", "R1")           # the single bridge

oCv = oTwo.GraphCanvas([ :Layout = :Force, :Width = 800, :Height = 800 ])

nInside = _MeanPairDist(oCv, oTwo, "L", "L")
nAcross = _MeanPairDist(oCv, oTwo, "L", "R")
? "   mean distance WITHIN the left clique  : " + nInside
? "   mean distance ACROSS to the right one : " + nAcross
if nInside > 0
	? "   separation ratio : " + (nAcross / nInside) + "x"
ok
chk("the two cliques come APART (ratio > 2)", nAcross > nInside * 2)

# THE NEGATIVE SIBLING. Break the id->position pairing and the same
# measurement must collapse -- otherwise the ratio above proves nothing
# about the binding, only that the layout spreads things out.
#
# HOW THIS CONTROL WAS GOT WRONG FIRST, because the shape of the mistake
# matters more than the fix. The nodes are inserted L1,R1,L2,R2..., so the
# id list ALTERNATES. Rotating positions by one hands every L the position
# of an R -- which is a clean SWAP OF THE TWO GROUPS, and a swap preserves
# separation exactly. The control reported 7.74x and looked like a library
# failure. It was the control that was broken: ANY index shift flips parity
# uniformly on an alternating list, and any stride coprime with 60
# preserves it. Index arithmetic cannot scramble this pairing.
#
# So decouple by VALUE instead of by index: sort the positions on x and
# hand them out in id order. Nothing about that can accidentally respect
# the grouping.
nInsideP = _MeanPairDistDecoupled(oCv, "L", "L")
nAcrossP = _MeanPairDistDecoupled(oCv, "L", "R")
? ""
? "   with names DECOUPLED from positions (sorted by x, dealt in id order):"
? "     within " + nInsideP + "   across " + nAcrossP
if nInsideP > 0
	? "     ratio " + (nAcrossP / nInsideP) + "x   (must be near 1 -- no structure)"
ok
chk("a decoupled binding DESTROYS the separation",
    nAcrossP < nInsideP * 1.5)
? "   so the 7.8x above is about WHICH node, not merely about spread"

#---------------------------------------------------------------------------
? ""
? "-- 3. Insertion order changes the numbers, not the SHAPE -----"
#
# The layout is seeded by node INDEX, so the same graph built in a
# different order gets different coordinates. That is expected. What must
# NOT change is what the picture says: the cliques still separate.
#---------------------------------------------------------------------------

oRev = new stzGraph("rev")
for i = 30 to 1 step -1
	oRev.AddNode("R" + i)
	oRev.AddNode("L" + i)
next
for i = 1 to 30
	for j = i + 1 to 30
		oRev.AddEdge("L" + i, "L" + j)
		oRev.AddEdge("R" + i, "R" + j)
	next
next
oRev.AddEdge("L1", "R1")

oCv2 = oRev.GraphCanvas([ :Layout = :Force, :Width = 800, :Height = 800 ])

nInside2 = _MeanPairDist(oCv2, oRev, "L", "L")
nAcross2 = _MeanPairDist(oCv2, oRev, "L", "R")
? "   same graph, nodes inserted in the opposite order:"
? "     within " + nInside2 + "   across " + nAcross2
if nInside2 > 0
	? "     ratio " + (nAcross2 / nInside2) + "x"
ok
chk("the cliques still come apart", nAcross2 > nInside2 * 2)

# and the coordinates themselves DID move -- if they had not, this scene
# would be asserting nothing
nSameCoord = 0
aP1 = oCv.Positions()
aP2 = oCv2.Positions()
for i = 1 to 10
	if aP1[i][2] = aP2[i][2] and aP1[i][3] = aP2[i][3]  nSameCoord++  ok
next
? "   first 10 coordinates identical across the two builds : " + nSameCoord
chk("insertion order really did move the coordinates", nSameCoord < 10)

#---------------------------------------------------------------------------
? ""
? "-- 4. One position per node, and only real nodes ------------"
#---------------------------------------------------------------------------

chkeq("as many positions as nodes", len(oCv.Positions()), len(oTwo.NodesIds()))
nGhost = 0
for a in oCv.Positions()
	if NOT oTwo.NodeExists(a[1])  nGhost++  ok
next
chkeq("every position names a real node", nGhost, 0)

? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

func _At aList, cWhat
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if StzLower("" + aList[_i_]) = StzLower("" + cWhat)  return _i_  ok
	next
	return 0

# Mean euclidean distance between every node whose id starts cA and every
# node whose id starts cB (skipping a node paired with itself).
func _MeanPairDist poCv, poG, cA, cB
	_aP_ = poCv.Positions()
	_sum_ = 0  _cnt_ = 0
	_n_ = len(_aP_)
	for _i_ = 1 to _n_
		if StzSubStr("" + _aP_[_i_][1], 1, 1) != StzLower(cA)  loop  ok
		for _j_ = 1 to _n_
			if _i_ = _j_  loop  ok
			if StzSubStr("" + _aP_[_j_][1], 1, 1) != StzLower(cB)  loop  ok
			_dx_ = _aP_[_i_][2] - _aP_[_j_][2]
			_dy_ = _aP_[_i_][3] - _aP_[_j_][3]
			_sum_ += sqrt(_dx_ * _dx_ + _dy_ * _dy_)
			_cnt_++
		next
	next
	if _cnt_ = 0  return 0  ok
	return _sum_ / _cnt_

# The negative control. Sorting the positions by x and dealing them out in
# id order breaks the pairing by VALUE, so it cannot accidentally respect a
# grouping the way index arithmetic did.
func _MeanPairDistDecoupled poCv, cA, cB
	_aP0_ = poCv.Positions()
	_m_ = len(_aP0_)

	# insertion sort of the coordinate pairs on x -- small n, and it keeps
	# the control free of any library sort whose stability could matter
	_aXY_ = []
	for _i_ = 1 to _m_
		_aXY_ + [ _aP0_[_i_][2], _aP0_[_i_][3] ]
	next
	for _i_ = 2 to _m_
		_cur_ = _aXY_[_i_]
		_j_ = _i_ - 1
		while _j_ >= 1 and _aXY_[_j_][1] > _cur_[1]
			_aXY_[_j_ + 1] = _aXY_[_j_]
			_j_--
		end
		_aXY_[_j_ + 1] = _cur_
	next

	_aP_ = []
	for _i_ = 1 to _m_
		_aP_ + [ _aP0_[_i_][1], _aXY_[_i_][1], _aXY_[_i_][2] ]
	next

	_sum_ = 0  _cnt_ = 0
	for _i_ = 1 to _m_
		if StzSubStr("" + _aP_[_i_][1], 1, 1) != StzLower(cA)  loop  ok
		for _j_ = 1 to _m_
			if _i_ = _j_  loop  ok
			if StzSubStr("" + _aP_[_j_][1], 1, 1) != StzLower(cB)  loop  ok
			_dx_ = _aP_[_i_][2] - _aP_[_j_][2]
			_dy_ = _aP_[_i_][3] - _aP_[_j_][3]
			_sum_ += sqrt(_dx_ * _dx_ + _dy_ * _dy_)
			_cnt_++
		next
	next
	if _cnt_ = 0  return 0  ok
	return _sum_ / _cnt_
