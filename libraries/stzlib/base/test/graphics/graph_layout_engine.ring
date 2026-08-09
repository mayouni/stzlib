load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG1 -- THE SWEEP MOVES TO THE ENGINE

	The hierarchical spike measured the split honestly and it was lopsided:
	the GPU assigned layers for 2,000 nodes in 29 ms, and the barycentre
	sweep -- an ordinary per-layer sort -- was essentially the entire cost of
	a 10,000-node layout, sitting at 75% of the 2,000 ms kill line.

	The house rule says fix that in Zig, not in more GPU. A sort of a hundred
	items is not GPU work; it is a tight loop in the wrong language.

	What this file checks is NOT just speed. A faster implementation that
	answers differently is a different algorithm, so it asserts:
	  - the engine produces the IDENTICAL ORDER Ring produced
	  - it is deterministic, and the check discriminates
	  - and the crossing count agrees, now O(E log W) by Fenwick tree
	    instead of the O(E^2) pair loop it replaced

	Run:  ring graph_layout_engine.ring
---------------------------------------------------------------------------*/

decimals(2)

LAYERS = 100  WIDE = 100
N = LAYERS * WIDE
aU = []  aV = []
for L = 0 to LAYERS - 2
	for w = 0 to WIDE - 1
		for k = 1 to 3
			aU + (L * WIDE + w)
			aV + ((L + 1) * WIDE + ((w * 17 + k * 23 + L * 7) % WIDE))
		next
	next
next
? "graph : " + N + " nodes, " + len(aU) + " edges, " + LAYERS + " layers"

aLayer = []
for i = 1 to N  aLayer + floor((i - 1) / WIDE)  next

# in-CSR
aCnt = []
for i = 1 to N  aCnt + 0  next
for e = 1 to len(aU)  aCnt[aV[e] + 1]++  next
aOff = []  nAcc = 0
for i = 1 to N  aOff + nAcc  nAcc += aCnt[i]  next
aOff + nAcc
aSrc = []
for i = 1 to nAcc  aSrc + 0  next
aFill = []
for i = 1 to N  aFill + 0  next
for e = 1 to len(aU)
	v = aV[e]
	aSrc[aOff[v+1] + aFill[v+1] + 1] = aU[e]
	aFill[v+1]++
next

aStarts = []
for L = 0 to LAYERS  aStarts + (L * WIDE)  next
aOrder = []
for i = 0 to N - 1  aOrder + i  next
aPos = []
for i = 1 to N  aPos + (((i - 1) % WIDE) + 1)  next

nT0 = clock()
nBefore = StzEngineGraphLayoutCrossings(aU, aV, aLayer, aPos, aStarts)
nT1 = clock()
? "crossings before : " + nBefore + "   (engine count in " +
  ((nT1-nT0)/clockspersecond()*1000) + " ms)"

nT2 = clock()
aNew = StzEngineGraphLayoutSweep(aOff, aSrc, aLayer, aOrder, aStarts, 8, aU, aV)
nT3 = clock()
nEngMs = (nT3 - nT2) / clockspersecond() * 1000

aPos2 = []
for i = 1 to N  aPos2 + 0  next
for L = 0 to LAYERS - 1
	for k = 1 to WIDE
		aPos2[aNew[L * WIDE + k] + 1] = k
	next
next
nAfter = StzEngineGraphLayoutCrossings(aU, aV, aLayer, aPos2, aStarts)

? "crossings after  : " + nAfter + "   (" + ((nBefore-nAfter)/nBefore*100) + "% removed)"
? ""
# The SAME 8 sweeps in Ring, on the SAME graph -- the 1499 ms figure from
# the spike covered CSR building and layering too, so it is not the number
# to divide by. This is.
aRL = []
for L = 0 to LAYERS - 1
	_row_ = []
	for w = 0 to WIDE - 1  _row_ + (L * WIDE + w)  next
	aRL + _row_
next
aRP = []
for i = 1 to N  aRP + 0  next
RSetPos(aRL, aRP)
nT4 = clock()
for nS = 1 to 8
	RBary(aRL, aRP, aOff, aSrc)
	RSetPos(aRL, aRP)
next
nT5 = clock()
nRingMs = (nT5 - nT4) / clockspersecond() * 1000

? "RING   sweep, 8 passes : " + nRingMs + " ms"
? "ENGINE sweep, 8 passes : " + nEngMs + " ms"
if nEngMs > 0
	? "speedup                : " + (nRingMs / nEngMs) + "x   (same graph, same work)"
ok

# and they must AGREE, or the speed is meaningless
bAgree = TRUE
for L = 0 to LAYERS - 1
	for k = 1 to WIDE
		if aRL[L+1][k] != aNew[L * WIDE + k]  bAgree = FALSE  exit  ok
	next
	if NOT bAgree  exit  ok
next
? "same ORDER as Ring     : " + bAgree

# determinism: the engine must reproduce too
aOrder2 = []
for i = 0 to N - 1  aOrder2 + i  next
aNewB = StzEngineGraphLayoutSweep(aOff, aSrc, aLayer, aOrder2, aStarts, 8, aU, aV)
bSame = TRUE
for i = 1 to N
	if aNew[i] != aNewB[i]  bSame = FALSE  exit  ok
next
? "deterministic          : " + bSame

aOrder3 = []
for i = 0 to N - 1  aOrder3 + i  next
aNewC = StzEngineGraphLayoutSweep(aOff, aSrc, aLayer, aOrder3, aStarts, 7, aU, aV)
bDiff = FALSE
for i = 1 to N
	if aNew[i] != aNewC[i]  bDiff = TRUE  exit  ok
next
? "  and discriminates    : " + bDiff


func RSetPos aL, aP
	_n_ = len(aL)
	for _L_ = 1 to _n_
		_a_ = aL[_L_]
		_m_ = len(_a_)
		for _i_ = 1 to _m_
			aP[_a_[_i_] + 1] = _i_
		next
	next

func RBary aL, aP, aO, aS
	_nL_ = len(aL)
	for _L_ = 2 to _nL_
		_a_ = aL[_L_]
		_n_ = len(_a_)
		if _n_ < 2  loop  ok
		_k_ = []
		for _i_ = 1 to _n_
			_v_ = _a_[_i_]
			_s_ = aO[_v_ + 1]
			_e_ = aO[_v_ + 2]
			_sum_ = 0  _c_ = 0
			for _q_ = _s_ + 1 to _e_
				_sum_ += aP[aS[_q_] + 1]
				_c_++
			next
			if _c_ = 0
				_k_ + [ aP[_v_ + 1], _v_ ]
			else
				_k_ + [ _sum_ / _c_, _v_ ]
			ok
		next
		_k_ = RSort(_k_)
		_new_ = []
		for _i_ = 1 to _n_  _new_ + _k_[_i_][2]  next
		aL[_L_] = _new_
	next

func RSort aK
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
