load "../../stzBase.ring"
decimals(4)

# GE7c -- INTERPOLATION. A narrated guard for stzGeoSamples: IDW, the
# variogram, and ordinary kriging with its variance -- each proven against
# an answer this file knows without running the code.
#
# THE TRUTH IS INVENTED ON PURPOSE. The measurements are read off a smooth
# function of longitude and latitude that this guard writes down, so the
# error of an interpolation can be MEASURED and not merely admired. A guard
# that only checks an interpolator against itself is checking that
# arithmetic is repeatable.

nOk = 0  nBad = 0
? "=========================================================="
? " GE7c: interpolation -- IDW, the variogram, kriging"
? "=========================================================="

oW = StzGeoFeaturesFromJson(_ArdaJson())
oPat = StzGeoPoints([], oW)

# sixty gauges at pseudo-random places, each reading the true field
aPlaces = oPat.Sample(60, 20260914)
aGauges = []
for i = 1 to len(aPlaces) / 2
	x = aPlaces[i * 2 - 1]
	y = aPlaces[i * 2]
	aGauges + x  aGauges + y  aGauges + _TrueField(x, y)
next
oS = StzGeoSamples(aGauges, oW)
? "   " + oS.Count() + " gauges, readings from " + StzFactNumText(oS.MinValue()) +
  " to " + StzFactNumText(oS.MaxValue())

? ""
? "-- 1. A MEASUREMENT IS A PLACE AND A NUMBER --"
chk("samples without a value are refused -- a point pattern is a different " +
    "thing and answers different questions",
    _RefusesPairs())
chk("a sample whose value is not a number is refused, because a measurement " +
    "that was not made is not a measurement of zero",
    _RefusesBlank())
chk("a set of samples without a window is refused -- an estimate is made " +
    "OVER ground, and is clipped to it",
    _RefusesNoWindow())
oOut = StzGeoSamples([ 2.5, 5, 100, 40, 40, 200 ], oW)
chk("a sample outside the window is COUNTED and warned about: it weighs on " +
    "the answer and stands on none of its ground",
    oOut.Outside() = 1 and _Has(oOut.Findings(), "the_samples_are_in_their_window", "warning"))

? ""
? "-- 2. IDW: THE BASELINE, AND WHAT IT CANNOT DO --"
oIdw = oS.IDWField(25, 2)
nAtGauge = oIdw.ValueAt(aGauges[1], aGauges[2])
? "   at the first gauge IDW says " + StzFactNumText(nAtGauge) +
  ", the gauge reads " + StzFactNumText(aGauges[3])
chk("IDW IS EXACT AT A GAUGE -- that is what makes it an interpolator and " +
    "not a smoother",
    fabs(nAtGauge - aGauges[3]) < 0.5)
aIS = oIdw.Stats()
chk("...AND IT CANNOT LEAVE THE DATA'S RANGE anywhere at all: a weighted " +
    "average of measurements lies between the smallest and the largest, so " +
    "IDW will never invent a reading nobody recorded",
    aIS[:min] >= oS.MinValue() - 0.001 and aIS[:max] <= oS.MaxValue() + 0.001)
chk("a higher power leans harder on the nearest gauge", _PowerIsLocal(oS, aGauges))
chk("NEGATIVE: a power of zero is refused -- it is how fast a vote falls " +
    "off with distance, and nothing falls off at zero",
    _RefusesPower(oS))

? ""
? "-- 3. THE VARIOGRAM: the diagnostic almost nobody draws --"
aBins = oS.Variogram(12, 0)
? "   " + len(aBins) + " lag bins; the nearest is h=" + StzFactNumText(aBins[1][1]) +
  " gamma=" + StzFactNumText(aBins[1][2]) + " from " + aBins[1][3] + " pairs"
? "   the farthest is h=" + StzFactNumText(aBins[len(aBins)][1]) +
  " gamma=" + StzFactNumText(aBins[len(aBins)][2])
chk("THE CLOUD RISES: close gauges agree and distant ones do not, which is " +
    "what spatial structure IS and what makes interpolation possible at all",
    aBins[1][2] < aBins[len(aBins)][2] * 0.5)
chk("...and h ascends through the bins, each built from its own pairs",
    _Ascending(aBins) and aBins[1][3] > 0)
aFit = oS.FitVariogram(:Best)
? "   best fit: " + aFit[:model] + " nugget " + StzFactNumText(aFit[:nugget]) +
  " sill " + StzFactNumText(aFit[:sill]) + " range " + StzFactNumText(aFit[:range]) + " km"
