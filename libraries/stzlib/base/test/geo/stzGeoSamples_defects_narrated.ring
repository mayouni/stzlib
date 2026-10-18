load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)
$nGsSeed = 12345

# stzGeoSamples -- the defects the documenting wave found, reproduced with invented data and held shut.
# DOCREFORM follow-up, 2026-10-18. Run from inside test/geo:  ring stzGeoSamples_defects_narrated.ring
#
# Data: invented. A well-behaved set (two smooth humps read by 60 gauges at the places
# StzGeoPoints.Sample(60, 20260914) draws) and a set with a TREND (value = 180 + 619 * lon / 5 plus a
# small wobble, 50 gauges at places drawn by a fixed linear congruential generator), both over the Arda
# window (0..5 E, 0..10 N). Nothing here needs the atlas or a window onto the screen.
#
# The register listed five rows and TWO causes:
#   A. ValueOf and PlaceOf raised R2 for a position of 0 or past the last.
#      FIXED: they answer "" and [ ] -- the same empty answer stzGeoMap gives for a position
#      outside its features (ValueOf, LabelPointOf, IsOnPaper).
#   B. FitAndUse, KrigeFields, Findings: on gauges with a trend the Gaussian fit makes kriging answer
#      tens of thousands outside the measured range, while Findings stayed quiet and IsSound said TRUE.
#      Reproduced on the trend set: a Gaussian fit of range 585 km (inside the window, so the range
#      rule never fired, not even as a warning) kriges from -76126 to 90432 for gauges of 190 to 786.
#      FIXED AS A DECISION OF VISIBILITY, NOT OF NUMBERS: Findings has a new rule,
#      the_estimate_is_inside_the_data, of severity ERROR. The estimate is never clamped and the fit
#      is not bounded: a nugget floor or a bounded fallback would change the fit of well-behaved sets,
#      and this guard proves they are untouched, to 1e-9, against values recorded on main.
#
# What each scenario holds, and the rule it answers to:
#   1. positions            -> 1 and the last answer; 0, last + 1, negatives, fractions, text do not
#   2. a well-behaved set   -> sound, no findings, and the numbers are those main produced
#   3. a set with a trend   -> the Gaussian estimate leaves the data, is returned as computed, and IS flagged
#   4. the bounded models   -> on the same set they stay inside the data and are sound
#   5. what the check reads -> a KrigeFields run, or a probe; a new model forgets the old run
#   6. the limit            -> over 200 gauges nothing is probed, and the doc says so
#
# Every positive carries a negative sibling: what must still be answered, still be sound, still be
# left alone.

# --- 1. positions -------------------------------------------------------------------------
Scenario("ValueOf and PlaceOf answer for 1 and the last position, and say nothing for the rest")
	oS = new stzGeoSamples([ 1.5, 2.5, 100, 3, 4, 200, 4.5, 9, 300 ], ArdaWindow())
	Then("there are three measurements", oS.Count(), 3)
	Then("position 1 reads 100", oS.ValueOf(1), 100)
	Then("the last position, 3, reads 300", oS.ValueOf(3), 300)
	Then("position 1 was made at [ 1.5, 2.5 ], longitude first", PlaceIs(oS.PlaceOf(1), 1.5, 2.5), 1)
	Then("the last position was made at [ 4.5, 9 ]", PlaceIs(oS.PlaceOf(3), 4.5, 9), 1)
	Then("the middle one reads 200 and sits at [ 3, 4 ]", oS.ValueOf(2) = 200 and PlaceIs(oS.PlaceOf(2), 3, 4), 1)
	cV0 = "" + oS.ValueOf(0)
	Then("NEGATIVE: position 0 has no value (no error, an empty answer)", cV0, "")
	Then("NEGATIVE: position 0 is not a number, so a caller can test it", isNumber(oS.ValueOf(0)), 0)
	Then("NEGATIVE: and no place", len(oS.PlaceOf(0)), 0)
	Then("NEGATIVE: past the last (4) has no value", isNumber(oS.ValueOf(4)), 0)
	Then("NEGATIVE: past the last (4) has no place", len(oS.PlaceOf(4)), 0)
	Then("NEGATIVE: a far position (1000) has neither", isNumber(oS.ValueOf(1000)) + len(oS.PlaceOf(1000)), 0)
	Then("NEGATIVE: a negative position has neither", isNumber(oS.ValueOf(-1)) + len(oS.PlaceOf(-1)), 0)
	Then("NEGATIVE: a position between two (1.5) is not rounded to a neighbour",
		isNumber(oS.ValueOf(1.5)) + len(oS.PlaceOf(1.5)), 0)
	Then("NEGATIVE: a text is not a position", isNumber(oS.ValueOf("2")) + len(oS.PlaceOf("2")), 0)
	Then("the whole range 1..Count answers, every position", AllAnswer(oS), 1)
	oH = HumpSet()
	Then("NEGATIVE: a set grown to 60 gauges still refuses 61", isNumber(oH.ValueOf(61)) + len(oH.PlaceOf(61)), 0)
	Then("and answers 60", isNumber(oH.ValueOf(60)) + len(oH.PlaceOf(60)), 3)
