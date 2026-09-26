# THE TUKEY TIER'S GATE -- TK1: the resistant core, pinned against the
# oracles the plan names (SOFTANZA_TUKEY_PLAN.md 6), and resistant where
# its classical sibling is not (the negative every positive needs).
#
#   1. fourths against percentile quartiles at every n mod 4, by hand; the
#      convention named on every summary
#   2. the letter-value ladder on nine values
#   3. the fences under both conventions, and the values beyond them
#   4. median polish: R's ?medpolish example to 1e-9, Data = Fit + Residual,
#      and one cell dragged to 1e9 moving the resistant effects by less than
#      a fourth-spread while the mean-based effects move by millions
#   5. the resistant line: an exact line recovered, one wild point ignored
#      where least squares follows it
#   6. MAD, biweight and trimean on hand examples, and their resistance
#   7. the cost, printed: a polish of 100 x 100 through the seam
#
# Run from this folder: ring tukey_narrated.ring

load "../../stzBase.ring"

nOk = 0
nBad = 0
nSecClock = 0
? "=============================================================="
? " TUKEY GATE -- the mathematics plane, M4 / TK1: the resistant core"
? "=============================================================="

sec("-- 1. FOURTHS ARE NOT QUARTILES, AND THE SUMMARY SAYS WHICH IT USED -----")

# by hand: d(M) = (n+1)/2, d(F) = (floor(d(M)) + 1)/2, counted from each end
aCases = [ [ [ 1, 2, 3, 4 ], 1.5, 3.5 ], [ [ 1, 2, 3, 4, 5 ], 2, 4 ],
           [ [ 1, 2, 3, 4, 5, 6 ], 2, 5 ], [ [ 1, 2, 3, 4, 5, 6, 7 ], 2.5, 5.5 ] ]
for i = 1 to len(aCases)
	aF = StzTukeySummaryQ(aCases[i][1]).Fourths()
	chk("n = " + len(aCases[i][1]) + " (n mod 4 = " + (len(aCases[i][1]) % 4) + "): fourths " + @@(aF) + " by hand " + aCases[i][2] + " and " + aCases[i][3],
		fabs(aF[1] - aCases[i][2]) < 0.000000001 and fabs(aF[2] - aCases[i][3]) < 0.000000001)
next
oS = StzTukeySummaryQ([ 2, 4, 4, 5, 7, 9, 12, 25 ])
aF = oS.Fourths()
aQ = oS.Quartiles()
chk("the library's box-plot sample: fourths 4 and 10.5, percentile quartiles 4 and 9.75  [" + @@(aF) + " / " + @@(aQ) + "]",
	fabs(aF[2] - 10.5) < 0.000000001 and fabs(aQ[2] - 9.75) < 0.000000001)
chk("the gap is 0.75 on a fourth-spread of 6.5: 0.115 fourth-spreads, above the 0.1 the plan set, so both conventions ship",
	fabs((aF[2] - aQ[2]) / (aF[2] - aF[1]) - 0.1154) < 0.001)
chk("the summary names its convention: " + oS.Why(), StzFindFirst("Tukey's fourths", oS.Why()) > 0)
oS.SetConvention(:Percentile)
chk("...and the other when switched: " + oS.Why(), StzFindFirst("percentile quartiles", oS.Why()) > 0 and fabs(oS.Hinges()[2] - 9.75) < 0.000000001)
chk("a convention that is neither is refused by name", _TkRefuses("convention"))
chk("the median is the same under both: 6", oS.Median() = 6)

sec("-- 2. THE LETTER-VALUE LADDER --------------------------------------------")

