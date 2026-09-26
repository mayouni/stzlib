# PROBE TK6, the memory half, as its own kill criterion: a memory of which
# re-expression worked on which table shape ships only if its suggestion
# beats "evaluate the whole ladder and take the best slope" on held-out
# tables. Forty training tables and twenty held-out, each made additive by a
# known power of the ladder; the memory keys on the one-number shape the
# fixed policy also reads first (the non-additivity slope at power 1) and
# suggests the power of the nearest remembered shape.
load "../../stzBase.ring"
nTmSeed = 777
aPowers = StzTukeyLadderPowers()
aTrain = []
for k = 1 to 40
	p = aPowers[(k - 1) % len(aPowers) + 1]
	aT = _TmTable(p)
	oRe = StzTukeyReexpressionQ(aT)
	aBest = oRe.Recommend()
	aTrain + [ oRe.NonAdditivity()[:slope], aBest[:power], p ]
next
nHit = 0
nSame = 0
nRegret = 0
nMaxRegret = 0
nHeld = 20
for k = 1 to nHeld
	p = aPowers[(k * 7) % len(aPowers) + 1]
	aT = _TmTable(p)
	oRe = StzTukeyReexpressionQ(aT)
	aBest = oRe.Recommend()
	nS = oRe.NonAdditivity()[:slope]
	# THE MEMORY: the nearest remembered shape's power
	nD = 0  nSug = 1
	for i = 1 to len(aTrain)
		d = fabs(aTrain[i][1] - nS)
		if i = 1 or d < nD  nD = d  nSug = aTrain[i][2]  ok
	next
	if nSug = aBest[:power]  nHit++  ok
	if nSug = p  nSame++  ok
	rS = oRe.Rung(nSug)
	rB = oRe.Rung(aBest[:power])
	nReg = fabs(rS[2]) - fabs(rB[2])
	nRegret += nReg
	if nReg > nMaxRegret  nMaxRegret = nReg  ok
next
? "held-out tables: " + nHeld
? "  the memory suggests the ladder's own best power on " + nHit + "/" + nHeld + ", the generating power on " + nSame + "/" + nHeld
? "  regret in |slope| when it differs: mean " + _FfNum(nRegret / nHeld, 4) + ", worst " + _FfNum(nMaxRegret, 4)
# the ladder's own hit rate against the generating power, for scale
nLad = 0
for k = 1 to nHeld
	p = aPowers[(k * 7) % len(aPowers) + 1]
	if StzTukeyReexpressionQ(_TmTable(p)).Recommend()[:power] = p  nLad++  ok
next
? "  the fixed ladder recovers the generating power on " + nLad + "/" + nHeld
# THE COST the memory would save: the whole ladder against one polish
for aDim in [ [ 6, 5 ], [ 60, 50 ], [ 200, 100 ] ]
	aBig = _TmBig(aDim[1], aDim[2])
	t0 = StzEngineWatchTimestampMs()
	StzTukeyReexpressionQ(aBig).Ladder()
	tL = StzEngineWatchTimestampMs() - t0
	t0 = StzEngineWatchTimestampMs()
	oF = StzTukeyFitQ(aBig)
	oF.Polish()
	tP = StzEngineWatchTimestampMs() - t0
	? "  " + aDim[1] + " x " + aDim[2] + ": the whole ladder " + _FfNum(tL, 2) + " ms, one polish " + _FfNum(tP, 2) + " ms"
next

func _TmU
	nTmSeed = (nTmSeed * 16807) % 2147483647
	return nTmSeed / 2147483647

# a 6 x 5 additive table with seeded noise on a positive scale, then UNDONE by
# the power p, so that re-expressing with p makes it additive again
func _TmTable p
	_a_ = []
	for _i_ = 1 to 6
		_aRow_ = []
		for _j_ = 1 to 5
			_v_ = 2 + 0.4 * _i_ + 0.3 * _j_ + (_TmU() - 0.5) * 0.1
			if p = 0
				_v_ = exp(_v_)
			else
				_v_ = pow(_v_, 1 / p)
			ok
			_aRow_ + _v_
		next
		_a_ + _aRow_
	next
	return _a_

func _TmBig r, c
	_a_ = []
	for _i_ = 1 to r
		_aRow_ = []
		for _j_ = 1 to c
			_aRow_ + exp(1 + 0.02 * _i_ + 0.03 * _j_ + (_TmU() - 0.5) * 0.1)
		next
		_a_ + _aRow_
	next
	return _a_