EndScenario()

# --- 2. a well-behaved set ----------------------------------------------------------------
Scenario("A set without a trend stays sound, and its numbers are those main produced")
	oS = HumpSet()
	Then("sixty gauges", oS.Count(), 60)
	aFit = oS.FitAndUse(:Best)
	Then("the best fit is the Gaussian one, as on main", aFit[:model], "gaussian")
	Then("its sill is the one main fitted, 59.61077300006081", Near(aFit[:sill], 59.61077300006081), 1)
	Then("its range is the one main fitted, 351.3733854206128 km", Near(aFit[:range], 351.3733854206128), 1)
	aK = oS.KrigeFields(25)
	aKat = oS.KrigeAt(2.4, 4.1)
	Then("kriging at (2.4, 4.1) estimates what main did, 72.99917169882292", Near(aKat[1], 72.99917169882292), 1)
	Then("and its variance is what main computed, 0.0038984344082564", Near(aKat[2], 0.00389843440825643), 1)
	aCv = oS.CrossValidate()
	Then("the leave-one-out bias is main's, 0.04772841149954748", Near(aCv[:bias], 0.04772841149954748), 1)
	Then("the leave-one-out rmse is main's, 0.24443242419580941", Near(aCv[:rmse], 0.24443242419580941), 1)
	nLo = aK[1].Min()
	nHi = aK[1].Max()
	Then("the estimate stays within the measured range, give or take a tenth of its spread",
		nLo > oS.MinValue() - (oS.MaxValue() - oS.MinValue()) / 10 and
		nHi < oS.MaxValue() + (oS.MaxValue() - oS.MinValue()) / 10, 1)
	Then("it has no finding at all", len(oS.Findings()), 0)
	Then("and it is sound", oS.IsSound(), 1)
	oB = HumpSet()
	oB.FitAndUse(:Best)
	Then("NEGATIVE: asked BEFORE any KrigeFields run, the probe agrees: sound",
		oB.IsSound(), 1)
	Then("NEGATIVE: the probe finds nothing for the set either", len(oB.Findings()), 0)
	Then("NEGATIVE: the new rule is not a general complaint -- the spherical fit of the same set is sound too",
		FitSound(HumpSet(), :Spherical), 1)
	Then("NEGATIVE: and so is the exponential one, apart from its warning about the range",
		FitSound(HumpSet(), :Exponential), 1)
EndScenario()

# --- 3. a set with a trend ----------------------------------------------------------------
Scenario("Gauges with a trend: the Gaussian estimate leaves the data, and now it is an error")
	oT = TrendSet(50)
	nLo = oT.MinValue()
	nHi = oT.MaxValue()
	Then("fifty gauges read from about 190 to 786", nLo > 180 and nLo < 200 and nHi > 775 and nHi < 800, 1)
	aFit = oT.FitAndUse(:Gaussian)
	Then("the fit is the Gaussian one", aFit[:model], "gaussian")
	Then("its range is INSIDE the window's half diagonal (about 600 km), which is why the old range rule said nothing",
		aFit[:range] < 600, 1)
	aF0 = oT.Findings()
	Then("BEFORE any kriging a probe already finds it: one finding", len(aF0), 1)
	Then("it is the estimate rule", aF0[1][:rule], "the_estimate_is_inside_the_data")
	Then("it is an ERROR, not a warning", aF0[1][:severity], "error")
	Then("and the set is NOT sound", oT.IsSound(), 0)
	Then("the message names the cure: a bounded model", Has(aF0[1][:message], "FitAndUse(:Spherical)"), 1)
	Then("the message names the other cure: take the trend out", Has(aF0[1][:message], "take the trend out"), 1)
	Then("the message states the two ranges it compares (the gauges' and the estimate's)",
		Has(aF0[1][:message], "where the gauges measure"), 1)
	aK = oT.KrigeFields(60)
	nEstLo = aK[1].Min()
	nEstHi = aK[1].Max()
	Then("THE FAILURE IS REAL: the estimate runs below -10000", nEstLo < -10000, 1)
	Then("THE FAILURE IS REAL: and above 10000", nEstHi > 10000, 1)
	Then("it is returned as computed, never clamped: below the lowest gauge by far", nEstLo < nLo - 10000, 1)
	aF1 = oT.Findings()
	Then("AFTER the run, the finding reads the kriged field: still one finding", len(aF1), 1)
	Then("it says where it read the numbers", Has(aF1[1][:where], "the kriged field"), 1)
	cLoText = StzFactNumText(nEstLo)
	Then("it reports the field's own lowest value", Has(aF1[1][:where], cLoText), 1)
	Then("and the set is still NOT sound", oT.IsSound(), 0)
	Then("NEGATIVE: IDW on the same gauges cannot leave their range, and says so",
		IdwInside(oT), 1)
	Then("NEGATIVE: fewer than two findings -- the range, nugget and count rules did not all fire",
		len(aF1) < 2, 1)
