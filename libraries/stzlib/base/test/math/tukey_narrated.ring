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
nTkSeed = 12345
aDeaths = [ [ 14, 15, 14 ], [ 7, 4, 7 ], [ 8, 2, 10 ], [ 15, 9, 10 ], [ 0, 2, 0 ] ]
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

sec("-- 8. THE VERDICTS: EVERY FACE INTO ONE REPORT, AND IsSound() BOTH WAYS (TK4)")

# the deaths table again: three cells are three or more residual
# fourth-spreads from the fit, and each is an ERROR the fit does not describe
oF8 = StzTukeyFitQ(aDeaths)
oF8.Polish()
aD8 = oF8.Diagnostics("deaths")
chk("the deaths fit carries two far-out cells under Tukey's fences (hinges 0 and 1, far-out fences -3 and 4: -5 and 5 are beyond, 3 is not), each an error in the house shape", len(aD8) = 2 and _TkAllRule(aD8, "far_out", "error"))
chk("the message names the residual and its distance past the hinge: cell (3, 2), 'residual -5 lies 5 fourth-spread(s) past the hinge'", _TkFindingHas(aD8, "cell (3, 2)", "residual -5 lies 5 fourth-spread(s) past the hinge, beyond the far-out fence at 3"))
chk("...and cell (4, 1), residual 5, lies 4 past the upper hinge 1", _TkFindingHas(aD8, "cell (4, 1)", "residual 5 lies 4 fourth-spread(s) past the hinge"))
oRep8 = StzTukeyReportQ("deaths", [ oF8, StzTukeyReexpressionQ(aDeaths) ])
chk("one report over the fit and the re-expression: NOT sound, 2 errors, 1 warning (non_additive, slope 0.737)", NOT oRep8.IsSound() and len(oRep8.Errors()) = 2 and len(oRep8.Warnings()) = 1 and _TkHasRule(oRep8.Findings(), "non_additive"))
chk("Explain() says UNSOUND and groups by subject", StzFindFirst("UNSOUND", oRep8.Explain()[1]) > 0 and StzFindFirst("[deaths]", oRep8.Explain()[2]) > 0)
# BOTH DIRECTIONS on the synthetic additive table of section 6b
aAdd8 = _TkSynthetic(0)
oA8 = StzTukeyFitQ(aAdd8)
oA8.Polish()
oRA8 = StzTukeyReportQ("additive", [ oA8, StzTukeyReexpressionQ(aAdd8) ])
chk("the additive table with seeded noise: no re-expression warning, and ONE far-out error -- cell (6, 3), residual -0.0871, 3.92 fourth-spreads past a hinge on a spread of 0.02; the rule reads the batch it is given", len(oRA8.Warnings()) = 0 and len(oRA8.Errors()) = 1 and _TkFindingHas(oRA8.Errors(), "cell (6, 3)", "residual -0.0871 lies 3.92 fourth-spread(s) past the hinge"))
aExact8 = [ [ 11, 12, 13, 14 ], [ 21, 22, 23, 24 ], [ 31, 32, 33, 34 ], [ 41, 42, 43, 44 ] ]
oE8 = StzTukeyFitQ(aExact8)
oE8.Polish()
oRE8 = StzTukeyReportQ("exact", [ oE8, StzTukeyReexpressionQ(aExact8) ])
chk("NEGATIVE: an exactly additive table is sound, with no finding at all", oRE8.IsSound() and oRE8.NumberOfFindings() = 0)
aWild8 = aExact8
aWild8[3][2] = aWild8[3][2] + 1000
oW8 = StzTukeyFitQ(aWild8)
oW8.Polish()
oRW8 = StzTukeyReportQ("wild", [ oW8 ])
chk("one wild cell of 1000: the report is unsound, with one error, at cell (3, 2) -- and because every OTHER residual is exactly 0, the message says the fences collapsed onto the hinge", NOT oRW8.IsSound() and len(oRW8.Errors()) = 1 and _TkFindingHas(oRW8.Errors(), "cell (3, 2)", "whose fourth-spread is 0"))
aWild8[3][2] = aExact8[3][2]
oR8 = StzTukeyFitQ(aWild8)
oR8.Polish()
chk("...and the same table repaired is sound again", StzTukeyReportQ("repaired", [ oR8 ]).IsSound())
aMul8 = _TkSynthetic(1)
oM8 = StzTukeyFitQ(aMul8)
oM8.Polish()
oRM8 = StzTukeyReportQ("multiplicative", [ oM8, StzTukeyReexpressionQ(aMul8) ])
chk("a multiplicative table fitted additively: the bow throws one corner past the far-out fence (an error) AND the re-expression warns non_additive -- not sound, and both findings say why", NOT oRM8.IsSound() and len(oRM8.Errors()) = 1 and _TkHasRule(oRM8.Findings(), "non_additive"))
# A BATCH: a far-out value is an error, both ways
oS8 = StzTukeySummaryQ([ 2, 4, 4, 5, 7, 9, 12, 40 ])
aS8 = oS8.Diagnostics("marks")
chk("eight marks with a 40: one error, far_out at value #8, '4.54 fourth-spread(s) past the hinge'", len(aS8) = 1 and _TkFindingHas(aS8, "value #8", "value 40 lies 4.54 fourth-spread(s) past the hinge"))
chk("...and with 25 in its place (section 3's batch) there is no finding", len(StzTukeySummaryQ([ 2, 4, 4, 5, 7, 9, 12, 25 ]).Diagnostics("marks")) = 0)
# THE SHAPE, on seeded batches, against the thresholds MEASURED in probe_tk4.ring
oLn8 = StzTukeySummaryQ(_TkBatch("lognormal", 200))
aSh = oLn8.Shape()
chk("a lognormal batch of 200 leans right: mid-summaries drift " + _FfNum(aSh[:skewness], 4) + " past the threshold " + StzTukeySkewThreshold(), aSh[:leans] = "right" and aSh[:skewness] > StzTukeySkewThreshold())
chk("...and its diagnostics carry 'skewed' as a warning naming the threshold", _TkFindingHas(oLn8.Diagnostics("batch"), "the whole batch", "threshold 0.25"))
oNm8 = StzTukeySummaryQ(_TkBatch("normal", 200))
aShN = oNm8.Shape()
chk("NEGATIVE: a normal batch of 200 leans neither and is not heavy  [skew " + _FfNum(aShN[:skewness], 4) + ", tail " + _FfNum(aShN[:tailweight], 4) + "]", aShN[:leans] = "neither" and aShN[:tails] = "not heavy" and len(oNm8.Diagnostics("batch")) = 0)
oCa8 = StzTukeySummaryQ(_TkBatch("cauchy", 200))
aShC = oCa8.Shape()
chk("a Cauchy batch of 200 is heavy-tailed: sixteenth-spread " + _FfNum(aShC[:tailweight], 4) + " times the Gaussian's, past " + StzTukeyTailThreshold(), aShC[:tails] = "heavy" and _TkHasRule(oCa8.Diagnostics("batch"), "heavy_tailed"))
chk("a batch of 50 is UNJUDGED by name -- the thresholds were not measured under 100", StzTukeySummaryQ(_TkBatch("lognormal", 50)).Shape()[:leans] = "unjudged")
# GROUPS: spread that tracks level
oG8 = StzTukeyOneWayQ(_TkGroups(1))
aG8 = oG8.Diagnostics("groups")
chk("five groups whose spread grows with level: 'spread_tracks_level', a warning that says which power to try", len(aG8) = 1 and aG8[1][:rule] = "spread_tracks_level" and StzFindFirst("try power", aG8[1][:message]) > 0)
chk("NEGATIVE: five groups of constant spread: no finding", len(StzTukeyOneWayQ(_TkGroups(0)).Diagnostics("groups")) = 0)
chk("a report over a face without Diagnostics is refused", _TkRefuses("report"))

