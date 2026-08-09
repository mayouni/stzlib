load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG1 STRESS -- eight topologies, because one graph proves one graph

	Every measurement so far used a band or a uniform scatter. Both are
	regular, both are the same width at every layer, and both are exactly
	the shape a layered sweep is happiest with. That is a thin basis for
	calling a foundation robust.

	Each scenario below stresses something the others cannot:

	  band          a good order EXISTS -- can the sweep find it
	  tree          widths DOUBLE per layer; the top is one node
	  dense         no good order -- the crossing floor
	  deep narrow   60 layers of 6 -- propagation depth
	  wide shallow  4 layers of 200 -- sort width
	  disconnected  three graphs sharing a drawing
	  spanning      edges that SKIP layers -- the case the sweep ignores
	  degenerate    empty and single-node layers -- the crash surface

	For every one: does it run, does it reproduce, and do crossings fall or
	at least not RISE. A sweep that makes a picture worse on some topology
	is not a foundation, however good its average.

	Run:  ring graph_layout_stress.ring
---------------------------------------------------------------------------*/

decimals(2)

aNames = [ "band", "tree", "dense", "deep-narrow", "wide-shallow",
           "disconnected", "spanning", "degenerate" ]
nPass = 0  nFail = 0
aReport = []

nS = len(aNames)
for nI = 1 to nS
	aG = MakeGraph(nI)
	cN = aNames[nI]
	aU = aG[1]  aV = aG[2]  aLayer = aG[3]  nN = aG[4]

	aGrp = GroupByLayer(aLayer, nN)
	aOrder = aGrp[1]
	aStarts = aGrp[2]

	if len(aU) = 0
		aReport + [ cN, nN, 0, 0, 0, "no edges", TRUE ]
		nPass++
		loop
	ok

	aCsr = InCsr(aU, aV, nN)
	aPos0 = PosOf(aOrder, aStarts, nN)
	nB = StzEngineGraphLayoutCrossings(aU, aV, aLayer, aPos0, aStarts)

	nT0 = clock()
	aAfter = StzEngineGraphLayoutSweep(aCsr[1], aCsr[2], aLayer, aOrder, aStarts, 12, aU, aV)
	nT1 = clock()
	nMs = (nT1 - nT0) / clockspersecond() * 1000

	aPos1 = PosOf(aAfter, aStarts, nN)
	nA = StzEngineGraphLayoutCrossings(aU, aV, aLayer, aPos1, aStarts)

	# determinism on THIS topology, not just on the band
	aOrder2 = GroupByLayer(aLayer, nN)[1]
	aAfter2 = StzEngineGraphLayoutSweep(aCsr[1], aCsr[2], aLayer, aOrder2, aStarts, 12, aU, aV)
	bDet = TRUE
	for k = 1 to nN
		if aAfter[k] != aAfter2[k]  bDet = FALSE  exit  ok
	next

	# the property that matters: a sweep must never make a picture WORSE
	bNoWorse = (nA <= nB)
	bOk = bDet and bNoWorse
	if bOk  nPass++  else  nFail++  ok

	cNote = ""
	if NOT bDet       cNote += "NOT DETERMINISTIC "  ok
	if NOT bNoWorse   cNote += "CROSSINGS ROSE "     ok
	if cNote = ""     cNote = "ok"                   ok

	aReport + [ cN, nN, nB, nA, nMs, cNote, bOk ]

	if nI = 1 or nI = 2 or nI = 6 or nI = 7
		Draw("stress_" + cN + ".png", aPos1, aU, aV, aLayer, aStarts, nN,
		     upper(cN) + "  --  " + nB + " -> " + nA + " crossings")
	ok
next

? "=============================================================================="
? " topology        nodes    before      after     ms   verdict"
? "=============================================================================="
nR = len(aReport)
for i = 1 to nR
	a = aReport[i]
	? " " + PadR(a[1], 15) + PadL("" + a[2], 5) + PadL("" + a[3], 10) +
	  PadL("" + a[4], 10) + PadL("" + a[5], 7) + "   " + a[6]
next
? "=============================================================================="
? " " + nPass + " topologies clean, " + nFail + " with a problem"
? "=============================================================================="

#---------------------------------------------------------------------------

