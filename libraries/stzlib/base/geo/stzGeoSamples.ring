# stzGeoSamples -- MEASUREMENTS AT PLACES, AND THE VALUE IN BETWEEN (GE7c)
#
# GE7a had places with no value and asked whether they were clustered. GE7b
# made a field by SMOOTHING a pattern -- how many places per square
# kilometre. This has sixty rain gauges, each with a number, and asks the
# question those two cannot: HOW MUCH RAIN FELL WHERE THERE IS NO GAUGE?
#
# Three answers, in the order an analyst uses them:
#
#   IDWField(cellKm, power)
#       Inverse distance weighting. Every gauge votes with a weight of
#       1/d^p. It needs no model, assumes nothing, and tells you NOTHING
#       about how wrong it is. Its one real virtue: a weighted average of
#       measurements cannot leave their range, so it will never invent a
#       rainfall nobody recorded.
#
#   Variogram(lags) / FitVariogram(model) / BestModel()
#       THE DIAGNOSTIC ALMOST NOBODY DRAWS. Half the mean squared
#       difference of every pair, against how far apart they are: near zero
#       for close pairs, rising to a plateau at the distance where two
#       gauges stop being related. That distance is the RANGE, the plateau
#       is the SILL, the jump at the origin is the NUGGET. Everything
#       kriging does is read off this curve, and a caller who has not
#       looked at it is trusting a number they have not seen.
#
#   KrigeFields(cellKm)
#       Ordinary kriging: the best linear unbiased predictor for the
#       variogram it is given, and the only one of the three that answers
#       "how wrong might this be" EVERYWHERE. It returns TWO fields -- the
#       estimate and its VARIANCE -- and it returns them together on
#       purpose. The variance is low where the gauges are and high in the
#       gaps, and it is the map that says which parts of the pretty
#       coloured picture nobody should act on.
#
# THE ONE THING MOST WORTH KNOWING: the kriging variance does not depend on
# the measured values at all. Multiply every rainfall by ten and the
# variance surface does not move. It is a function of WHERE the gauges are
# and of the variogram, and of nothing else -- so it answers "how densely
# was this neighbourhood sampled", which is a question worth its own map
# and which no other method here will answer.

func StzGeoSamples(paLonLatValue, poWindow)
	return new stzGeoSamples(paLonLatValue, poWindow)

func StzGeoVariogramModels()
	return [ :Spherical, :Exponential, :Gaussian ]

func _GeoModelNumber(pcModel)
	_c_ = StzLower(ring_trim("" + pcModel))
	if _c_ = "spherical"    return 0  ok
	if _c_ = "exponential"  return 1  ok
	if _c_ = "gaussian"     return 2  ok
	if _c_ = "best"         return -1  ok
	stzraise("stzGeoSamples: '" + pcModel + "' is not a variogram model -- " +
		":Spherical, :Exponential, :Gaussian, or :Best to fit all three and " +
		"keep the one that fits.")

func _GeoModelName(pnK)
	if pnK = 0  return "spherical"  ok
	if pnK = 1  return "exponential"  ok
	if pnK = 2  return "gaussian"  ok
	return "unknown"