sec("-- 9. THE STORY COMPUTES NOTHING: EVERY NUMERAL IS READ FROM THE FIT OR A FINDING (TK5)")

oSt = StzTukeyStoryQ(oF8, oRep8)
cSt = oSt.Text()
chk("four paragraphs: the fit, the effects, the findings, the verdict", len(oSt.Paragraphs()) = 4)
chk("the fit paragraph reads the common value and the scale from the fit: '...is 8 and the residuals' fourth-spread... is 1.'", StzFindFirst("The common value is 8 and the residuals' fourth-spread, the scale every judgement below is in, is 1.", cSt) > 0)
chk("the effects paragraph reads the extremes: 'from -8 at row 5 to 6 at row 1' and 'from -1 at column 2 to 0 at column 1'", StzFindFirst("from -8 at row 5 to 6 at row 1", cSt) > 0 and StzFindFirst("from -1 at column 2 to 0 at column 1", cSt) > 0)
chk("the findings paragraph retells a finding verbatim: 'An error, far out, at cell (3, 2): residual -5 lies 5 fourth-spread(s) past the hinge'", StzFindFirst("An error, far out, at cell (3, 2): residual -5 lies 5 fourth-spread(s) past the hinge", cSt) > 0)
chk("the verdict says not sound, 2 error(s), 1 warning(s), and that the fit still holds", StzFindFirst("Verdict: the table is not sound -- 2 error(s), 1 warning(s); the fit still holds", cSt) > 0)
chk("THE HONESTY LAW: every numeral in the prose is carried by the fit or a finding  [" + len(oSt.Numerals()) + " numerals]", oSt.IsHonest() and len(oSt.Unsourced()) = 0 and len(oSt.Numerals()) > 20)
chk("...and the story told twice is the same text: deterministic, no LLM face", StzTukeyStoryQ(oF8, oRep8).Text() = cSt)
oTr = oSt.Transcript()
chk("on the transcript: three system lines and a verdict at certainty 1", oTr.NumberOfLines() = 4 and oTr.Lines()[4][1] = "verdict" and oTr.Lines()[4][3] = 1)
# THE CHECK HAS TEETH: the extractor and the sources are pinned
chk("the numeral extractor: 'cell (3, 2): residual -5 is 5.00 and 0.94' gives 3, 2, 5, 5.00, 0.94", @@( _TsNumerals("cell (3, 2): residual -5 is 5.00 and 0.94") ) = '[ "3", "2", "5", "5.00", "0.94" ]')
chk("the sources carry -8 (an effect) and 0.737 (a finding's slope) and NOT 0.94", StzFindFirst("-8", oSt.SourceNumerals()) > 0 and StzFindFirst("0.737", oSt.SourceNumerals()) > 0 and StzFindFirst("0.94", oSt.SourceNumerals()) = 0)
oStA = StzTukeyStoryQ(oE8, oRE8)
chk("a sound table's story has three paragraphs (no findings) and is honest: " + oStA.Why(), len(oStA.Paragraphs()) = 3 and oStA.IsHonest() and StzFindFirst("the table is sound -- 0 error(s), 0 warning(s)", oStA.Text()) > 0)
chk("a story about an unpolished fit is refused", _TkRefuses("story"))