func MakeGraph nWhich
	_u_ = []  _v_ = []  _lay_ = []  _n_ = 0

	switch nWhich
	on 1     # band: a near-crossing-free order exists, started scrambled
		_L_ = 26  _W_ = 34
		_n_ = _L_ * _W_
		for i = 1 to _n_  _lay_ + floor((i - 1) / _W_)  next
		for L = 0 to _L_ - 2
			for w = 0 to _W_ - 1
				for k = -1 to 1
					_t_ = w + k
					if _t_ >= 0 and _t_ < _W_
						_u_ + (L * _W_ + w)
						_v_ + ((L + 1) * _W_ + _t_)
					ok
				next
			next
		next

	on 2     # tree: layer widths DOUBLE, and layer 0 holds one node
		_D_ = 9
		_n_ = pow(2, _D_) - 1
		for i = 1 to _n_
			_d_ = 0  _c_ = i
			while _c_ > 1
				_c_ = floor(_c_ / 2)
				_d_++
			end
			_lay_ + _d_
		next
		for i = 2 to _n_
			_u_ + (floor(i / 2) - 1)
			_v_ + (i - 1)
		next

	on 3     # dense scatter: no good order to find
		_L_ = 20  _W_ = 40
		_n_ = _L_ * _W_
		for i = 1 to _n_  _lay_ + floor((i - 1) / _W_)  next
		for L = 0 to _L_ - 2
			for w = 0 to _W_ - 1
				for k = 1 to 6
					_u_ + (L * _W_ + w)
					_v_ + ((L + 1) * _W_ + ((w * 17 + k * 23 + L * 7) % _W_))
				next
			next
		next

	on 4     # deep and narrow: 60 layers of 6
		_L_ = 60  _W_ = 6
		_n_ = _L_ * _W_
		for i = 1 to _n_  _lay_ + floor((i - 1) / _W_)  next
		for L = 0 to _L_ - 2
			for w = 0 to _W_ - 1
				for k = 1 to 2
					_u_ + (L * _W_ + w)
					_v_ + ((L + 1) * _W_ + ((w + k) % _W_))
				next
			next
		next

	on 5     # wide and shallow: 4 layers of 200 -- the sort's width case
		_L_ = 4  _W_ = 200
		_n_ = _L_ * _W_
		for i = 1 to _n_  _lay_ + floor((i - 1) / _W_)  next
		for L = 0 to _L_ - 2
			for w = 0 to _W_ - 1
				for k = 1 to 3
					_u_ + (L * _W_ + w)
					_v_ + ((L + 1) * _W_ + ((w * 31 + k * 13) % _W_))
				next
			next
		next

	on 6     # three disconnected bands sharing one drawing
		_L_ = 14  _W_ = 12  _C_ = 3
		_n_ = _L_ * _W_ * _C_
		for i = 1 to _n_  _lay_ + floor(((i - 1) % (_L_ * _W_)) / _W_)  next
		for c = 0 to _C_ - 1
			_base_ = c * _L_ * _W_
			for L = 0 to _L_ - 2
				for w = 0 to _W_ - 1
					for k = -1 to 1
						_t_ = w + k
						if _t_ >= 0 and _t_ < _W_
							_u_ + (_base_ + L * _W_ + w)
							_v_ + (_base_ + (L + 1) * _W_ + _t_)
						ok
					next
				next
			next
		next

	on 7     # edges that SKIP layers -- the case the barycentre ignores
		_L_ = 20  _W_ = 20
		_n_ = _L_ * _W_
		for i = 1 to _n_  _lay_ + floor((i - 1) / _W_)  next
		for L = 0 to _L_ - 2
			for w = 0 to _W_ - 1
				# one ordinary edge, one that jumps three layers
				_u_ + (L * _W_ + w)
				_v_ + ((L + 1) * _W_ + ((w + 1) % _W_))
				if L + 3 < _L_
					_u_ + (L * _W_ + w)
					_v_ + ((L + 3) * _W_ + ((w * 7) % _W_))
				ok
			next
		next

	on 8     # degenerate: single-node and empty layers, isolated nodes
		_n_ = 30
		_lay_ = [ 0, 1,1,1, 2, 3,3,3,3,3, 4, 5,5, 6,6,6,6, 7, 8,8,8,8,8,8, 9,9, 10, 11,11, 12 ]
		# a couple of nodes deliberately get NO predecessor at all
		_u_ + 0   _v_ + 1
		_u_ + 0   _v_ + 2
		_u_ + 1   _v_ + 4
		_u_ + 4   _v_ + 5
		_u_ + 4   _v_ + 6
		_u_ + 5   _v_ + 10
		_u_ + 10  _v_ + 11
		_u_ + 11  _v_ + 13
		_u_ + 13  _v_ + 17
		_u_ + 17  _v_ + 18
		_u_ + 18  _v_ + 24
		_u_ + 24  _v_ + 26
		_u_ + 26  _v_ + 27
		_u_ + 27  _v_ + 29
	off

	return [ _u_, _v_, _lay_, _n_ ]