class stzGeoSamples from stzObject
	@aS = []
	@oW = NULL
	@aRings = []
	@aBox = []
	@aModel = []
	@nOutside = 0

	def init(paLonLatValue, poWindow)
		if NOT isList(paLonLatValue) or len(paLonLatValue) % 3 != 0
			stzraise("stzGeoSamples: the samples are a flat list " +
				"[ lon, lat, value, lon, lat, value, ... ] -- a measurement is a " +
				"place AND a number, which is what makes this not a point pattern.")
		ok
		if NOT isObject(poWindow)
			stzraise("stzGeoSamples: the window is a stzGeoFeatures -- the ground " +
				"the estimate is made over, and what it is clipped to.")
		ok
		if poWindow.Count() = 0
			stzraise("stzGeoSamples: the window holds no feature.")
		ok
		_n_ = len(paLonLatValue) / 3
		for _i_ = 1 to _n_
			if NOT isNumber(paLonLatValue[_i_ * 3])
				stzraise("stzGeoSamples: sample " + _i_ + " has no numeric value. A " +
					"measurement that was not made is not a measurement of zero -- " +
					"leave it out.")
			ok
		next
		@aS = paLonLatValue
		@oW = poWindow
		@aRings = []
		for _i_ = 1 to @oW.Count()
			for _k_ = 1 to @oW.PartCount(_i_)
				@aRings + @oW.OuterRingOf(_i_, _k_)
			next
		next
		@aBox = @oW.Bounds()
		@nOutside = 0
		for _i_ = 1 to _n_
			if @oW.IndexAt(@aS[_i_ * 3 - 2], @aS[_i_ * 3 - 1]) = 0  @nOutside++  ok
		next

	def Samples()
		return @aS

	def Count()
		return len(@aS) / 3

	def Window()
		return @oW

	def WindowRings()
		return @aRings

	def Outside()
		return @nOutside

	def ValueOf(pnI)
		return @aS[pnI * 3]

	def PlaceOf(pnI)
		return [ @aS[pnI * 3 - 2], @aS[pnI * 3 - 1] ]

	def Values()
		_a_ = []
		for _i_ = 1 to This.Count()  _a_ + @aS[_i_ * 3]  next
		return _a_

	def MinValue()
		_a_ = This.Values()
		_m_ = _a_[1]
		for _i_ = 2 to len(_a_)  if _a_[_i_] < _m_  _m_ = _a_[_i_]  ok  next
		return _m_

	def MaxValue()
		_a_ = This.Values()
		_m_ = _a_[1]
		for _i_ = 2 to len(_a_)  if _a_[_i_] > _m_  _m_ = _a_[_i_]  ok  next
		return _m_

	#-- 1. the baseline ----------------------------------------------------

	# IDW as a field, clipped to the window. Power 2 is the usual default
	# and is a CHOICE, not a fact: a higher power leans harder on the
	# nearest gauge and makes bullseyes round each one.
	def IDWField(pnCellKm, pnPower)
		if pnPower <= 0
			stzraise("stzGeoSamples.IDWField: the power is positive -- it is how " +
				"fast a gauge's vote falls off with distance.")
		ok
		_g_ = StzEngineGeoGridOver(@aBox, pnCellKm)
		_v_ = StzEngineGeoIdwField(@aS, _g_, pnPower, @aRings, @aBox)
		_f_ = StzGeoField(_g_, _v_)
		_f_.SetClip(@aRings)
		_f_.SetSource("inverse distance weighting, power " + pnPower)
		return _f_

	#-- 2. the diagnostic --------------------------------------------------

	# [ [ h, gamma, pairs ], ... ]. pnMaxKm of 0 takes HALF the greatest
	# distance in the data, which is the standard cut: beyond it only the
	# opposite corners contribute and the far bins are a handful of pairs
	# sharing the same few gauges.
	def Variogram(pnLags, pnMaxKm)
		return StzEngineGeoVariogram(@aS, pnLags, pnMaxKm)

	# [ :model, :nugget, :sill, :range, :rss ] -- :Best fits all three and
	# keeps the one with the least weighted residual
	def FitVariogram(pcModel)
		return This.FitVariogramXT(This.Variogram(12, 0), pcModel)

	def FitVariogramXT(paBins, pcModel)
		if len(paBins) < 2
			stzraise("stzGeoSamples.FitVariogram: fewer than two lag bins -- there " +
				"is no curve to fit. More gauges, or fewer lags.")
		ok
		_a_ = StzEngineGeoFitVariogram(paBins, _GeoModelNumber(pcModel))
		if len(_a_) < 5  return []  ok
		return [ :model = _GeoModelName(_a_[1]), :nugget = _a_[2], :sill = _a_[3],
		         :range = _a_[4], :rss = _a_[5] ]

	# the fitted model this object will krige with
	def SetModel(paModel)
		if NOT (isList(paModel) and len(paModel) >= 4)
			stzraise("stzGeoSamples.SetModel: a model is what FitVariogram answers.")
		ok
		@aModel = paModel

		def SetModelQ(paModel)
			This.SetModel(paModel)
			return This

	def Model()
		return @aModel

	# fit and adopt in one move, which is what most callers want
	def FitAndUse(pcModel)
		This.SetModel(This.FitVariogram(pcModel))
		return @aModel

	def _ModelNumbers()
		if len(@aModel) < 4
			stzraise("stzGeoSamples: no variogram model has been fitted. Kriging " +
				"is not a formula you apply to points -- it reads the RANGE, the " +
				"SILL and the NUGGET off a curve, and refusing without one is the " +
				"difference between a method and a guess. Call FitAndUse(:Best).")
		ok
		return [ _GeoModelNumber(@aModel[:model]), @aModel[:nugget],
		         @aModel[:sill], @aModel[:range], 0 ]

	# gamma(h) under the fitted model, for drawing the curve over the cloud
	def GammaAt(pnHkm)
		return StzEngineGeoVariogramAt(This._ModelNumbers(), pnHkm)

	#-- 3. the answer, with its own doubt ----------------------------------

	# [ estimate, variance ] as two stzGeoField, from ONE factorisation.
	#
	# THEY COME BACK TOGETHER ON PURPOSE. A kriged surface published without
	# its variance is the one abuse this method makes easy: it looks like
	# measurement everywhere, and half of it is arithmetic over empty
	# ground. Taking them apart is the caller's decision to make, not a
	# default to stumble into.
	def KrigeFields(pnCellKm)
		_m_ = This._ModelNumbers()
		_g_ = StzEngineGeoGridOver(@aBox, pnCellKm)
		_r_ = StzEngineGeoKrigeField(@aS, _m_, _g_, @aRings, @aBox)
		if len(_r_) < 2
			stzraise("stzGeoSamples.KrigeFields: the system would not solve. Two " +
				"gauges at the same place with different readings make two " +
				"identical rows and no answer; more than 1200 gauges is past what " +
				"one factorisation should spend unasked.")
		ok
		_e_ = StzGeoField(_g_, _r_[1])
		_e_.SetClip(@aRings)
		_e_.SetSource("ordinary kriging, " + @aModel[:model] + " variogram")
		_v_ = StzGeoField(_g_, _r_[2])
		_v_.SetClip(@aRings)
		_v_.SetUnit("kriging variance")
		_v_.SetSource("ordinary kriging variance, " + @aModel[:model] + " variogram")
		return [ _e_, _v_ ]

	# [ estimate, variance ] at one place
	def KrigeAt(pnLon, pnLat)
		return StzEngineGeoKrigeAt(@aS, This._ModelNumbers(), pnLon, pnLat)

	# [ :bias, :rmse ] by leave-one-out: every gauge predicted from all the
	# others. The honest test of an interpolator and the one a report owes.
	def CrossValidate()
		_a_ = StzEngineGeoCrossValidate(@aS, This._ModelNumbers())
		if len(_a_) < 2  return [ :bias = 0, :rmse = 0 ]  ok
		return [ :bias = _a_[1], :rmse = _a_[2] ]

	#-- what the gate owes an interpolation --------------------------------

	def Findings()
		_a_ = []
		_c_ = "" + This.Count() + " samples in " + @oW.NameOf(1)
		if @oW.Count() > 1  _c_ = "" + This.Count() + " samples in " + @oW.Count() + " regions"  ok

		# 1. SAMPLES OUTSIDE THE WINDOW. They pull the estimate over ground
		# they do not stand on, and they are usually a data error.
		if @nOutside > 0
			_a_ + [ :rule = "the_samples_are_in_their_window",
				:subject = _c_, :where = "" + @nOutside + " sample(s)",
				:severity = "warning",
				:message = "" + @nOutside + " of " + This.Count() + " samples fall " +
					"outside the window being estimated -- they weigh on the answer " +
					"and stand on none of its ground" ]
		ok

		# 2. TOO FEW TO FIT A VARIOGRAM. The usual floor is thirty pairs a
		# lag; below about twenty gauges there are not enough pairs to see a
		# curve at all, and a fitted range is then a number with no evidence.
		if This.Count() < 20
			_a_ + [ :rule = "enough_samples_for_a_variogram",
				:subject = _c_, :where = "" + This.Count() + " samples",
				:severity = "warning",
				:message = "" + This.Count() + " samples make " +
					(This.Count() * (This.Count() - 1) / 2) + " pairs -- too few to " +
					"see a variogram, so a fitted range is a number with no evidence " +
					"under it. IDW is the honest tool at this size" ]
		ok

		if len(@aModel) < 4  return _a_  ok

		# 3. A RANGE LONGER THAN THE DATA. The model then claims structure
		# at distances nothing was measured at -- it is extrapolation
		# wearing a fitted curve.
		_far_ = 0
		_b_ = @aBox
		_far_ = StzGeoDistanceOnSphereKm(_b_[1], _b_[2], _b_[3], _b_[4])
		if @aModel[:range] > _far_
			_a_ + [ :rule = "the_range_is_inside_the_data",
				:subject = _c_, :where = "range " + StzFactNumText(@aModel[:range]) + " km",
				:severity = "error",
				:message = "the fitted range is " + StzFactNumText(@aModel[:range]) +
					" km and the whole window measures " + StzFactNumText(_far_) +
					" km corner to corner -- the model claims structure at distances " +
					"nothing was measured at" ]
		but @aModel[:range] > _far_ / 2
			_a_ + [ :rule = "the_range_is_inside_the_data",
				:subject = _c_, :where = "range " + StzFactNumText(@aModel[:range]) + " km",
				:severity = "warning",
				:message = "the fitted range is over half the window's diagonal, so " +
					"it rests on the far lag bins, which are the ones built from " +
					"fewest pairs" ]
		ok

		# 4. ALL NUGGET IS NO STRUCTURE. If the jump at the origin carries
		# most of the sill, the gauges do not predict each other, and
		# kriging will return very nearly the mean everywhere with a large
		# variance. That is an honest answer and the caller should be told
		# rather than left to admire a flat map.
		if @aModel[:nugget] > (@aModel[:nugget] + @aModel[:sill]) * 0.75
			_a_ + [ :rule = "the_variogram_found_structure",
				:subject = _c_,
				:where = "nugget " + StzFactNumText(@aModel[:nugget]) + " of " +
					StzFactNumText(@aModel[:nugget] + @aModel[:sill]),
				:severity = "warning",
				:message = "the nugget carries most of the sill: these measurements " +
					"barely predict each other, so the kriged surface will be close " +
					"to their mean everywhere with a large variance. That is the " +
					"data's answer, not a fault in the fit" ]
		ok
		return _a_

	def IsSound()
		_a_ = This.Findings()
		for _i_ = 1 to len(_a_)
			if _a_[_i_][:severity] = "error"  return FALSE  ok
		next
		return TRUE