sec("-- 10. THE SMOOTHERS, EVERY KIND AGAINST R 4.5.1'S OWN OUTPUT (TK1, second half)")

# THE ORACLE: base/test/math/oracle/r_smooth.txt, written by R itself
# (oracle/r_smooth.R) -- three fixed series and forty seeded ones, every
# kind, both end rules, twicing; nothing in it was computed by this library
aOr = _TkOracle("oracle/r_smooth.txt")
chk("the transcript names the R that wrote it: " + aOr[:version], StzFindFirst("R version 4.5.1", aOr[:version]) > 0)
oX = StzTukeySmootherQ(aOr["x"])
chk("R's own ?smooth example, 3R under Tukey's end rule: " + @@(oX.Smooth3R()), _TkClose(oX.Smooth3R(), aOr["x 3R Tukey twice=0"]))
chk("...and under the copy end rule the first value stays 4", _TkClose(oX.SetEndRuleQ(:Copy).Smooth3R(), aOr["x 3R copy twice=0"]))
chk("the splitting of two-flats, S, on the same series", _TkClose(StzTukeySmootherQ(aOr["x"]).Split(), aOr["x S Tukey twice=0"]))
oY = StzTukeySmootherQ(aOr["y"])
chk("a ramp with a 100 on it: 3RS3R takes the point out: " + @@(oY.Smooth3RS3R()), _TkClose(oY.Smooth3RS3R(), aOr["y 3RS3R Tukey twice=0"]))
chk("twicing adds the smooth of the rough back, as R's twiceit does", _TkClose(oY.Twice("3RS3R"), aOr["y 3RS3R Tukey twice=1"]))
chk("the rough is data minus smooth, exactly", _TkClose(_TkAdd(oY.Smooth3RS3R(), oY.Rough("3RS3R")), aOr["y"]))
nAll = 0
nSame = 0
acKinds = StzTukeySmoothKinds()
for cSeries in [ "x", "y", "p" ]
	for k = 1 to len(acKinds)
		for cEr in [ "Tukey", "copy" ]
			for nTw = 0 to 1
				oSm = StzTukeySmootherQ(aOr[cSeries])
				oSm.SetEndRule(cEr)
				if nTw = 1  aGot = oSm.Twice(acKinds[k])  else  aGot = oSm.Smooth(acKinds[k])  ok
				nAll++
				if _TkClose(aGot, aOr[cSeries + " " + acKinds[k] + " " + cEr + " twice=" + nTw])  nSame++  ok
			next
		next
	next