# Group node ids by layer into one contiguous array, and record where each
# layer starts. The engine requires exactly this shape.
func GroupByLayer aLayer, n
	_max_ = 0
	for i = 1 to n
		if aLayer[i] > _max_  _max_ = aLayer[i]  ok
	next
	_buckets_ = []
	for L = 0 to _max_  _buckets_ + []  next
	for i = 1 to n
		_buckets_[aLayer[i] + 1] + (i - 1)
	next
	# scramble inside each layer so there is something to fix
	_order_ = []
	_starts_ = []
	_acc_ = 0
	for L = 1 to _max_ + 1
		_starts_ + _acc_
		_b_ = _buckets_[L]
		_m_ = len(_b_)
		if _m_ > 1
			_sc_ = []
			for _k_ = 0 to _m_ - 1
				_sc_ + _b_[((_k_ * 37 + L * 11) % _m_) + 1]
			next
			# a stride that shares a factor with _m_ would repeat ids, so
			# fall back to the plain order rather than emit a broken layer
			if HasDup(_sc_)
				_sc_ = _b_
			ok
			_b_ = _sc_
		ok
		for _k_ = 1 to _m_
			_order_ + _b_[_k_]
		next
		_acc_ += _m_
	next
	_starts_ + _acc_
	return [ _order_, _starts_ ]

func HasDup aX
	_n_ = len(aX)
	for _i_ = 1 to _n_ - 1
		for _j_ = _i_ + 1 to _n_
			if aX[_i_] = aX[_j_]  return TRUE  ok
		next
	next
	return FALSE

func PosOf aOrder, aStarts, n
	_p_ = []
	for _i_ = 1 to n  _p_ + 0  next
	_nl_ = len(aStarts) - 1
	for _L_ = 1 to _nl_
		_pp_ = 1
		for _i_ = aStarts[_L_] + 1 to aStarts[_L_ + 1]
			_p_[aOrder[_i_] + 1] = _pp_
			_pp_++
		next
	next
	return _p_

func InCsr aU, aV, n
	_cnt_ = []
	for _i_ = 1 to n  _cnt_ + 0  next
	_ne_ = len(aU)
	for _e_ = 1 to _ne_  _cnt_[aV[_e_] + 1]++  next
	_off_ = []  _acc_ = 0
	for _i_ = 1 to n  _off_ + _acc_  _acc_ += _cnt_[_i_]  next
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

func Draw cName, aPos, aU, aV, aLayer, aStarts, n, cTitle
	_W_ = 1200  _H_ = 720
	_oC_ = new stzCanvas(_W_, _H_)
	_oC_.SetBackground("#0A0E1A")
	_oC_.AddGradientRect(0, 0, _W_, _H_, "#0A0E1A", "#141B30", TRUE)
	_nl_ = len(aStarts) - 1
	_rowH_ = (_H_ - 110) / _nl_
	_ne_ = len(aU)
	for _e_ = 1 to _ne_
		_a_ = XY(aU[_e_], aPos, aLayer, aStarts, _W_, _rowH_)
		_b_ = XY(aV[_e_], aPos, aLayer, aStarts, _W_, _rowH_)
		_oC_.AddLineQ(_a_[1], _a_[2], _b_[1], _b_[2]).Stroke("#4A7BD455", 1)
	next
	for _i_ = 0 to n - 1
		_a_ = XY(_i_, aPos, aLayer, aStarts, _W_, _rowH_)
		_oC_.AddCircleQ(_a_[1], _a_[2], 3).
			Fill(StzColorFromHSL((aLayer[_i_+1] * 15) % 360, 72, 62))
	next
	_cF_ = "C:/Windows/Fonts/segoeui.ttf"
	if fexists(_cF_)
		_oF_ = new stzFont(_cF_)
		_oC_.AddTextQ(cTitle, 28, _H_ - 30).SetFontQ(_oF_, 22).Color("#EAF0FF")
	ok
	_oC_.ToPNG(cName)

func XY nId, aPos, aLayer, aStarts, W, rowH
	_L_ = aLayer[nId + 1]
	_w_ = aStarts[_L_ + 2] - aStarts[_L_ + 1]
	_p_ = aPos[nId + 1]
	return [ 40 + (W - 80) * _p_ / (_w_ + 1), 34 + _L_ * rowH ]

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_

func PadL c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ = " " + _s_  end
	return _s_