chk("A MODEL IS FITTED to the cloud, and its shape is one of the three the " +
    "literature uses",
    _IsOneOf(aFit[:model], [ "spherical", "exponential", "gaussian" ]) and
    aFit[:nugget] >= 0 and aFit[:sill] > 0 and aFit[:range] > 0)
chk("...and the fitted curve passes near the cloud it was fitted to -- the " +
    "test is the RESIDUAL, not that a number came back",
    _FitIsClose(oS, aBins, aFit))
chk("THE FIELD IS SMOOTH, SO THE NUGGET IS SMALL: these readings are a " +
    "function of position with no noise added, and the fit says so",
    aFit[:nugget] < (aFit[:nugget] + aFit[:sill]) * 0.25)
chk("NEGATIVE: a model this file does not know is refused BY NAME, with the " +
    "three it does know in the refusal",
    _RefusesModel(oS))

? ""
? "-- 4. KRIGING REFUSES TO GUESS WITHOUT A CURVE --"
chk("kriging before a variogram is fitted is REFUSED, and the refusal says " +
    "why -- it reads the range, the sill and the nugget off a curve, and " +
    "without one it would be a formula applied to points",
    _RefusesUnfitted(oS))
oS.FitAndUse(:Best)
chk("...and after FitAndUse the model is the object's own",
    len(oS.Model()) >= 4 and oS.Model()[:range] > 0)

? ""
? "-- 5. THE ESTIMATE, AND ITS OWN DOUBT --"
aK = oS.KrigeFields(25)
oEst = aK[1]
oVar = aK[2]
aKat = oS.KrigeAt(aGauges[1], aGauges[2])
? "   at the first gauge kriging says " + StzFactNumText(aKat[1]) +
  " with variance " + StzFactNumText(aKat[2]) + "; the gauge reads " + StzFactNumText(aGauges[3])
chk("KRIGING IS EXACT AT A GAUGE and its variance there is ZERO -- it " +
    "honours what was actually measured",
    fabs(aKat[1] - aGauges[3]) < 0.01 and aKat[2] < 0.01)
chk("the two fields come back TOGETHER from one factorisation, over the " +
    "same grid",
    oEst.ColumnCount() = oVar.ColumnCount() and oEst.RowCount() = oVar.RowCount())
# AVERAGED OVER THE SURFACE, NOT READ AT ONE PLACE. The exact zero at a
# gauge is the previous assertion's business, through KrigeAt; the FIELD is
# a 25 km raster, so reading it at a gauge interpolates from four nodes
# none of which is that gauge. The first version demanded the raster answer
# zero there and failed a correct engine. What the SURFACE claims is that
# it is low near gauges and high in the gaps -- measured here, 0.010 within
# 20 km against 0.314 beyond 60, a factor of thirty-one.
aVN = _MeanVarianceNear(oVar, aGauges, 0, 20)
aVF = _MeanVarianceNear(oVar, aGauges, 60, 99999)
? "   mean variance within 20 km of a gauge " + StzFactNumText(aVN) +
  ", beyond 60 km " + StzFactNumText(aVF)
chk("THE VARIANCE IS LOW NEAR THE GAUGES AND HIGH IN THE GAPS -- it is the " +
    "map of where the estimate is guesswork, and it says so by a factor of " +
    "many, not by a hair",
    aVN < aVF / 5 and aVF > 0.1 and oVar.Max() > aVF * 10)
chk("THE KRIGING VARIANCE DOES NOT DEPEND ON THE MEASURED VALUES: multiply " +
    "every reading by ten and the variance surface does not move, because " +
    "it answers how densely the ground was sampled and nothing else",
    _VarianceIgnoresValues(oS, oW, aGauges))

? ""
? "-- 6. AGAINST THE TRUTH THIS FILE INVENTED --"
# the guard knows the true field, so it can measure both interpolators
aErr = _ErrorsAgainstTruth(oIdw, oEst)
? "   mean absolute error over 400 places: IDW " + StzFactNumText(aErr[1]) +
  ", kriging " + StzFactNumText(aErr[2]) + " (the field spans " +
  StzFactNumText(oS.MaxValue() - oS.MinValue()) + ")"
chk("BOTH INTERPOLATORS BEAT KNOWING NOTHING: their error is far under the " +
    "spread of the field itself, which is what the mean would give you",
    aErr[1] < (oS.MaxValue() - oS.MinValue()) * 0.25 and
    aErr[2] < (oS.MaxValue() - oS.MinValue()) * 0.25)