next
chk("the three fixed series (11, 10 and the 120 presidents), six kinds, both end rules, twice or not: " + nSame + " of " + nAll + " equal R exactly", nSame = nAll and nAll = 72)
nAll = 0
nSame = 0
for c = 1 to 40
	aIn = aOr["case " + c + " input"]
	for k = 1 to len(acKinds)
		for cEr in [ "Tukey", "copy" ]
			oSm = StzTukeySmootherQ(aIn)
			oSm.SetEndRule(cEr)
			nAll++
			if _TkClose(oSm.Smooth(acKinds[k]), aOr["case " + c + " " + acKinds[k] + " " + cEr])  nSame++  ok
		next
	next
	nAll++
	if _TkClose(StzTukeySmootherQ(aIn).Twice("3RS3R"), aOr["case " + c + " 3RS3R Tukey twice"])  nSame++  ok
next
chk("forty seeded integer series of 7 to 30 values with ties and plateaus, every kind, both end rules, and twicing: " + nSame + " of " + nAll + " equal R exactly", nSame = nAll and nAll = 520)
# THE PIECES OF 4253H, each against R per window
oP = StzTukeySmootherQ(aOr["p"])
chk("the window medians of 4 and of 2 equal R's median() on every window of the presidents", _TkClose(oP.WindowMedians(4), aOr["p median4-windows"]) and _TkClose(oP.WindowMedians(2), aOr["p median2-windows"]))
chk("the window medians of 3 and 5 equal the interior of R's runmed", _TkClose(oP.WindowMedians(3), _TkInterior(aOr["p runmed3"], 1)) and _TkClose(oP.WindowMedians(5), _TkInterior(aOr["p runmed5"], 2)))
chk("Hanning's interior equals R's filter(c(0.25, 0.5, 0.25)) interior; the ends are copied here where R prints NA", _TkClose(_TkInterior(oP.Hanning(), 1), _TkInterior(aOr["p hanning-interior"], 1)) and oP.Hanning()[1] = aOr["p"][1])
aLine = []
for i = 1 to 20  aLine + (2 * i + 1)  next
oL = StzTukeySmootherQ(aLine)
chk("4253H keeps a straight line exactly -- every median and Hanning of a line is the line", _TkClose(oL.Smooth4253H(), aLine))
aSpike = aLine
aSpike[11] += 100
n4 = StzTukeySmootherQ(aSpike).Smooth4253H()[11]
chk("...and a spike of 100 on it leaks through the even-span medians by " + _FfNum(fabs(n4 - aLine[11]), 2) + " on a slope of 2 -- under 2, not 0: an even median averages its two middle values", fabs(n4 - aLine[11]) < 2)
chk("3RS3R replaces the spike by a neighbour, 25 for 23 -- a median smoother does not interpolate", StzTukeySmootherQ(aSpike).Smooth3RS3R()[11] = 25)
chk("NEGATIVE: Hanning alone leaves 50 of the spike in place", fabs(StzTukeySmootherQ(aSpike).Hanning()[11] - aLine[11]) = 50)
chk("Why() names the end rule and the largest rough, 94 = 100 - 6: " + oY.Why(), StzFindFirst("end rule tukey", oY.Why()) > 0 and StzFindFirst("largest rough is 94", oY.Why()) > 0)
chk("fewer than four values are refused, and told why", _TkRefuses("smoother"))
chk("an end rule that is neither is refused", _TkRefuses("endrule"))
chk("a kind that is not one of the six is refused with the six", _TkRefuses("kind"))

sec("-- 11. A CHANGE POINT IS A VERDICT WITH A MEASURED THRESHOLD, NEVER A CLAIM (plan row 9)")