EndScenario()

# --- 4. the bounded models ----------------------------------------------------------------
Scenario("The same trend set with a bounded model stays inside the data and is sound")
	oS = TrendSet(50)
	aFit = oS.FitAndUse(:Spherical)
	Then("the spherical fit is spherical", aFit[:model], "spherical")
	aK = oS.KrigeFields(60)
	nEstLo = aK[1].Min()
	nEstHi = aK[1].Max()
	Then("its estimate stays within the data, give or take a tenth of the spread",
		nEstLo > oS.MinValue() - (oS.MaxValue() - oS.MinValue()) / 10 and
		nEstHi < oS.MaxValue() + (oS.MaxValue() - oS.MinValue()) / 10, 1)
	Then("and there is no estimate finding", HasRule(oS.Findings(), "the_estimate_is_inside_the_data"), 0)
	Then("the set is sound (its range is only a warning)", oS.IsSound(), 1)
	oE = TrendSet(50)
	oE.FitAndUse(:Exponential)
	Then("the exponential fit on the same gauges is sound too", oE.IsSound(), 1)
	Then("and has no estimate finding", HasRule(oE.Findings(), "the_estimate_is_inside_the_data"), 0)
	oB = TrendSet(50)
	aBest = oB.FitAndUse(:Best)
	Then("NEGATIVE: :Best picks the Gaussian one on this set (lowest residual) -- the trap is the default",
		aBest[:model], "gaussian")
	Then("NEGATIVE: and so :Best is flagged", oB.IsSound(), 0)
	oN = TrendSet(50)
	Then("NEGATIVE: with no model adopted there is no estimate to judge, and no finding of that rule",
		HasRule(oN.Findings(), "the_estimate_is_inside_the_data"), 0)
	Then("NEGATIVE: and a set with no model is not unsound for it", oN.IsSound(), 1)
EndScenario()

# --- 5. what the check reads --------------------------------------------------------------
Scenario("The check reads the last KrigeFields run, and a new model forgets it")
	oS = TrendSet(50)
	oS.FitAndUse(:Gaussian)
	oS.KrigeFields(60)
	Then("after a Gaussian run it is flagged", oS.IsSound(), 0)
	oS.SetModel(oS.FitVariogram(:Spherical))
	Then("a new model is adopted: the old run is forgotten, the probe reads the new model: sound",
		oS.IsSound(), 1)
	Then("NEGATIVE: and the estimate rule is silent", HasRule(oS.Findings(), "the_estimate_is_inside_the_data"), 0)
	oS.SetModel(oS.FitVariogram(:Gaussian))
	Then("adopting the Gaussian one again is flagged again, without a new KrigeFields run", oS.IsSound(), 0)
	oS.KrigeFields(60)
	oS.SetModel(oS.FitVariogram(:Exponential))
	Then("NEGATIVE: an Exponential model adopted after the run is not judged by the Gaussian run", oS.IsSound(), 1)
	oSame = new stzGeoSamples([ 1, 1, 10, 2, 2, 10, 3, 3, 10 ], ArdaWindow())
	oSame.SetModel([ :model = "spherical", :nugget = 0, :sill = 1, :range = 100, :rss = 0 ])
	Then("NEGATIVE: three equal gauges cannot make an estimate outside them: no estimate finding",
		HasRule(oSame.Findings(), "the_estimate_is_inside_the_data"), 0)
EndScenario()