aCv = oS.CrossValidate()
? "   leave-one-out: bias " + StzFactNumText(aCv[:bias]) + ", rmse " + StzFactNumText(aCv[:rmse])
chk("LEAVE-ONE-OUT CROSS-VALIDATION is near unbiased -- every gauge " +
    "predicted from all the others, which is the honest test and the one a " +
    "report owes",
    fabs(aCv[:bias]) < (oS.MaxValue() - oS.MinValue()) * 0.05)

? ""
? "-- 7. WHAT THE GATE OWES AN INTERPOLATION --"
oFew = StzGeoSamples(_FirstGauges(aGauges, 8), oW)
chk("TOO FEW GAUGES TO SEE A VARIOGRAM warns, and names IDW as the honest " +
    "tool at that size",
    _Has(oFew.Findings(), "enough_samples_for_a_variogram", "warning"))
oLong = StzGeoSamples(aGauges, oW)
oLong.SetModel([ :model = "spherical", :nugget = 0, :sill = 10, :range = 99999, :rss = 0 ])
chk("A RANGE LONGER THAN THE WINDOW is an ERROR: the model claims structure " +
    "at distances nothing was measured at",
    _Has(oLong.Findings(), "the_range_is_inside_the_data", "error") and NOT oLong.IsSound())
oNoise = StzGeoSamples(aGauges, oW)
oNoise.SetModel([ :model = "spherical", :nugget = 9, :sill = 1, :range = 200, :rss = 0 ])
chk("ALL NUGGET AND NO SILL warns: the gauges barely predict each other, so " +
    "the surface will be the mean everywhere -- the data's answer, not a " +
    "fault in the fit",
    _Has(oNoise.Findings(), "the_variogram_found_structure", "warning"))
chk("NEGATIVE: sixty gauges with a sane fitted model report nothing at all",
    len(oS.Findings()) = 0 and oS.IsSound())

? ""
? "=========================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=========================================================="

func chk pcWhat, pbOk
	if pbOk
		nOk++
		? "  ok   " + pcWhat
	else
		nBad++
		? "  FAIL " + pcWhat
	ok

# THE TRUE FIELD, written here so the guard can measure error rather than
# admire agreement: two smooth humps over the window, no noise.
func _TrueField pnLon, pnLat
	return 50 + 30 * exp(-(pow(pnLon - 1.5, 2) + pow(pnLat - 3, 2)) / 6) +
	            20 * exp(-(pow(pnLon - 3.5, 2) + pow(pnLat - 7.5, 2)) / 5)

func _ErrorsAgainstTruth poIdw, poKrige
	_si_ = 0  _sk_ = 0  _n_ = 0
	for _i_ = 1 to 20
		for _j_ = 1 to 20
			_x_ = 0.25 + 4.5 * _i_ / 21
			_y_ = 0.5 + 9 * _j_ / 21
			_t_ = _TrueField(_x_, _y_)
			_vi_ = poIdw.ValueAt(_x_, _y_)
			_vk_ = poKrige.ValueAt(_x_, _y_)
			if isNumber(_vi_) and isNumber(_vk_)
				_si_ += fabs(_vi_ - _t_)
				_sk_ += fabs(_vk_ - _t_)
				_n_++
			ok
		next
	next
	if _n_ = 0  return [ 0, 0 ]  ok
	return [ _si_ / _n_, _sk_ / _n_ ]

# the mean of the variance surface over places whose nearest gauge is
# between pnLo and pnHi kilometres away
func _MeanVarianceNear poVar, paG, pnLo, pnHi
	_s_ = 0  _n_ = 0
	for _i_ = 1 to 24
		for _j_ = 1 to 24
			_x_ = 0.2 + 4.6 * _i_ / 25
			_y_ = 0.4 + 9.2 * _j_ / 25
			_v_ = poVar.ValueAt(_x_, _y_)
			if NOT isNumber(_v_)  loop  ok
			_d_ = _NearestGaugeKm(paG, _x_, _y_)
			if _d_ >= pnLo and _d_ < pnHi
				_s_ += _v_
				_n_++
			ok
		next
	next
	if _n_ = 0  return 0  ok
	return _s_ / _n_

func _NearestGaugeKm paG, pnX, pnY
	_m_ = 999999
	for _i_ = 1 to len(paG) / 3
		_d_ = StzGeoDistanceOnSphereKm(pnX, pnY, paG[_i_ * 3 - 2], paG[_i_ * 3 - 1])
		if _d_ < _m_  _m_ = _d_  ok
	next
	return _m_