# the seeded series of probe_changepoint.ring: a level with noise, a trend of
# 0.1 sigma per point, and steps of 3 and 5 sigma at the middle, n = 100
oLv = StzTukeySmootherQ(_TkStepSeries("level", 100))
aLv = oLv.ChangePoint()
chk("a level with noise: judged, and no level shift -- contrast " + _FfNum(aLv[:contrast], 3) + " under the threshold " + aLv[:threshold], aLv[:judged] = 1 and aLv[:fires] = 0 and aLv[:threshold] = 1.8)
oTr = StzTukeySmootherQ(_TkStepSeries("trend", 100))
aTr = oTr.ChangePoint()
chk("NEGATIVE: a trend of 0.1 sigma per point is not a level shift -- contrast " + _FfNum(aTr[:contrast], 3) + ", the scale is blind to it", aTr[:fires] = 0)
oS5 = StzTukeySmootherQ(_TkStepSeries("step5", 100))
aS5 = oS5.ChangePoint()
chk("a step of 5 sigma at the middle fires, and is located within two of the cut at 51: index " + aS5[:at] + ", contrast " + _FfNum(aS5[:contrast], 3), aS5[:fires] = 1 and fabs(aS5[:at] - 51) <= 2)
aD5 = oS5.Diagnostics("series")
chk("...and the verdict is a warning, level_shift, at that index, naming the contrast and the threshold", len(aD5) = 1 and aD5[1][:rule] = "level_shift" and aD5[1][:where] = "index " + aS5[:at] and StzFindFirst("threshold 1.8", aD5[1][:message]) > 0)
chk("...and Why() says it: " + oS5.Why(), StzFindFirst("a level shift at index " + aS5[:at], oS5.Why()) > 0)
chk("NEGATIVE: the level's diagnostics are empty", len(oLv.Diagnostics("series")) = 0)
nFire = 0
nLoc = 0
for k = 1 to 20
	aK = StzTukeySmootherQ(_TkStepSeriesK("step5", 100, k)).ChangePoint()
	if aK[:fires]  nFire++  ok
	if fabs(aK[:at] - 51) <= 2  nLoc++  ok
next
nNull = 0
for k = 1 to 20
	if StzTukeySmootherQ(_TkStepSeriesK("level", 100, k)).ChangePoint()[:fires]  nNull++  ok
	if StzTukeySmootherQ(_TkStepSeriesK("trend", 100, k)).ChangePoint()[:fires]  nNull++  ok
next
chk("over twenty seeded 5-sigma steps: fires " + nFire + "/20, located within two " + nLoc + "/20; over forty null series: fires " + nNull + "/40", nFire >= 19 and nLoc >= 17 and nNull = 0)
chk("under forty values the verdict is not made, by name", StzTukeySmootherQ(_TkStepSeries("step5", 30)).ChangePoint()[:judged] = 0 and StzFindFirst("needs 40 values", StzTukeySmootherQ(_TkStepSeries("step5", 30)).ChangePoint()[:because]) > 0)
chk("a flat series with one jump has no spread of differences to scale by, and says so", StzFindFirst("no spread", StzTukeySmootherQ(_TkFlatJump()).ChangePoint()[:because]) > 0)

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
? " skipped: none -- every section of this gate ran (the smoother family runs against R 4.5.1's transcript since 2026-09-26; the N-way polish is not built and owns no gate)"
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
		but cWhat = "report"  StzTukeyReportQ("x", [ StzTukeyLineQ([ 1, 2, 3 ], [ 2, 4, 6 ]) ])
		but cWhat = "story"  StzTukeyStoryQ(StzTukeyFitQ([ [ 1, 2 ], [ 3, 4 ] ]), StzRuleReportQ("x"))
		but cWhat = "smoother"  StzTukeySmootherQ([ 1, 2, 3 ])
		but cWhat = "endrule"  StzTukeySmootherQ([ 1, 2, 3, 4, 5 ]).SetEndRule(:Median)
		but cWhat = "kind"  StzTukeySmootherQ([ 1, 2, 3, 4, 5 ]).Smooth("4253")
		ok
	catch
		_b_ = TRUE
	done
	return _b_

