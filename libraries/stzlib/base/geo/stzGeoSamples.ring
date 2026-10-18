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

# Holds measurements at places, rain gauges say, and estimates the value in between by inverse distance weighting or ordinary kriging, with the error kriging owes.
#
# The measurements are one flat list lon, lat, value, ... and the window is the ground the estimate
# is made over and clipped to. Three answers, in the order an analyst uses them: IDWField (needs no
# model, tells nothing of its error, never leaves the measured range), Variogram with FitVariogram
# (the curve everything else is read from: nugget, sill and range) and KrigeFields, which returns
# TWO fields, the estimate and its variance, together on purpose: the variance depends only on where
# the gauges are and on the variogram, never on the values. A model must be adopted (FitAndUse)
# before GammaAt, KrigeAt, KrigeFields and CrossValidate, which raise otherwise. Kriging expects a
# field without a trend: for gauges whose value rises or falls steadily the Gaussian fit makes an
# estimate that leaves the measured range by tens of thousands. Nothing is clamped, and Findings
# reports it as an error, so IsSound is FALSE: use a bounded model or take the trend out first.
# Pictures, each looked at by 'stzlib-docs visual pass (a model reading the
# PNG)' on 2026-10-05: doc/gallery/stzGeoSamples/variogram_and_fit.png, gauges over an IDW surface
# beside the variogram and its three fitted models, RIGHT; kriging_transect.png, the estimate with
# isohyets and the doubt along a line, RIGHT (the band pinches at gauges and swells in gaps);
# kriging_on_a_trend.png, the same method on a trend, WRONG (white inside the country marks kriged
# values far outside the classes, see FINDINGS_geo.md; Findings now says so as an error). Index: doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = new stzGeoSamples([ 2.1, 13.5, 100, 8.0, 15.0, 200, 5.0, 14.0, 150 ],
#              StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson")))
#   example    ? o1.Count()
#              #--> 3
#              ? o1.MaxValue()
#              #--> 200
#   see        stzGeoField, stzGeoPoints, stzGeoFeatures
class stzGeoSamples from stzObject
	@aS = []
	@oW = NULL
	@aRings = []
	@aBox = []
	@aModel = []
	@aKrige = []
	@nOutside = 0

	# Builds the measurements from places with values and a window; raises an error for a list not in triples, an empty window or a non-number.
	#
	#   paLonLatValue   the measurements as one flat list lon, lat, value, lon, lat, value, ...
	#   poWindow        the stzGeoFeatures of the ground the estimate is made over
	#   returns         nothing; the samples are built
	#   note            A measurement not made is left out, never entered as 0. Counts the gauges
	#                   that fall outside the window
	#   see             StzGeoSamples, Count
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

	# Returns the measurements as they were given.
	#
	#   returns    a flat list lon, lat, value, lon, lat, value, ...
	#   see        Count, Values
	def Samples()
		return @aS

	# Returns how many measurements there are.
	#
	#   returns    a number
	#   see        Samples
	def Count()
		return len(@aS) / 3

	# Returns the features that make the window.
	#
	#   returns    a stzGeoFeatures
	#   see        WindowRings, Outside
	def Window()
		return @oW

	# Returns the outer ring of every part of the window, the shape the engine takes.
	#
	#   returns    a list of flat lon, lat lists
	#   see        Window
	def WindowRings()
		return @aRings

	# Returns how many measurements lie outside the window.
	#
	#   returns    a number, 0 for a clean set
	#   note       They weigh on the estimate and stand on none of its ground
	#   see        Findings
	def Outside()
		return @nOutside

	# Returns the value of measurement pnI.
	#
	#   pnI        the position of the measurement, from 1
	#   returns    a number, or "" for a position of 0, past the last, or not a whole number
	#   note       An empty answer, never an error, as stzGeoMap answers for a position outside its
	#              features: test with isNumber, and compare with Count
	#   see        PlaceOf, Values
	def ValueOf(pnI)
		if NOT isNumber(pnI)  return ""  ok
		if pnI < 1 or pnI > This.Count() or pnI != floor(pnI)  return ""  ok
		return @aS[pnI * 3]

	# Returns where measurement pnI was made.
	#
	#   pnI        the position of the measurement, from 1
	#   returns    a list [ lon, lat ] in degrees; [ ] for a position of 0, past the last, or not a
	#              whole number
	#   note       LONGITUDE FIRST. An empty answer, never an error, as stzGeoMap answers for a
	#              position outside its features
	#   see        ValueOf
	def PlaceOf(pnI)
		if NOT isNumber(pnI)  return []  ok
		if pnI < 1 or pnI > This.Count() or pnI != floor(pnI)  return []  ok
		return [ @aS[pnI * 3 - 2], @aS[pnI * 3 - 1] ]

	# Returns the measured values, without their places.
	#
	#   returns    a list of numbers
	#   see        MinValue, MaxValue, ValueOf
	def Values()
		_a_ = []
		for _i_ = 1 to This.Count()  _a_ + @aS[_i_ * 3]  next
		return _a_

	# Returns the lowest measured value.
	#
	#   returns    a number
	#   see        MaxValue, Values
	def MinValue()
		_a_ = This.Values()
		_m_ = _a_[1]
		for _i_ = 2 to len(_a_)  if _a_[_i_] < _m_  _m_ = _a_[_i_]  ok  next
		return _m_

	# Returns the highest measured value.
	#
	#   returns    a number
	#   see        MinValue, Values
	def MaxValue()
		_a_ = This.Values()
		_m_ = _a_[1]
		for _i_ = 2 to len(_a_)  if _a_[_i_] > _m_  _m_ = _a_[_i_]  ok  next
		return _m_

	# Returns an inverse-distance-weighted surface over the window as a stzGeoField, clipped to the window.
	#
	#   pnCellKm   the size of a grid cell in km
	#   pnPower    how fast a gauge's vote falls with distance, 2 being usual and a higher power
	#              giving bullseyes
	#   returns    a stzGeoField, 28 columns by 22 rows for Niger at 60 km
	#   note       Raises an error for a power of 0 or less. A weighted mean never leaves the
	#              measured range, and says nothing of its own error
	#   see        KrigeFields, stzGeoField
	#@ aka  -- 1. the baseline ----------------------------------------------------
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

	# Returns half the mean squared difference of pairs of measurements, against their distance, in pnLags bins.
	#
	#   pnLags     how many distance bins
	#   pnMaxKm    the greatest distance in km, 0 for half of the greatest distance in the data
	#   returns    a list of [ h, gamma, pairs ]: the bin's distance in km, its semivariance and the
	#              number of pairs
	#   note       The diagnostic almost nobody draws: near 0 for close pairs, rising to a plateau,
	#              the sill, at the range
	#   see        FitVariogram, GammaAt
	#@ aka  -- 2. the diagnostic --------------------------------------------------
	def Variogram(pnLags, pnMaxKm)
		return StzEngineGeoVariogram(@aS, pnLags, pnMaxKm)

	# Fits a variogram model to the data's 12-lag variogram and returns it, without adopting it.
	#
	#   pcModel    the model to fit: :Spherical, :Exponential, :Gaussian, or :Best to fit all three
	#              and keep the least weighted residual
	#   returns    a hash list [ :model, :nugget, :sill, :range, :rss ]; model is "spherical",
	#              "exponential" or "gaussian"
	#   note       Raises an error for another name or for fewer than two bins. Data with a trend
	#              can fit a Gaussian model that makes kriging leave the measured range; Findings
	#              reports it once the model is adopted
	#   see        FitAndUse, SetModel, Variogram
	#@ aka  [ :model, :nugget, :sill, :range, :rss ] -- :Best fits all three and keeps the one with the least weighted residual
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

	# Adopts a fitted model as the one kriging uses.
	#
	#   paModel    a model as FitVariogram answers it, with at least four items
	#   returns    nothing; the model is stored
	#   note       Raises an error for anything shorter
	#   see        Model, FitAndUse
	#@ aka  the fitted model this object will krige with
	def SetModel(paModel)
		if NOT (isList(paModel) and len(paModel) >= 4)
			stzraise("stzGeoSamples.SetModel: a model is what FitVariogram answers.")
		ok
		@aModel = paModel
		@aKrige = []

		def SetModelQ(paModel)
			This.SetModel(paModel)
			return This

	# Returns the model kriging will use.
	#
	#   returns    a hash list [ :model, :nugget, :sill, :range, :rss ], or [ ] until one is set
	#   see        SetModel, FitAndUse
	def Model()
		return @aModel

	# Fits a variogram model and adopts it in one move.
	#
	#   pcModel    the model to fit: :Spherical, :Exponential, :Gaussian, or :Best
	#   returns    the fitted hash list [ :model, :nugget, :sill, :range, :rss ]
	#   note       Kriging and GammaAt raise an error until a model is adopted. The fit is not
	#              bounded: on gauges with a trend a Gaussian fit makes kriging answer tens of
	#              thousands outside the measured range, and nothing here clamps it
	#   warning    Check Findings or IsSound after adopting: they now flag that estimate as an error,
	#              and the cure is a bounded model (:Spherical or :Exponential) or a detrended set
	#   see        FitVariogram, KrigeFields, Findings
	#@ aka  fit and adopt in one move, which is what most callers want
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

	# Returns the adopted model's semivariance at a distance, for drawing the curve over the variogram.
	#
	#   pnHkm      the distance in km
	#   returns    a number; 0 at distance 0
	#   note       Raises an error until a model is adopted
	#   see        Variogram, FitAndUse
	#@ aka  gamma(h) under the fitted model, for drawing the curve over the cloud
	def GammaAt(pnHkm)
		return StzEngineGeoVariogramAt(This._ModelNumbers(), pnHkm)

	# Returns the ordinary-kriging estimate and its variance as two fields, from one factorisation.
	#
	#   pnCellKm   the size of a grid cell in km
	#   returns    a list of two stzGeoField: the estimate, then the kriging variance with the unit
	#              "kriging variance"
	#   note       Raises an error with no model, with two gauges at one place that read
	#              differently, or past 1200 gauges
	#   warning    The estimate is NOT held to the measured range. On gauges with a trend the Gaussian
	#              fit can make it leave that range by tens of thousands, and it is returned as
	#              computed, never clamped. Findings reports it as an error from the moment this has
	#              run
	#   see        KrigeAt, CrossValidate, IDWField, Findings
	#@ aka  -- 3. the answer, with its own doubt ----------------------------------
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
		_st_ = _e_.Stats()
		@aKrige = []
		if _st_[:known] > 0  @aKrige = [ _st_[:min], _st_[:max] ]  ok
		_v_ = StzGeoField(_g_, _r_[2])
		_v_.SetClip(@aRings)
		_v_.SetUnit("kriging variance")
		_v_.SetSource("ordinary kriging variance, " + @aModel[:model] + " variogram")
		return [ _e_, _v_ ]

	# Returns the kriging estimate and its variance at one place.
	#
	#   pnLon      longitude in degrees east
	#   pnLat      latitude in degrees north
	#   returns    a list [ estimate, variance ]; the variance is 0 at a gauge
	#   note       LONGITUDE FIRST. Raises an error until a model is adopted. Far outside the window
	#              it answers about the mean with a variance near the sill
	#   see        KrigeFields, CrossValidate
	#@ aka  [ estimate, variance ] at one place
	def KrigeAt(pnLon, pnLat)
		return StzEngineGeoKrigeAt(@aS, This._ModelNumbers(), pnLon, pnLat)

	# Predicts every gauge from all the others and returns the average error and the root mean square error.
	#
	#   returns    a hash list [ :bias, :rmse ] in the units of the values
	#   note       The honest test of an interpolator. Raises an error until a model is adopted
	#   see        KrigeAt, Findings
	#@ aka  [ :bias, :rmse ] by leave-one-out: every gauge predicted from all the others. The honest test of an interpolator and the one a report owes.
	def CrossValidate()
		_a_ = StzEngineGeoCrossValidate(@aS, This._ModelNumbers())
		if len(_a_) < 2  return [ :bias = 0, :rmse = 0 ]  ok
		return [ :bias = _a_[1], :rmse = _a_[2] ]

	def _EstimateExtremes()
		# [ min, max, how ] of the kriged estimate: from the last KrigeFields run with
		# this model, else from kriging a 6 by 6 lattice inside the window. [ ] when
		# there is no model, no gauges worth a probe (under 3, over 200) or no answer.
		if len(@aModel) < 4  return []  ok
		if len(@aKrige) = 2  return [ @aKrige[1], @aKrige[2], "the kriged field" ]  ok
		_n_ = This.Count()
		if _n_ < 3 or _n_ > 200  return []  ok
		_b_ = @aBox
		_lo_ = 0
		_hi_ = 0
		_got_ = 0
		for _i_ = 0 to 5
			_x_ = _b_[1] + (_b_[3] - _b_[1]) * (0.02 + 0.96 * _i_ / 5)
			for _j_ = 0 to 5
				_y_ = _b_[2] + (_b_[4] - _b_[2]) * (0.02 + 0.96 * _j_ / 5)
				if @oW.IndexAt(_x_, _y_) = 0  loop  ok
				_k_ = This.KrigeAt(_x_, _y_)
				if NOT isList(_k_)  loop  ok
				if len(_k_) < 2  loop  ok
				if _got_ = 0
					_lo_ = _k_[1]
					_hi_ = _k_[1]
				ok
				if _k_[1] < _lo_  _lo_ = _k_[1]  ok
				if _k_[1] > _hi_  _hi_ = _k_[1]  ok
				_got_++
			next
		next
		if _got_ = 0  return []  ok
		return [ _lo_, _hi_, "" + _got_ + " places probed" ]

	# Returns what is wrong with the set and its fit, as entries of severity warning or error.
	#
	#   returns    a list of [ :rule, :subject, :where, :severity, :message ]; [ ] when clean
	#   note       Gauges outside the window and fewer than 20 gauges are warnings. The range rule is
	#              an error beyond the window's diagonal and a warning beyond half of it. Once a model
	#              is adopted the estimate is checked too: it is an ERROR (rule
	#              the_estimate_is_inside_the_data) when kriging leaves the measured range by more
	#              than the spread of the data itself, read from the last KrigeFields or else from a
	#              6 by 6 lattice of probes (up to 200 gauges; beyond that only a KrigeFields run is
	#              checked)
	#   see        IsSound, FitAndUse, KrigeFields
	#@ aka  -- what the gate owes an interpolation --------------------------------
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

		# 5. AN ESTIMATE OUTSIDE THE DATA. Ordinary kriging weights can be
		# negative, so it MAY overshoot a little; it may not leave the measured
		# range by more than the whole spread of the data. A trend and a
		# Gaussian fit do, by tens of thousands. The estimate is never
		# clamped -- hiding it would be hiding the failure -- so it is said.
		_x_ = This._EstimateExtremes()
		if len(_x_) = 3
			_lo_ = This.MinValue()
			_hi_ = This.MaxValue()
			_tol_ = (_hi_ - _lo_) + 0.000000001 * (1 + fabs(_lo_) + fabs(_hi_))
			if _x_[1] < _lo_ - _tol_ or _x_[2] > _hi_ + _tol_
				_a_ + [ :rule = "the_estimate_is_inside_the_data",
					:subject = _c_,
					:where = "estimate " + StzFactNumText(_x_[1]) + " to " + StzFactNumText(_x_[2]) +
						" (" + _x_[3] + ")",
					:severity = "error",
					:message = "kriging with the " + @aModel[:model] + " variogram estimates " +
						StzFactNumText(_x_[1]) + " to " + StzFactNumText(_x_[2]) +
						" where the gauges measure " + StzFactNumText(_lo_) + " to " +
						StzFactNumText(_hi_) + " -- further outside them than the whole " +
						"spread of the data. Data with a trend does this to a Gaussian fit. " +
						"Fit a bounded model (FitAndUse(:Spherical) or :Exponential), or " +
						"take the trend out of the values and krige what is left; IDWField " +
						"cannot leave the measured range" ]
			ok
		ok
		return _a_

	# TRUE if the set has no finding of severity error.
	#
	#   returns    TRUE or FALSE
	#   note       Warnings do not count. A kriging that leaves the measured range by more than the
	#              spread of the data is an error, so such a set is not sound
	#   see        Findings
	def IsSound()
		_a_ = This.Findings()
		for _i_ = 1 to len(_a_)
			if _a_[_i_][:severity] = "error"  return FALSE  ok
		next
		return TRUE