func _VarianceIgnoresValues poS, poW, paG
	_scaled_ = []
	for _i_ = 1 to len(paG) / 3
		_scaled_ + paG[_i_ * 3 - 2]
		_scaled_ + paG[_i_ * 3 - 1]
		_scaled_ + (paG[_i_ * 3] * 10 + 1000)
	next
	_o2_ = StzGeoSamples(_scaled_, poW)
	_o2_.SetModel(poS.Model())
	_a_ = poS.KrigeAt(2.4, 4.1)
	_b_ = _o2_.KrigeAt(2.4, 4.1)
	if len(_a_) < 2 or len(_b_) < 2  return FALSE  ok
	# the variance is identical; the estimate follows the values
	return fabs(_a_[2] - _b_[2]) < 0.000001 and
	       fabs((_a_[1] * 10 + 1000) - _b_[1]) < 0.001 and
	       fabs(_a_[1] - _b_[1]) > 1

func _PowerIsLocal poS, paG
	# a place near gauge 1: a big power must sit closer to its reading
	_x_ = paG[1] + 0.05
	_y_ = paG[2]
	_soft_ = poS.IDWField(25, 1).ValueAt(_x_, _y_)
	_hard_ = poS.IDWField(25, 6).ValueAt(_x_, _y_)
	if NOT (isNumber(_soft_) and isNumber(_hard_))  return FALSE  ok
	return fabs(_hard_ - paG[3]) < fabs(_soft_ - paG[3])

func _FitIsClose poS, paBins, paFit
	_o_ = StzGeoSamples(poS.Samples(), poS.Window())
	_o_.SetModel(paFit)
	_s_ = 0
	for _i_ = 1 to len(paBins)
		_s_ += fabs(_o_.GammaAt(paBins[_i_][1]) - paBins[_i_][2])
	next
	# the mean residual is a small part of the sill
	return (_s_ / len(paBins)) < (paFit[:nugget] + paFit[:sill]) * 0.2

func _Ascending paBins
	for _i_ = 2 to len(paBins)
		if paBins[_i_][1] <= paBins[_i_ - 1][1]  return FALSE  ok
	next
	return TRUE

func _IsOneOf pcWhat, paList
	for _i_ = 1 to len(paList)
		if paList[_i_] = pcWhat  return TRUE  ok
	next
	return FALSE

func _FirstGauges paG, pnHowMany
	_a_ = []
	for _i_ = 1 to pnHowMany
		_a_ + paG[_i_ * 3 - 2]  _a_ + paG[_i_ * 3 - 1]  _a_ + paG[_i_ * 3]
	next
	return _a_

func _Has paF, pcRule, pcSev
	for _i_ = 1 to len(paF)
		if paF[_i_][:rule] = pcRule and paF[_i_][:severity] = pcSev  return TRUE  ok
	next
	return FALSE

func _RefusesPairs
	try
		StzGeoSamples([ 1, 2, 3, 4 ], StzGeoFeaturesFromJson(_ArdaJson()))
	catch
		return StzFindFirst("value", cCatchError) > 0
	done
	return FALSE

func _RefusesBlank
	try
		StzGeoSamples([ 1, 2, "" ], StzGeoFeaturesFromJson(_ArdaJson()))
	catch
		return StzFindFirst("measurement", cCatchError) > 0
	done
	return FALSE

func _RefusesNoWindow
	try
		StzGeoSamples([ 1, 2, 3 ], "not a window")
	catch
		return StzFindFirst("window", cCatchError) > 0
	done
	return FALSE

func _RefusesPower poS
	try
		poS.IDWField(25, 0)
	catch
		return StzFindFirst("power", cCatchError) > 0
	done
	return FALSE

func _RefusesModel poS
	try
		poS.FitVariogram(:Parabolic)
	catch
		return StzFindFirst(":Gaussian", cCatchError) > 0
	done
	return FALSE

func _RefusesUnfitted poS
	_o_ = StzGeoSamples(poS.Samples(), poS.Window())
	try
		_o_.KrigeFields(40)
	catch
		return StzFindFirst("variogram", cCatchError) > 0
	done
	return FALSE

func _ArdaJson
	return '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Arda"},' +
		'"geometry":{"type":"Polygon","coordinates":[[[0,0],[5,0],[5,10],[0,10],[0,0]]]}}]}'