# --- 6. the limit -------------------------------------------------------------------------
Scenario("Beyond 200 gauges the probe is not run; a KrigeFields run is still read")
	oBig = TrendSet(201)
	Then("201 gauges", oBig.Count(), 201)
	oBig.SetModel([ :model = "gaussian", :nugget = 0, :sill = 44068.1735, :range = 584.8773, :rss = 0 ])
	Then("with a Gaussian model adopted but NO run, nothing is probed: the estimate rule is silent (the stated limit)",
		HasRule(oBig.Findings(), "the_estimate_is_inside_the_data"), 0)
	aK = oBig.KrigeFields(150)
	nEstLo = aK[1].Min()
	nEstHi = aK[1].Max()
	Then("a run of KrigeFields on the same 201 gauges leaves the data", nEstLo < oBig.MinValue() - 1000 or nEstHi > oBig.MaxValue() + 1000, 1)
	Then("and from then on Findings reads it: flagged", HasRule(oBig.Findings(), "the_estimate_is_inside_the_data"), 1)
	Then("and the set is not sound", oBig.IsSound(), 0)
	cSrc = read("../../geo/stzGeoSamples.ring")
	Then("the source no longer carries a 'Defect:' line", Has(cSrc, "Defect:"), 0)
	Then("NEGATIVE: it carries the honest limit: the estimate is not held to the measured range",
		Has(cSrc, "NOT held to the measured range"), 1)
	Then("NEGATIVE: and the one for FitAndUse: the fit is not bounded", Has(cSrc, "The fit is not"), 1)
EndScenario()

Summary()

# --------------------------------------------------------------------------------------
# helpers (after the scenarios: in Ring, code after a func is part of the func)

func Near(nA, nB)
	if NOT isNumber(nA)  return 0  ok
	if fabs(nA - nB) < 0.000000001  return 1  ok
	return 0

func Has(cText, cNeedle)
	if substr(cText, cNeedle) > 0  return 1  ok
	return 0

func ArdaWindow()
	return StzGeoFeaturesFromJson('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Arda"},' +
		'"geometry":{"type":"Polygon","coordinates":[[[0,0],[5,0],[5,10],[0,10],[0,0]]]}}]}')

func PlaceIs(aP, nX, nY)
	if len(aP) != 2  return 0  ok
	if aP[1] = nX and aP[2] = nY  return 1  ok
	return 0

# every position 1..Count answers with a number and a two item place
func AllAnswer(oS)
	nOk = 0
	for i = 1 to oS.Count()
		if isNumber(oS.ValueOf(i)) and len(oS.PlaceOf(i)) = 2  nOk++  ok
	next
	if nOk = oS.Count()  return 1  ok
	return 0

# the same sixty gauges the narrated geo_samples_narrated guard uses: two smooth humps, no noise
func HumpSet()
	oW = ArdaWindow()
	aP = StzGeoPoints([], oW).Sample(60, 20260914)
	aG = []
	for i = 1 to len(aP) / 2
		x = aP[i * 2 - 1]
		y = aP[i * 2]
		aG + x  aG + y
		aG + (50 + 30 * exp(-(pow(x - 1.5, 2) + pow(y - 3, 2)) / 6) +
		      20 * exp(-(pow(x - 3.5, 2) + pow(y - 7.5, 2)) / 5))
	next
	return new stzGeoSamples(aG, oW)

# n gauges at places a fixed linear congruential generator draws, reading a steady climb to the east
# (180 at lon 0, 799 at lon 5) plus a wobble of up to 20 -- a TREND, not a stationary field
func TrendSet(n)
	$nGsSeed = 12345
	aG = []
	for i = 1 to n
		x = 0.1 + 4.8 * GsRnd()
		y = 0.1 + 9.8 * GsRnd()
		aG + x  aG + y  aG + (180 + 619 * x / 5 + 20 * sin(i * 1.7))
	next
	return new stzGeoSamples(aG, ArdaWindow())

func GsRnd()
	$nGsSeed = ($nGsSeed * 1103515245 + 12345) % 2147483648
	return $nGsSeed / 2147483648

# adopt a fit and answer whether the set is sound
func FitSound(oS, pcModel)
	oS.FitAndUse(pcModel)
	if oS.IsSound()  return 1  ok
	return 0

func HasRule(aF, cRule)
	for i = 1 to len(aF)
		if strcmp(aF[i][:rule], cRule) = 0  return 1  ok
	next
	return 0

# IDW over the gauges stays in their range
func IdwInside(oS)
	oF = oS.IDWField(60, 2)
	nLo = oF.Min()
	nHi = oF.Max()
	if nLo >= oS.MinValue() - 0.001 and nHi <= oS.MaxValue() + 0.001  return 1  ok
	return 0
