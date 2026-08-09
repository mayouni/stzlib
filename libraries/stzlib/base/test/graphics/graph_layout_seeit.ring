load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	SEE THE SWEEP WORK

	A number saying "crossings fell 44%" is a claim. This draws the same
	graph before and after so the claim is inspectable.

	The graph is a BAND: every node links to its neighbours one layer down,
	so a near-crossing-free order exists. It is then deliberately scrambled.
	A working sweep should pull the tangle back into a clean band; a broken
	one cannot fake that.

	Run:  ring graph_layout_seeit.ring
---------------------------------------------------------------------------*/

decimals(2)

LAYERS = 26
WIDE = 34
N = LAYERS * WIDE

# band edges: w -> {w-1, w, w+1} in the next layer
aU = []  aV = []
for L = 0 to LAYERS - 2
	for w = 0 to WIDE - 1
		for k = -1 to 1
			nT = w + k
			if nT >= 0 and nT < WIDE
				aU + (L * WIDE + w)
				aV + ((L + 1) * WIDE + nT)
			ok
		next
	next
next
? "graph : " + N + " nodes, " + len(aU) + " edges, " + LAYERS + " layers"

aLayer = []
for i = 1 to N  aLayer + floor((i - 1) / WIDE)  next

aStarts = []
for L = 0 to LAYERS  aStarts + (L * WIDE)  next

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

# SCRAMBLE the starting order inside every layer
aOrder = []
for L = 0 to LAYERS - 1
	for w = 0 to WIDE - 1
		aOrder + (L * WIDE + ((w * 37 + L * 11) % WIDE))
	next
next
aPosBefore = PosOf(aOrder, LAYERS, WIDE, N)
nBefore = StzEngineGraphLayoutCrossings(aU, aV, aLayer, aPosBefore, aStarts)

nT0 = clock()
aAfter = StzEngineGraphLayoutSweep(aOff, aSrc, aLayer, aOrder, aStarts, 16, aU, aV)
nT1 = clock()
aPosAfter = PosOf(aAfter, LAYERS, WIDE, N)
nAfter = StzEngineGraphLayoutCrossings(aU, aV, aLayer, aPosAfter, aStarts)

? "crossings : " + nBefore + "  ->  " + nAfter +
  "   (" + ((nBefore - nAfter) / nBefore * 100) + "% removed)"
? "sweep     : " + ((nT1-nT0)/clockspersecond()*1000) + " ms for 16 passes"

Draw("graph_sweep_before.png", aPosBefore, aU, aV, aLayer, LAYERS, WIDE,
     "SCRAMBLED  --  " + nBefore + " crossings")
Draw("graph_sweep_after.png", aPosAfter, aU, aV, aLayer, LAYERS, WIDE,
     "AFTER 16 SWEEPS  --  " + nAfter + " crossings")
? "wrote graph_sweep_before.png and graph_sweep_after.png"

#---------------------------------------------------------------------------

func PosOf aOrder, nL, nW, n
	_p_ = []
	for _i_ = 1 to n  _p_ + 0  next
	for _L_ = 0 to nL - 1
		for _k_ = 1 to nW
			_p_[aOrder[_L_ * nW + _k_] + 1] = _k_
		next
	next
	return _p_

func Draw cName, aPos, aU, aV, aLayer, nL, nW, cTitle
	_W_ = 1200  _H_ = 760
	_oC_ = new stzCanvas(_W_, _H_)
	_oC_.SetBackground("#0A0E1A")
	_oC_.AddGradientRect(0, 0, _W_, _H_, "#0A0E1A", "#141B30", TRUE)

	_rowH_ = (_H_ - 120) / nL
	_ne_ = len(aU)
	for _e_ = 1 to _ne_
		_a_ = XY(aU[_e_], aPos, aLayer, _W_, _rowH_, nW)
		_b_ = XY(aV[_e_], aPos, aLayer, _W_, _rowH_, nW)
		_oC_.AddLineQ(_a_[1], _a_[2], _b_[1], _b_[2]).Stroke("#4A7BD455", 1)
	next
	for _i_ = 0 to nL * nW - 1
		_a_ = XY(_i_, aPos, aLayer, _W_, _rowH_, nW)
		_oC_.AddCircleQ(_a_[1], _a_[2], 3).
			Fill(StzColorFromHSL((aLayer[_i_+1] * 13) % 360, 70, 62))
	next

	_cF_ = "C:/Windows/Fonts/segoeui.ttf"
	if fexists(_cF_)
		_oF_ = new stzFont(_cF_)
		_oC_.AddTextQ(cTitle, 30, _H_ - 34).SetFontQ(_oF_, 24).Color("#EAF0FF")
	ok
	_oC_.ToPNG(cName)

func XY nId, aPos, aLayer, W, rowH, nW
	_L_ = aLayer[nId + 1]
	_p_ = aPos[nId + 1]
	return [ 40 + (W - 80) * _p_ / (nW + 1), 40 + _L_ * rowH ]