# R's transcript: "tag : v1 v2 ..." per line, NA kept as the string "NA"
func _TkOracle cFile
	_a_ = []
	_c_ = read(cFile)
	_ac_ = StzSplit(_c_, char(10))
	for _i_ = 1 to len(_ac_)
		_cL_ = ring_trim(_ac_[_i_])
		if _cL_ = ""  loop  ok
		if StzLeft(_cL_, 17) = "R.version.string:"
			_a_ + [ "version", ring_trim(StzStringSection(_cL_, 18, len(_cL_))) ]
			loop
		ok
		_n_ = StzFindFirst(" : ", _cL_)
		if _n_ = 0  loop  ok
		_cTag_ = ring_trim(StzLeft(_cL_, _n_ - 1))
		_acV_ = StzSplit(ring_trim(StzStringSection(_cL_, _n_ + 3, len(_cL_))), " ")
		_aV_ = []
		for _k_ = 1 to len(_acV_)
			_t_ = ring_trim(_acV_[_k_])
			if _t_ = ""  loop  ok
			if _t_ = "NA"  _aV_ + "NA"  else  _aV_ + number(_t_)  ok
		next
		_a_ + [ _cTag_, _aV_ ]
	next
	return _a_

func _TkInterior aList, nEnds
	_a_ = []
	for _i_ = nEnds + 1 to len(aList) - nEnds  _a_ + aList[_i_]  next
	return _a_

func _TkAdd aA, aB
	_a_ = []
	for _i_ = 1 to len(aA)  _a_ + (aA[_i_] + aB[_i_])  next
	return _a_

func _TkHasRule aF, cRule
	for _i_ = 1 to len(aF)
		if aF[_i_][:rule] = cRule  return TRUE  ok
	next
	return FALSE

func _TkAllRule aF, cRule, cSeverity
	for _i_ = 1 to len(aF)
		if aF[_i_][:rule] != cRule or "" + aF[_i_][:severity] != cSeverity  return FALSE  ok
	next
	return len(aF) > 0

func _TkFindingHas aF, cWhere, cWords
	for _i_ = 1 to len(aF)
		if aF[_i_][:where] = cWhere and StzFindFirst(cWords, aF[_i_][:message]) > 0  return TRUE  ok
	next
	return FALSE

# the seeded generator of probe_tk4.ring, so the gate sees the batches the
# thresholds were measured on: Park-Miller, exact in a double
func _TkU
	nTkSeed = (nTkSeed * 16807) % 2147483647
	return nTkSeed / 2147483647

func _TkGaussian
	_u1_ = _TkU()
	_u2_ = _TkU()
	return sqrt(-2 * log(_u1_)) * cos(2 * 3.14159265358979 * _u2_)

func _TkBatch cKind, nCount
	nTkSeed = 12345
	_a_ = []
	for _i_ = 1 to nCount
		if cKind = "normal"
			_a_ + _TkGaussian()
		but cKind = "lognormal"
			_a_ + exp(_TkGaussian())
		but cKind = "cauchy"
			_a_ + tan(3.14159265358979 * (_TkU() - 0.5))
		ok
	next
	return _a_

# five groups whose medians climb; spread constant, or proportional to level
func _TkGroups bProp
	nTkSeed = 777
	_g_ = []
	for _i_ = 1 to 5
		_lvl_ = 10 * _i_
		_sp_ = 2
		if bProp  _sp_ = 0.2 * _lvl_  ok
		_a_ = []
		for _k_ = 1 to 30  _a_ + (_lvl_ + _sp_ * _TkGaussian() * (1 + 0.5 * (_TkU() - 0.5)))  next
		_g_ + _a_
	next
	return _g_

# the change-point probe's series: Park-Miller from the probe's seed, a level
# of 10 with unit noise, a trend of 0.1 per point, or a step at the middle
func _TkStepSeries cKind, n
	return _TkStepSeriesK(cKind, n, 1)

func _TkStepSeriesK cKind, n, k
	nTkSeed = 4242 + 1000 * (k - 1)
	_a_ = []
	for _i_ = 1 to n
		_v_ = 10 + _TkGaussian()
		if cKind = "trend"  _v_ += 0.1 * _i_  ok
		if cKind = "step3" and _i_ > n / 2  _v_ += 3  ok
		if cKind = "step5" and _i_ > n / 2  _v_ += 5  ok
		_a_ + _v_
	next
	return _a_

func _TkFlatJump
	_a_ = []
	for _i_ = 1 to 60
		if _i_ > 30  _a_ + 15  else  _a_ + 10  ok
	next
	return _a_

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