oN = StzTukeySummaryQ([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
aL = oN.LetterValues(4)
chk("nine values: M at depth 5, F at depth 3, E at depth 2, D at depth 1.5  [" + @@(aL) + "]",
	len(aL) = 4 and aL[1][1] = "M" and aL[1][2] = 5 and aL[2][1] = "F" and aL[2][2] = 3 and aL[3][1] = "E" and aL[3][2] = 2 and aL[4][2] = 1.5)
chk("F is 3 and 7, mid 5, spread 4", aL[2][3] = 3 and aL[2][4] = 7 and aL[2][5] = 5 and aL[2][6] = 4)
chk("E is 2 and 8", aL[3][3] = 2 and aL[3][4] = 8)
chk("the mids are all 5 on symmetric data -- the ladder's shape verdict in the making", aL[1][5] = 5 and aL[3][5] = 5 and aL[4][5] = 5)
chk("the trimean of 1..9 is 5", oN.Trimean() = 5)

sec("-- 3. THE FENCES, UNDER EACH CONVENTION, AND WHAT LIES BEYOND ------------")

oB = StzTukeySummaryQ([ 2, 4, 4, 5, 7, 9, 12, 25 ])
aOut = oB.OutsideFences()
# by hand under fourths: 4 - 1.5*6.5 = -5.75 and 10.5 + 1.5*6.5 = 20.25
chk("outside fences under fourths, by hand -5.75 and 20.25  [" + @@(aOut) + "]", fabs(aOut[1] + 5.75) < 0.000000001 and fabs(aOut[2] - 20.25) < 0.000000001)
aFar = oB.FarOutFences()
chk("far-out fences under fourths, by hand -15.5 and 30", fabs(aFar[1] + 15.5) < 0.000000001 and fabs(aFar[2] - 30) < 0.000000001)
chk("25 lies outside and not far out", @@(oB.Outside()) = "[ 25 ]" and len(oB.FarOut()) = 0)
oB.SetConvention(:Percentile)
aOutP = oB.OutsideFences()
# by hand under percentile quartiles: 4 - 1.5*5.75 = -4.625 and 9.75 + 1.5*5.75 = 18.375
chk("under percentile quartiles the outside fences are -4.625 and 18.375 -- stzDataSet's numbers  [" + @@(aOutP) + "]",
	fabs(aOutP[1] + 4.625) < 0.000000001 and fabs(aOutP[2] - 18.375) < 0.000000001)
chk("...and stzDataSet agrees on its own convention", @@(StzDataSetQ([ 2, 4, 4, 5, 7, 9, 12, 25 ]).Outliers()) = "[ 25 ]")
chk("a fence multiplier that is not positive is refused", _TkRefuses("fence"))

sec("-- 4. MEDIAN POLISH: R'S OWN EXAMPLE, THE CONTRACT, AND RESISTANCE -------")

# R: deaths <- rbind(c(14,15,14), c(7,4,7), c(8,2,10), c(15,9,10), c(0,2,0)); medpolish(deaths)
# Overall 8; row 6 -1 0 2 -8; column 0 -1 0; residuals 0 2 0 / 0 -2 0 / 0 -5 2 / 5 0 0 / 0 3 0
# (reproduced by an independent NumPy implementation, scratchpad/tk0/medpolish_np.py)
aDeaths = [ [ 14, 15, 14 ], [ 7, 4, 7 ], [ 8, 2, 10 ], [ 15, 9, 10 ], [ 0, 2, 0 ] ]
oF = StzTukeyFitQ(aDeaths)
chk("before the polish the fit says so: " + oF.Why(), StzFindFirst("not yet polished", oF.Why()) > 0)
chk("...and refuses to hand out a common value it never computed", _TkRefuses("unpolished"))
oF.Polish()
chk("R's overall 8", fabs(oF.Common() - 8) < 0.000000001)
chk("R's row effects 6 -1 0 2 -8  [" + @@(oF.Effects(:Row)) + "]", _TkClose(oF.Effects(:Row), [ 6, -1, 0, 2, -8 ]))
chk("R's column effects 0 -1 0", _TkClose(oF.Effects(:Col), [ 0, -1, 0 ]))
aR = oF.Residuals()
chk("R's residual table, cell for cell", _TkClose(aR[1], [ 0, 2, 0 ]) and _TkClose(aR[2], [ 0, -2, 0 ]) and _TkClose(aR[3], [ 0, -5, 2 ]) and _TkClose(aR[4], [ 5, 0, 0 ]) and _TkClose(aR[5], [ 0, 3, 0 ]))
chk("it converged, and says in how many sweeps: " + oF.Why(), oF.IsConverged() and oF.Sweeps() >= 1)
chk("THE CONTRACT: Data = Fit + Residual holds to 1e-9 over every cell  [" + oF.Check() + "]", oF.Check() < 0.000000001)
chk("the fitted value of (4, 1) is common + row + col = 8 + 2 + 0", fabs(oF.Fitted(4, 1) - 10) < 0.000000001)
chk("a ragged table is refused", _TkRefuses("ragged"))

# RESISTANCE (plan 2.3): drag one cell to 1e9 -- the polish's effects stay
# within one fourth-spread of the clean ones; the MEAN-based effects,
# computed here in Ring as the classical additive decomposition, move by
# millions. The same table, two centres, and only one of them is a fit.
aWild = [ [ 14, 15, 14 ], [ 7, 4, 7 ], [ 8, 1000000000, 10 ], [ 15, 9, 10 ], [ 0, 2, 0 ] ]
oW = StzTukeyFitQ(aWild)
oW.Polish()
# the bar is one fourth-spread OF THE DATA (plan 2.3): the clean table's
# fifteen values have fourths 3 and 12, so the spread is 9
aFlat = []
for i = 1 to 5  for j = 1 to 3  aFlat + aDeaths[i][j]  next  next
nSpread = StzTukeySummaryQ(aFlat).FourthSpread()
chk("the clean table's fourth-spread is 9 (fourths 3 and 12 of the fifteen values)", nSpread = 9)
nMoveRow = 0
aR0 = oF.Effects(:Row)
aR1 = oW.Effects(:Row)
for i = 1 to 5
	if fabs(aR1[i] - aR0[i]) > nMoveRow  nMoveRow = fabs(aR1[i] - aR0[i])  ok
next
chk("one cell at 1e9: the median-polish row effects move by at most " + _FfNum(nMoveRow, 4) + " -- the wild row's median went from 8 to 10 -- within one fourth-spread of the data (" + _FfNum(nSpread, 4) + ")", nMoveRow < nSpread)
chk("...and the common value moves by " + _FfNum(fabs(oW.Common() - 8), 4) + ", also within one fourth-spread  [common " + _FfNum(oW.Common(), 4) + "]", fabs(oW.Common() - 8) < nSpread)
aMean0 = _TkMeanRowEffects(aDeaths)
aMean1 = _TkMeanRowEffects(aWild)
nMoveMean = 0
for i = 1 to 5
	if fabs(aMean1[i] - aMean0[i]) > nMoveMean  nMoveMean = fabs(aMean1[i] - aMean0[i])  ok
next
chk("NEGATIVE: the mean-based row effects move by " + _FfNum(nMoveMean, 0) + " -- hundreds of millions -- on the same table", nMoveMean > 100000000)
chk("the wild cell's own residual carries the damage: " + _FfNum(oW.Residual(3, 2), 0), oW.Residual(3, 2) > 900000000)

sec("-- 4b. THE ONE-WAY FIT: GROUPS, EFFECTS, AND THE SAME CONTRACT ------------")

# three groups by hand: medians 4, 11 (the mean of 10 and 12) and 7 -> common 7, effects -3, 4, 0
oG = StzTukeyOneWayQ([ [ 2, 4, 6 ], [ 9, 10, 12, 100 ], [ 7 ] ])
oG.Polish()
chk("group medians 4, 11 and 7: the common value is their median, 7", oG.Common() = 7)
chk("the effects are -3, 4 and 0  [" + @@(oG.Effects()) + "]", _TkClose(oG.Effects(), [ -3, 4, 0 ]))
chk("the residual of the wild 100 in group 2 is 89 -- it stays in its cell and moves the group median by one", oG.Residuals()[2][4] = 89)
chk("THE CONTRACT holds group by group: " + oG.Why(), oG.Check() < 0.000000001)
chk("one group is refused: a one-way fit compares", _TkRefuses("oneway"))

sec("-- 5. THE RESISTANT LINE, WHERE LEAST SQUARES FOLLOWS THE WILD POINT -----")

aX = [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
aY = []
for i = 1 to 9  aY + (3 * aX[i] + 2)  next
oL = StzTukeyLineQ(aX, aY)
oL.Fit(5)
chk("an exact line y = 2 + 3x is recovered to 1e-9: " + oL.Why(), fabs(oL.Slope() - 3) < 0.000000001 and fabs(oL.Intercept() - 2) < 0.000000001)
# the LAST point is dragged, not a middle one: a point at the centre of x has
# no leverage on any slope, and a negative that cannot fail is not a negative
aY[9] = 1000000
oL2 = StzTukeyLineQ(aX, aY)
oL2.Fit(5)
chk("the last point dragged to 1e6: the resistant slope stays 3 -- the right group's median y is still 26  [" + _FfNum(oL2.Slope(), 6) + "]", fabs(oL2.Slope() - 3) < 0.000000001)
cLS = StzEngineStatsRegression(StzEngineStatsCreate(aX), StzEngineStatsCreate(aY))
nLS = 0 + StzSplit(cLS, ",")[1]
chk("NEGATIVE: least squares follows it -- its slope is " + _FfNum(nLS, 0) + " on the same points", fabs(nLS - 3) > 1000)
chk("fewer than three points are refused", _TkRefuses("line"))

sec("-- 6. RESISTANT SCALE: MAD, BIWEIGHT, AND ONE WILD VALUE -----------------")

oM = StzTukeySummaryQ([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
chk("the MAD of 1..9 is 2, by hand (deviations 4 3 2 1 0 1 2 3 4, median 2)", oM.Mad() = 2)
nBw = oM.Biweight(9)
chk("the biweight midvariance is positive and finite  [" + _FfNum(nBw, 4) + "]", nBw > 0 and nBw < 100)
oM2 = StzTukeySummaryQ([ 1, 2, 3, 4, 5, 6, 7, 8, 1000000000 ])
chk("one value at 1e9: the MAD stays 2", oM2.Mad() = 2)
chk("...and the biweight midvariance stays within a factor of two of the clean one  [" + _FfNum(oM2.Biweight(9), 4) + "]", oM2.Biweight(9) < 2 * nBw and oM2.Biweight(9) > nBw / 2)
nSd = StzDataSetQ([ 1, 2, 3, 4, 5, 6, 7, 8, 1000000000 ]).StandardDeviation()
chk("NEGATIVE: the standard deviation of the same values is " + _FfNum(nSd, 0), nSd > 100000000)

sec("-- 6b. RE-EXPRESSION, MEASURED: THE LADDER, THE SLOPE, THE VERDICT ---------")

# the oracles are built FROM a known power: an additive table with seeded
# noise, and its exponential, which is multiplicative and wants the log
aAdd = _TkSynthetic(0)
aMul = _TkSynthetic(1)
oRe = StzTukeyReexpressionQ(aMul)
aL = oRe.Ladder()
chk("the ladder has six rungs, evaluated in one crossing: " + @@(StzTukeyLadderPowers()), len(aL) = 6)
aR1 = oRe.Rung(1)
chk("at power 1 the multiplicative table's residuals track the comparison values with slope near 1  [" + _FfNum(aR1[2], 4) + "]", fabs(aR1[2] - 1) < 0.35)
aRec = oRe.Recommend()
chk("the recommendation fires and names the log, with its slope as evidence: " + aRec[:evidence], aRec[:fires] = 1 and aRec[:power] = 0 and aRec[:name] = "log")
chk("...and the diagnostic is a finding in the house rule shape", len(oRe.Diagnostics("sales")) = 1 and oRe.Diagnostics("sales")[1][:rule] = "non_additive")
oAd = StzTukeyReexpressionQ(aAdd)
aRecA = oAd.Recommend()
chk("NEGATIVE, the one that matters more: the additive table gets NO recommendation -- power 1, slope " + _FfNum(aRecA[:slope], 4) + " within the threshold " + _FfNum(oAd.Threshold(), 2), aRecA[:fires] = 0 and aRecA[:power] = 1)
chk("...and no finding", len(oAd.Diagnostics("sales")) = 0)
chk("the threshold is the engine's measured constant, 0.5, printed on every verdict", oRe.Threshold() = 0.5 and StzFindFirst("threshold 0.5", aRec[:evidence]) > 0)
aNA = oAd.NonAdditivity()
chk("the non-additivity slope of the additive table alone, without the ladder: " + _FfNum(aNA[:slope], 4) + ", suggested power " + _FfNum(aNA[:power], 2), aNA[:ok] = 1 and fabs(aNA[:slope]) < 0.5)
# spread versus level, from a known power
aSL = StzTukeySpreadLevel([ [ 9, 10, 11 ], [ 18, 20, 22 ], [ 36, 40, 44 ], [ 72, 80, 88 ] ])
chk("groups whose spread doubles with the level: log-spread on log-level slope 1, suggested power 0 (log)  [" + _FfNum(aSL[:slope], 4) + "]", aSL[:ok] = 1 and fabs(aSL[:slope] - 1) < 0.000001 and fabs(aSL[:power]) < 0.000001)
aSC = StzTukeySpreadLevel([ [ 9, 10, 11 ], [ 19, 20, 21 ], [ 39, 40, 41 ], [ 79, 80, 81 ] ])
chk("NEGATIVE: constant spread across levels: slope 0, power 1, leave it  [" + _FfNum(aSC[:slope], 4) + "]", aSC[:ok] = 1 and fabs(aSC[:slope]) < 0.000001 and fabs(aSC[:power] - 1) < 0.000001)
chk("a group whose spread is zero cannot be logged: not ok, never a guess", StzTukeySpreadLevel([ [ 5, 5, 5 ], [ 10, 12, 14 ] ])[:ok] = 0)

sec("-- 7. THE COST, PRINTED -------------------------------------------------")

aBig = []
for i = 1 to 100
	aRow = []
	for j = 1 to 100
		aRow + (10 + i * 0.5 + j * 0.25 + ((i * 7 + j * 13) % 10) / 10)
	next
	aBig + aRow
next
nT0 = StzEngineWatchTimestampMs()
oBig = StzTukeyFitQ(aBig)
oBig.Polish()
nMs = StzEngineWatchTimestampMs() - nT0
? "        polish of 100 x 100 through the seam: " + _FfNum(nMs, 1) + " ms (" + oBig.Sweeps() + " sweep(s)); the engine alone measured 0.98 ms in TK0"
chk("the contract holds on the large table too", oBig.Check() < 0.000000001)
chk("the polish through the seam stays under a second", nMs < 1000)

#---------------------------------------------------------------------------

if nSecClock > 0
	? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
ok
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? " skipped: the smoother family (3, 3R, SS, H, 4253H, twicing) -- no R oracle on this machine; it waits (TK1 kill criterion)"
? "=============================================================="

func sec cTitle
	if nSecClock > 0
		? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
	ok
	nSecClock = clock()
	? cTitle

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func _TkClose aGot, aWant
	if len(aGot) != len(aWant)  return FALSE  ok
	for _i_ = 1 to len(aWant)
		if fabs(aGot[_i_] - aWant[_i_]) > 0.000000001  return FALSE  ok
	next
	return TRUE

# the classical additive decomposition's row effects: row mean minus grand mean
func _TkMeanRowEffects aRows
	_nR_ = len(aRows)
	_nC_ = len(aRows[1])
	_nG_ = 0
	_a_ = []
	for _i_ = 1 to _nR_
		_s_ = 0
		for _j_ = 1 to _nC_  _s_ += aRows[_i_][_j_]  next
		_a_ + (_s_ / _nC_)
		_nG_ += _s_
	next
	_nG_ = _nG_ / (_nR_ * _nC_)
	for _i_ = 1 to _nR_  _a_[_i_] = _a_[_i_] - _nG_  next
	return _a_

func _TkRefuses cWhat
	_b_ = FALSE
	try
		if cWhat = "convention"  StzTukeySummaryQ([ 1, 2, 3 ]).SetConvention(:Median)
		but cWhat = "fence"  StzTukeySummaryQ([ 1, 2, 3 ]).Fences(0)
		but cWhat = "unpolished"  StzTukeyFitQ([ [ 1, 2 ], [ 3, 4 ] ]).Common()
		but cWhat = "ragged"  StzTukeyFitQ([ [ 1, 2 ], [ 3 ] ])
		but cWhat = "line"  StzTukeyLineQ([ 1, 2 ], [ 1, 2 ])
		but cWhat = "oneway"  StzTukeyOneWayQ([ [ 1, 2 ] ])
		ok
	catch
		_b_ = TRUE
	done
	return _b_

# a 6 x 5 table: additive with seeded noise, or its exponential (multiplicative)
func _TkSynthetic bMul
	_nSeed_ = 99
	_a_ = []
	for _i_ = 0 to 5
		_aRow_ = []
		for _j_ = 0 to 4
			_nSeed_ = (_nSeed_ * 1103515245 + 12345) % 2147483648
			_nNoise_ = (_nSeed_ / 2147483648 - 0.5) * 0.1
			_v_ = 2 + (1 + 0.4 * _i_) + (0.5 + 0.3 * _j_) + _nNoise_
			if bMul  _v_ = exp(_v_)  ok
			_aRow_ + _v_
		next
		_a_ + _aRow_
	next
	return _a_
