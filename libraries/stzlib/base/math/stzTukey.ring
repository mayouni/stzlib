#=====================================================================#
#  STZTUKEY -- the exploration tier's faces: a resistant summary, the  #
#  two-way fit (median polish), the resistant line                     #
#  (SOFTANZA_TUKEY_PLAN.md 2.1-2.3; plane stzlib-math, M4 / TK1)        #
#=====================================================================#
/*
	Tukey is a CONTRACT before it is a chart: Data = Fit + Residual,
	computed resistantly (medians, not means). Three faces carry it, all
	over engine/src/eda.zig through the stats DLL:

	    oS = StzTukeySummaryQ([ 2, 4, 4, 5, 7, 9, 12, 25 ])
	    ? oS.Fourths()          # [ 4, 10.5 ]   Tukey's fourths, the default
	    ? oS.Quartiles()        # [ 4, 9.75 ]   percentile quartiles, stzDataSet's
	    ? oS.Outside()          # [ 25 ]        beyond 1.5 fourth-spreads
	    ? oS.LetterValues(3)    # M F E, each with depth, lower, upper, mid, spread
	    ? oS.Why()              # names the convention it used

	    oF = StzTukeyFitQ([ [ 14, 15, 14 ], [ 7, 4, 7 ], ... ])
	    oF.Polish()
	    ? oF.Common()  ? oF.Effects(:Row)  ? oF.Residuals()
	    ? oF.Check()            # max |data - (common + row + col + residual)|

	    oL = StzTukeyLineQ(aX, aY)
	    oL.Fit()
	    ? oL.Slope()  ? oL.Intercept()

	THE HINGE CONVENTION IS NAMED, ONCE (plan 2.2). Tukey's fourths are the
	default for everything here; percentile quartiles remain stzDataSet's;
	SetConvention(:Percentile) switches a summary and Why() says which is
	in force. Engine bridges are 0-based and numeric; these faces are
	1-based and named, and that translation happens here and nowhere else.

	NO INFERENCE lives here or anywhere in the tier: no p-value, no
	interval, no forecast (plan 1.5). Severity, never significance.
*/

func StzTukeySummaryQ(paNumbers)
	return new stzTukeySummary(paNumbers)

func StzTukeyFitQ(paRows)
	return new stzTukeyFit(paRows)

func StzTukeyLineQ(paX, paY)
	return new stzTukeyLine(paX, paY)

# the one-way fit: groups of values, each a list; Tukey's one-way median
# polish -- common = the median of the group medians, effect = group median
# minus common, residual = value minus its group's median
func StzTukeyOneWayQ(paGroups)
	return new stzTukeyOneWay(paGroups)

# re-expression, measured: the ladder over a two-way table, the spread-
# versus-level slope over groups, and a recommendation that carries its
# slope and fires only past the measured threshold
func StzTukeyReexpressionQ(paRows)
	return new stzTukeyReexpression(paRows)

# a func placed after a class becomes that class's method: the constructors live here
func StzTukeySmootherQ(paNumbers)
	return new stzTukeySmoother(paNumbers)

func StzTukeySmoothKinds()
	return [ "3", "3R", "S", "3RSS", "3RS3R", "3RSR" ]

func StzTukeyLadderPowers()
	return [ -1, -0.5, 0, 0.5, 1, 2 ]

# the word for a rung of the ladder
func StzTukeyPowerName(pnPower)
	if pnPower = -1  return "reciprocal"  ok
	if pnPower = -0.5  return "reciprocal square root"  ok
	if pnPower = 0  return "log"  ok
	if pnPower = 0.5  return "square root"  ok
	if pnPower = 1  return "as is"  ok
	if pnPower = 2  return "square"  ok
	return "power " + pnPower

#-- spread versus level, over groups ------------------------------------------

# groups of values -> the slope of log fourth-spread on log median, and the
# suggested power 1 - slope: [ :slope, :intercept, :power, :ok, :medians, :spreads ]
func StzTukeySpreadLevel(paGroups)
	if NOT isList(paGroups) or ring_len(paGroups) < 2
		stzraise("StzTukeySpreadLevel: at least two groups, each a list of numbers.")
	ok
	_aM_ = []
	_aS_ = []
	_n_ = ring_len(paGroups)
	for _i_ = 1 to _n_
		_o_ = StzTukeySummaryQ(paGroups[_i_])
		_aM_ + _o_.Median()
		_aS_ + _o_.FourthSpread()
	next
	_a_ = StzEngineTukeySpreadLevel(_aM_, _aS_)
	if NOT isList(_a_) or ring_len(_a_) < 4
		stzraise("StzTukeySpreadLevel: the engine refused the groups.")
	ok
	return [ :slope = _a_[1], :intercept = _a_[2], :power = _a_[3], :ok = _a_[4], :medians = _aM_, :spreads = _aS_ ]

func _TkPad(pcText, pnWidth)
	_c_ = "" + pcText
	while len(_c_) < pnWidth  _c_ = " " + _c_  end
	return _c_

# the letters of the ladder, from the median outward
# THE SHAPE THRESHOLDS, MEASURED BEFORE ANY FACE USED THEM (TK4, 2026-09-26,
# base/test/math/probe_tk4.ring, seeded batches, 20 per class and size):
#   skewness = the mean drift of the F, E and D mid-summaries from M, over
#   the F-spread. Symmetric classes (normal, uniform, t with 2 df), 60
#   batches at each n: |skew| at most 0.2313 (n = 100), 0.2058 (200),
#   0.1408 (400). Exponential batches: at least 0.2366 / 0.2439 / 0.2510;
#   lognormal: 0.2894 / 0.3863 / 0.4245. Threshold 0.25: fires on 0 of 180
#   symmetric batches, on 40 of 40 lognormal, on 40 of 40 exponential at
#   n >= 200 and on fewer at n = 100 (the minimum there is 0.2366).
#   The single F-level mid-summary alone did NOT separate the classes at
#   n = 50 or 200 (symmetric up to 0.2562, skewed down to -0.0855) -- the
#   evidence of skew is the DRIFT across letters, as Tukey read it.
#   tail weight = the D-spread over the F-spread, divided by the Gaussian's
#   2.2745. Normal and uniform, 40 batches at each n: at most 1.1595 /
#   1.1871 / 1.1290. Cauchy: at least 1.1690 / 1.4613 / 1.6215; t with 2 df:
#   1.0992 / 1.1057 / 1.1796. Threshold 1.2: fires on 0 of 120 light-tailed
#   batches, on 40 of 40 Cauchy at n >= 200, and MISSES part of t2 (17, 18
#   and 20 of 20 clear the null maximum; fewer clear 1.2). A verdict on a
#   batch under 100 values is not made: it was not measured there.
func StzTukeySkewThreshold()
	return 0.25
func StzTukeyTailThreshold()
	return 1.2
func StzTukeyGaussianDOverF()
	return 2.2745
func StzTukeyShapeMinCount()
	return 100
# spread versus level: five groups whose spread is constant give |slope| at
# most 0.3397 over 20 sets; spread proportional to level gives at least
# 0.6689. Threshold 0.5, the same as the re-expression's (TK2), fires on
# 0 of 20 constant and 20 of 20 proportional.
func StzTukeySpreadLevelThreshold()
	return 0.5

# A CHANGE POINT, demoted to a verdict with a stated threshold (plan row 9):
# the largest contrast between the medians of the ten values before a cut and
# the ten after it, over the fourth-spread of the consecutive differences (a
# scale blind to a level and a trend and resistant to the one big difference
# a step makes). MEASURED 2026-09-26 (probe_changepoint.ring, seeded series,
# 20 per class and size): a level with noise reaches 1.13 (n = 40) / 0.90
# (n = 100); a trend of 0.1 sigma per point reaches 1.50 / 1.61; a step of 5
# sigma at the middle runs from 1.62 / 2.16 up; a step of 3 sigma from 1.20 /
# 1.13; of 2 sigma from 0.64 / 0.78. Threshold 1.8: fires on 0 of 80 null
# series, on 19 and 20 of 20 five-sigma steps, on 5 and 7 of 20 three-sigma
# steps, on 1 of 20 two-sigma steps; the location lands within two of the
# true cut on 15 and 19 of 20 five-sigma steps. The first statistic tried -- the largest
# step of the 3RS3R smooth over the rough's spread -- did NOT separate the
# classes (null up to 4.3, a 5-sigma step down to 1.97) and is not used.
# Under 40 values the verdict is not made: it was not measured there.
func StzTukeyChangePointThreshold()
	return 1.8
func StzTukeyChangePointWindow()
	return 10
func StzTukeyChangePointMinCount()
	return 40

# ONE REPORT OVER EVERY FACE (TK4): the house gate, stzRuleReport, fed by
# each face's Diagnostics(subject). Ring's list + list NESTS, so the faces
# are given as a list and ingested one by one.
#     oRep = StzTukeyReportQ("deaths", [ oFit, oRe ])
#     ? oRep.IsSound()
func StzTukeyReportQ(pcSubject, paFaces)
	_c_ = "" + pcSubject
	if _c_ = ""  _c_ = "table"  ok
	if NOT isList(paFaces)
		stzraise("StzTukeyReportQ: the faces are a list -- [ oFit, oRe ] -- each answering Diagnostics(subject).")
	ok
	_o_ = new stzRuleReport(_c_)
	for _i_ = 1 to ring_len(paFaces)
		if NOT isObject(paFaces[_i_]) or NOT ismethod(paFaces[_i_], "diagnostics")
			stzraise("StzTukeyReportQ: face " + _i_ + " does not answer Diagnostics(subject).")
		ok
		_o_.Ingest(paFaces[_i_].Diagnostics(_c_))
	next
	return _o_

func StzTukeyLetters()
	return [ "M", "F", "E", "D", "C", "B", "A", "Z", "Y", "X", "W", "V", "U", "T", "S" ]

#-- the resistant summary ---------------------------------------------------

# Summarises a batch of numbers resistantly: median, hinges, fences, letter values and spread, with no mean and no p-value.
#
# The summary is built on medians, so one wild value does not move it. Tukey's fourths are the
# default hinges and percentile quartiles are available with SetConvention; Why says which is in
# force. Fences at 1.5 and 3 fourth-spreads give the outside and far-out values, LetterValues gives
# the ladder from the median outward, and Skewness, TailWeight and Shape read the form of the batch
# against thresholds measured on seeded batches (a shape verdict is made from 100 values).
# Diagnostics returns the verdicts in the house rule shape. There is no inference here. Known
# defect: Skewness, TailWeight, Shape and Diagnostics raise error R2 for a batch of fewer than 5
# values. Checked by hand on 2, 4, 4, 5, 7, 9, 12, 25: median 6, fourths 4 and 10.5, quartiles 4 and
# 9.75, trimean 6.625, MAD 2.5.
#
#   receiver   o1 = new stzTukeySummary([ 2, 4, 4, 5, 7, 9, 12, 25 ])
#   example    ? o1.Median()
#              #--> 6
#              ? @@( o1.Fourths() )
#              #--> [ 4, 10.50 ]
#              ? @@( o1.Outside() )
#              #--> [ 25 ]
#   see        stzTukeySmoother, stzTukeyFit, stzDataSet
class stzTukeySummary from stzObject

	@aNumbers = []
	@cConvention = "fourths"     # "fourths" (Tukey) | "percentile" (stzDataSet's)

	# Builds a resistant summary of a batch of numbers, kept in the order given.
	#
	#   paNumbers   the batch, a non-empty list of numbers
	#   returns     nothing; the object is built
	#   see         Median, Fourths, Why
	def init(paNumbers)
		if NOT isList(paNumbers) or ring_len(paNumbers) = 0
			stzraise("stzTukeySummary: give a list of numbers.")
		ok
		_n_ = ring_len(paNumbers)
		for _i_ = 1 to _n_
			if NOT isNumber(paNumbers[_i_])
				stzraise("stzTukeySummary: item " + _i_ + " is not a number.")
			ok
		next
		@aNumbers = paNumbers

	# Returns the batch as it was given, in the same order.
	#
	#   returns    a list of numbers
	#   see        Count, Outside
	def Numbers()
		return @aNumbers

	# Returns how many values the batch holds.
	#
	#   returns    a number
	#   see        Numbers
	def Count()
		return ring_len(@aNumbers)

	# Chooses which pair of hinges the summary uses: Tukey's fourths, or percentile quartiles.
	#
	#   pcConvention   Fourths, Tukey or Hinges for Tukey's fourths, the default
	#   returns        the summary itself, so calls chain
	#   note           on 2, 4, 4, 5, 7, 9, 12, 25 the upper hinge is 10.5 under fourths and 9.75
	#                  under percentile
	#   warning        it changes Hinges, FourthSpread, Fences, Outside and FarOut; Fourths and
	#                  Quartiles always answer their own pair
	#   see            Convention, Hinges, Fourths, Quartiles
	def SetConvention(pcConvention)
		_c_ = StzLower(ring_trim("" + pcConvention))
		if _c_ = "fourths" or _c_ = "tukey" or _c_ = "hinges"
			@cConvention = "fourths"
		but _c_ = "percentile" or _c_ = "quartiles"
			@cConvention = "percentile"
		else
			stzraise("stzTukeySummary.SetConvention: :Fourths (Tukey's hinges) or :Percentile " +
				"(stzDataSet's quartiles) -- '" + pcConvention + "' is neither.")
		ok
		return This

		def SetConventionQ(pcConvention)
			return This.SetConvention(pcConvention)

	# Returns the convention in force for the hinges.
	#
	#   returns    fourths or percentile
	#   see        SetConvention, Why
	def Convention()
		return @cConvention

	def _ConventionCode()
		if @cConvention = "percentile"  return 1  ok
		return 0

	# Returns the middle value of the batch, or the mean of the two middle values for an even count.
	#
	#   returns    a number
	#   note       6 for 2, 4, 4, 5, 7, 9, 12, 25
	#   see        Fourths, Trimean
	def Median()
		return StzEngineStatsMedian(This._Handle())

	def _Handle()
		return StzEngineStatsCreate(@aNumbers)

	# Returns Tukey's two hinges, the medians of the lower and the upper half including the middle value.
	#
	#   returns    a list [ lower, upper ]
	#   note       always Tukey's pair whatever the convention in force; [ 4, 10.5 ] for 2, 4, 4, 5,
	#              7, 9, 12, 25
	#   see        Quartiles, Hinges, FourthSpread
	#@ aka  Tukey's fourths, whatever the convention in force: the two hinges
	def Fourths()
		return StzEngineTukeyFourths(@aNumbers)

	# Returns the percentile quartiles, read at rank p/100 times n minus 1 with linear interpolation.
	#
	#   returns    a list [ lower, upper ]
	#   note       always the percentile pair; [ 4, 9.75 ] for 2, 4, 4, 5, 7, 9, 12, 25
	#   see        Fourths, Hinges
	#@ aka  percentile quartiles, stats.zig's rank = p/100 * (n-1)
	def Quartiles()
		return StzEngineTukeyQuartiles(@aNumbers)

	# Returns the pair of hinges the convention in force names.
	#
	#   returns    a list [ lower, upper ]: the fourths by default, the quartiles under Percentile
	#   see        SetConvention, Fourths, Quartiles
	#@ aka  the pair the convention in force names
	def Hinges()
		if @cConvention = "percentile"  return This.Quartiles()  ok
		return This.Fourths()

	# Returns the distance between the two hinges, the spread that the fences are measured in.
	#
	#   returns    a number
	#   note       6.5 for 2, 4, 4, 5, 7, 9, 12, 25 under fourths
	#   see        Hinges, Fences
	def FourthSpread()
		_a_ = This.Hinges()
		return _a_[2] - _a_[1]

	# Returns the lower and upper limits at a multiple of the fourth-spread beyond the hinges, under the convention in force.
	#
	#   pnMult     a positive multiplier of the fourth-spread
	#   returns    a list [ lower, upper ]
	#   note       for 2, 4, 4, 5, 7, 9, 12, 25 the 1.5 fences are -5.75 and 20.25
	#   see        OutsideFences, FarOutFences, Outside
	#@ aka  [ lower, upper ] at a multiplier of the fourth-spread, under the convention in force
	def Fences(pnMult)
		if NOT isNumber(pnMult) or pnMult <= 0
			stzraise("stzTukeySummary.Fences: the multiplier is a positive number -- 1.5 outside, 3 far out.")
		ok
		return StzEngineTukeyFences(@aNumbers, pnMult, This._ConventionCode())

	# Returns the fences at 1.5 fourth-spreads beyond the hinges.
	#
	#   returns    a list [ lower, upper ]
	#   see        Fences, Outside
	def OutsideFences()
		return This.Fences(1.5)

	# Returns the fences at 3 fourth-spreads beyond the hinges.
	#
	#   returns    a list [ lower, upper ]
	#   note       -15.5 and 30 for 2, 4, 4, 5, 7, 9, 12, 25
	#   see        Fences, FarOut
	def FarOutFences()
		return This.Fences(3)

	# Returns the values beyond the outside fences, in the order given.
	#
	#   returns    a list of numbers; empty when none is outside
	#   note       25 for 2, 4, 4, 5, 7, 9, 12, 25
	#   see        OutsideFences, FarOut
	#@ aka  the values beyond the outside fences (1.5), in the order given
	def Outside()
		return This._Beyond(This.OutsideFences())

	# Returns the values beyond the far-out fences, in the order given.
	#
	#   returns    a list of numbers; empty when none is far out
	#   note       none for 2, 4, 4, 5, 7, 9, 12, 25, and 100 when the last value is 100
	#   see        FarOutFences, Outside
	#@ aka  the values beyond the far-out fences (3)
	def FarOut()
		return This._Beyond(This.FarOutFences())

	def _Beyond(paFences)
		_a_ = []
		_n_ = ring_len(@aNumbers)
		for _i_ = 1 to _n_
			if @aNumbers[_i_] < paFences[1] or @aNumbers[_i_] > paFences[2]
				_a_ + @aNumbers[_i_]
			ok
		next
		return _a_

	# Returns the ladder of letter values from the median outward: depth, lower, upper, mid and spread at each level.
	#
	#   pnLevels   how many levels, from 1 for the median alone
	#   returns    a list of rows [ letter, depth, lower, upper, mid, spread ] with letters M, F, E,
	#              D, C and on
	#   note       for 2, 4, 4, 5, 7, 9, 12, 25: M is 6 at depth 4.5, F is 4 and 10.5, E is 3 and
	#              18.5
	#   warning    the ladder stops when the depth reaches 1, so a batch of 8 gives 4 rows even when
	#              10 are asked
	#   see        LetterValueTable, Hinges, Skewness
	#@ aka  the ladder from M outward: [ [ letter, depth, lower, upper, mid, spread ], ... ]
	def LetterValues(pnLevels)
		if NOT isNumber(pnLevels) or pnLevels < 1
			stzraise("stzTukeySummary.LetterValues: how many levels, from 1 (M) outward.")
		ok
		_aRaw_ = StzEngineTukeyLetterValues(@aNumbers, pnLevels)
		_acL_ = StzTukeyLetters()
		_a_ = []
		_n_ = ring_len(_aRaw_)
		for _i_ = 1 to _n_
			_cL_ = "?"
			if _i_ <= ring_len(_acL_)  _cL_ = _acL_[_i_]  ok
			_a_ + [ _cL_, _aRaw_[_i_][1], _aRaw_[_i_][2], _aRaw_[_i_][3], _aRaw_[_i_][4], _aRaw_[_i_][5] ]
		next
		return _a_

	# Returns Tukey's trimean, the mean of the lower hinge, twice the median and the upper hinge.
	#
	#   returns    a number
	#   note       6.625 for 2, 4, 4, 5, 7, 9, 12, 25
	#   see        Median, Fourths
	def Trimean()
		return StzEngineTukeyTrimean(@aNumbers)

	# Returns the letter values laid out as a text table with one line per level and a note on how depths are found.
	#
	#   pnLevels   how many levels, from 1
	#   returns    a text of several lines
	#   see        LetterValues
	#@ aka  the ladder as a table: letter, depth, lower, mid, upper, spread
	def LetterValueTable(pnLevels)
		_a_ = This.LetterValues(pnLevels)
		_c_ = "  letter  depth   lower      mid    upper   spread" + char(10)
		for _i_ = 1 to ring_len(_a_)
			_c_ += "  " + _TkPad(_a_[_i_][1], 6) + "  " + _TkPad(_FfNum(_a_[_i_][2], 2), 5) + "  " +
				_TkPad(_FfNum(_a_[_i_][3], 4), 7) + "  " + _TkPad(_FfNum(_a_[_i_][5], 4), 7) + "  " +
				_TkPad(_FfNum(_a_[_i_][4], 4), 7) + "  " + _TkPad(_FfNum(_a_[_i_][6], 4), 7) + char(10)
		next
		_c_ += "  depths by Tukey's rule d(next) = (floor(d) + 1) / 2 from d(M) = (n + 1) / 2" + char(10)
		return _c_

	# Returns the median absolute deviation from the median, not scaled to estimate a standard deviation.
	#
	#   returns    a number
	#   note       2.5 for 2, 4, 4, 5, 7, 9, 12, 25
	#   see        Biweight, FourthSpread
	#@ aka  the median absolute deviation, unscaled
	def Mad()
		return StzEngineTukeyMad(@aNumbers)

	# Returns the biweight midvariance, a resistant variance that gives distant values little or no weight.
	#
	#   pnC        the tuning constant in units of the MAD
	#   returns    a number in squared units, a variance and not a standard deviation
	#   note       16.52 with 9 and 13.5 with 6 for 2, 4, 4, 5, 7, 9, 12, 25; its square root is a
	#              spread
	#   see        Mad
	#@ aka  the biweight midvariance with the tuning constant (9 is usual)
	def Biweight(pnC)
		_c_ = pnC
		if NOT isNumber(_c_) or _c_ <= 0  _c_ = 9  ok
		return StzEngineTukeyBiweight(@aNumbers, _c_)

	# Returns how far the mid-summaries drift from the median, in fourth-spreads; positive leans right.
	#
	#   returns    a number; 0 when the fourth-spread is 0
	#   note       0.69 for 2, 4, 4, 5, 7, 9, 12, 25; a shape verdict is made from 100 values
	#   warning    Raises error R2 (index out of range) for a batch of fewer than 5 values, because
	#              it needs four letter values
	#   see        TailWeight, Shape, LetterValues
	#@ aka  -- the shape, measured, and the verdicts (TK4) -----------------------------
	def Skewness()
		_lv_ = This.LetterValues(4)
		_m_ = _lv_[1][5]
		_f_ = _lv_[2][6]
		if _f_ <= 0  return 0  ok
		return ((_lv_[2][5] - _m_) + (_lv_[3][5] - _m_) + (_lv_[4][5] - _m_)) / 3 / _f_

	# Returns the sixteenth-spread over the fourth-spread, divided by the Gaussian ratio 2.2745; 1 is Gaussian.
	#
	#   returns    a number; 1 when the fourth-spread is 0
	#   note       above 1.2 counts as heavy tails once there are 100 values
	#   warning    Raises error R2 (index out of range) for a batch of fewer than 5 values, as
	#              Skewness does
	#   see        Skewness, Shape
	#@ aka  tail weight: the sixteenth-spread over the fourth-spread, against the Gaussian's ratio; 1 is Gaussian, above 1.2 is heavy by the measurement
	def TailWeight()
		_lv_ = This.LetterValues(4)
		_f_ = _lv_[2][6]
		if _f_ <= 0  return 1  ok
		return (_lv_[4][6] / _f_) / StzTukeyGaussianDOverF()

	# Returns the shape in numbers and in words: count, skewness, tail weight, which way it leans and whether its tails are heavy.
	#
	#   returns    a hash list with the keys count, skewness, tailweight, leans, tails and because
	#   note       under 100 values leans and tails are unjudged, and because says so; from 100,
	#              leans is right, left or neither and tails is heavy or not heavy
	#   warning    Raises error R2 (index out of range) for a batch of fewer than 5 values
	#   see        Skewness, TailWeight, Diagnostics
	#@ aka  the shape as words, with the numbers they were read from
	def Shape()
		_n_ = ring_len(@aNumbers)
		if _n_ < StzTukeyShapeMinCount()
			return [ :count = _n_, :skewness = This.Skewness(), :tailweight = This.TailWeight(),
			         :leans = "unjudged", :tails = "unjudged",
			         :because = "a shape verdict needs " + StzTukeyShapeMinCount() + " values; the thresholds were measured from there" ]
		ok
		_s_ = This.Skewness()
		_t_ = This.TailWeight()
		_cL_ = "neither"
		if _s_ > StzTukeySkewThreshold()  _cL_ = "right"  but _s_ < -StzTukeySkewThreshold()  _cL_ = "left"  ok
		_cT_ = "not heavy"
		if _t_ > StzTukeyTailThreshold()  _cT_ = "heavy"  ok
		return [ :count = _n_, :skewness = _s_, :tailweight = _t_, :leans = _cL_, :tails = _cT_,
		         :because = "skew threshold " + StzTukeySkewThreshold() + ", tail threshold " + StzTukeyTailThreshold() ]

	# Returns the verdicts on the batch in the house rule shape: each far-out value is an error, a lean or heavy tails a warning.
	#
	#   pcSubject   what the batch is called in the rows
	#   returns     a list of rows [ :rule, :subject, :where, :severity, :message ]; empty when all
	#               is well
	#   note        the rules are far_out, skewed and heavy_tailed, and each message names the
	#               measurement and its threshold
	#   warning     Raises error R2 (index out of range) for a batch of fewer than 5 values, through
	#               Shape
	#   see         Shape, FarOut, StzTukeyReportQ
	#@ aka  the verdicts in the house shape [ :rule, :subject, :where, :severity, :message ]: a far-out value is an error, a shape is a warning, and every message names the measurement and the threshold it crossed
	def Diagnostics(pcSubject)
		_c_ = "" + pcSubject
		if _c_ = ""  _c_ = "batch"  ok
		_a_ = []
		_aF_ = This.FarOutFences()
		_aH_ = This.Hinges()
		_nS_ = This.FourthSpread()
		_n_ = ring_len(@aNumbers)
		for _i_ = 1 to _n_
			_v_ = @aNumbers[_i_]
			if _v_ < _aF_[1] or _v_ > _aF_[2]
				_nK_ = 0
				if _nS_ > 0
					if _v_ < _aF_[1]  _nK_ = (_aH_[1] - _v_) / _nS_  else  _nK_ = (_v_ - _aH_[2]) / _nS_  ok
				ok
				_a_ + [ :rule = "far_out", :subject = _c_, :where = "value #" + _i_, :severity = :error,
				        :message = "value " + _FfNum(_v_, 4) + " lies " + _FfNum(_nK_, 2) +
				        " fourth-spread(s) past the hinge, beyond the far-out fence at 3" ]
			ok
		next
		_sh_ = This.Shape()
		if _sh_[:leans] = "right" or _sh_[:leans] = "left"
			_a_ + [ :rule = "skewed", :subject = _c_, :where = "the whole batch", :severity = :warning,
			        :message = "the mid-summaries drift " + _FfNum(_sh_[:skewness], 4) + " fourth-spread(s) from the median (threshold " +
			        StzTukeySkewThreshold() + "); the batch leans " + _sh_[:leans] ]
		ok
		if _sh_[:tails] = "heavy"
			_a_ + [ :rule = "heavy_tailed", :subject = _c_, :where = "the whole batch", :severity = :warning,
			        :message = "the sixteenth-spread is " + _FfNum(_sh_[:tailweight], 4) + " times the Gaussian's for this fourth-spread (threshold " +
			        StzTukeyTailThreshold() + ")" ]
		ok
		return _a_

	# Returns one sentence naming the convention in force, with the hinges, median, fourth-spread and the counts outside and far out.
	#
	#   returns    a text
	#   see        Convention, Hinges
	def Why()
		_aH_ = This.Hinges()
		_cName_ = "Tukey's fourths (hinges at depth (floor((n+1)/2)+1)/2)"
		if @cConvention = "percentile"
			_cName_ = "percentile quartiles (rank p/100*(n-1), linear)"
		ok
		return "a Tukey summary of " + ring_len(@aNumbers) + " value(s) under " + _cName_ +
			": hinges " + _FfNum(_aH_[1], 4) + " | " + _FfNum(This.Median(), 4) + " | " +
			_FfNum(_aH_[2], 4) + ", fourth-spread " + _FfNum(This.FourthSpread(), 4) +
			", " + ring_len(This.Outside()) + " outside, " + ring_len(This.FarOut()) + " far out"

#-- the two-way fit ----------------------------------------------------------

# Fits a two-way table as common plus row effect plus column effect plus residual, by median polish.
#
# The polish is R's medpolish, run in the engine: Data = Fit + Residual, with medians and not means,
# so one wild cell shows up as a large residual and does not bend the fit. Call Polish first: every
# read raises an error until then. Check proves the contract, Diagnostics flags a residual past the
# far-out fence and a polish that hit its cap. Checked against R 4.5.1 on a 3 by 3 and a 5 by 3
# table: common, effects and residuals are equal.
#
#   receiver   o1 = new stzTukeyFit([ [ 10, 12, 14 ], [ 11, 13, 15 ], [ 13, 15, 20 ] ]); o1.Polish()
#   example    ? o1.Common()
#              #--> 13
#              ? @@( o1.Effects(:Row) )
#              #--> [ -1, 0, 2 ]
#              ? o1.Residual(3, 3)
#              #--> 3
#   see        stzTukeyOneWay, stzTukeyReexpression, stzTukeySummary
class stzTukeyFit from stzObject

	@aRows = []
	@nRows = 0
	@nCols = 0
	@nCommon = 0
	@aRowEffects = []
	@aColEffects = []
	@aResiduals = []
	@nSweeps = 0
	@bConverged = 0
	@bPolished = 0
	@nEps = 0.01
	@nMaxSweeps = 10

	# Builds a two-way table to be fitted by median polish, from rows of numbers.
	#
	#   paRows     the table as a list of rows, each a list of numbers, all of the same length
	#   returns    nothing; the object is built
	#   see        Polish, SetTolerance
	def init(paRows)
		if NOT isList(paRows) or ring_len(paRows) = 0 or NOT isList(paRows[1])
			stzraise("stzTukeyFit: give the table as a list of rows, each a list of numbers.")
		ok
		_nC_ = ring_len(paRows[1])
		if _nC_ = 0
			stzraise("stzTukeyFit: the first row is empty.")
		ok
		_nR_ = ring_len(paRows)
		for _i_ = 1 to _nR_
			if NOT isList(paRows[_i_]) or ring_len(paRows[_i_]) != _nC_
				stzraise("stzTukeyFit: row " + _i_ + " does not have " + _nC_ + " value(s) -- a two-way table is rectangular.")
			ok
			for _j_ = 1 to _nC_
				if NOT isNumber(paRows[_i_][_j_])
					stzraise("stzTukeyFit: cell (" + _i_ + ", " + _j_ + ") is not a number.")
				ok
			next
		next
		@aRows = paRows
		@nRows = _nR_
		@nCols = _nC_

	# Returns how many rows the table has.
	#
	#   returns    a number
	#   see        NumberOfColumns
	def NumberOfRows()
		return @nRows

	# Returns how many columns the table has.
	#
	#   returns    a number
	#   see        NumberOfRows
	def NumberOfColumns()
		return @nCols

	# Sets how small the change of the residual sum must be for the polish to stop; 0.01 is R's default.
	#
	#   pnEps      a positive fraction of the residual sum
	#   returns    the fit itself, so calls chain
	#   note       call it before Polish
	#   see        SetMaxSweeps, Polish
	#@ aka  R's defaults: eps 0.01 of the residual sum, at most 10 sweeps
	def SetTolerance(pnEps)
		if NOT isNumber(pnEps) or pnEps <= 0
			stzraise("stzTukeyFit.SetTolerance: a positive fraction of the residual sum.")
		ok
		@nEps = pnEps
		return This

	# Sets the largest number of sweeps the polish may make; 10 is R's default.
	#
	#   pnMax      the cap, at least 1
	#   returns    the fit itself, so calls chain
	#   warning    a polish that stops at the cap is not converged and Diagnostics reports a warning
	#   see        SetTolerance, IsConverged
	def SetMaxSweeps(pnMax)
		if NOT isNumber(pnMax) or pnMax < 1
			stzraise("stzTukeyFit.SetMaxSweeps: at least one sweep.")
		ok
		@nMaxSweeps = pnMax
		return This

	# Fits the table as common plus row effect plus column effect plus residual, using medians, as R's medpolish does.
	#
	#   returns    the fit itself, so calls chain
	#   note       on the 3 by 3 table 10, 12, 14 / 11, 13, 15 / 13, 15, 20 it gives common 13 and a
	#              single residual of 3, as R does
	#   warning    every other read raises an error until Polish has run
	#   see        Common, Effects, Residuals, Check
	#@ aka  THE POLISH, R's stats::medpolish exactly, in one engine crossing
	def Polish()
		_a_ = StzEngineTukeyPolish(@aRows, @nEps, @nMaxSweeps)
		if NOT isList(_a_) or ring_len(_a_) < 6
			stzraise("stzTukeyFit.Polish: the engine refused the table.")
		ok
		@nCommon = _a_[1]
		@aRowEffects = _a_[2]
		@aColEffects = _a_[3]
		@aResiduals = _a_[4]
		@nSweeps = _a_[5]
		@bConverged = _a_[6]
		@bPolished = 1
		return This

		def PolishQ()
			return This.Polish()

	def _RequirePolished(pcWhat)
		if NOT @bPolished
			stzraise("stzTukeyFit." + pcWhat + ": Polish() first -- the fit is computed, never assumed.")
		ok

	# TRUE if Polish has run on this fit.
	#
	#   returns    1 or 0
	#   see        Polish
	def IsPolished()
		return @bPolished

	# Returns the typical value of the whole table, the first term of the fit.
	#
	#   returns    a number
	#   note       13 for the 3 by 3 table above
	#   warning    Raises an error until Polish has run
	#   see        Effects, Fitted
	def Common()
		This._RequirePolished("Common")
		return @nCommon

	# Returns the row effects or the column effects, the amount each row or column lies from the common value.
	#
	#   pcWhich    Row or Rows for the row effects
	#   returns    a list of numbers, one per row or per column
	#   note       rows -1, 0, 2 and columns -2, 0, 2 for the 3 by 3 table above
	#   warning    Raises an error until Polish has run
	#   see        Common, Fitted
	def Effects(pcWhich)
		This._RequirePolished("Effects")
		_c_ = StzLower(ring_trim("" + pcWhich))
		if _c_ = "row" or _c_ = "rows"  return @aRowEffects  ok
		if _c_ = "col" or _c_ = "cols" or _c_ = "column" or _c_ = "columns"  return @aColEffects  ok
		stzraise("stzTukeyFit.Effects: :Row or :Col.")

	# Returns what is left of every cell after the fit is taken out.
	#
	#   returns    a list of rows, each a list of numbers, like the table
	#   note       all zero but the corner, which is 3, for the 3 by 3 table above
	#   warning    Raises an error until Polish has run
	#   see        Residual, Check, Diagnostics
	def Residuals()
		This._RequirePolished("Residuals")
		return @aResiduals

	# Returns the residual of one cell.
	#
	#   pnRow      the row, from 1
	#   pnCol      the column, from 1
	#   returns    a number
	#   warning    Raises an error until Polish has run
	#   see        Residuals, Fitted
	def Residual(pnRow, pnCol)
		This._RequirePolished("Residual")
		return @aResiduals[pnRow][pnCol]

	# Returns what the fit gives for one cell: common plus its row effect plus its column effect.
	#
	#   pnRow      the row, from 1
	#   pnCol      the column, from 1
	#   returns    a number
	#   note       17 for the corner of the 3 by 3 table above, whose cell is 20
	#   warning    Raises an error until Polish has run
	#   see        Residual, Common
	#@ aka  common + row effect + column effect
	def Fitted(pnRow, pnCol)
		This._RequirePolished("Fitted")
		return @nCommon + @aRowEffects[pnRow] + @aColEffects[pnCol]

	# Returns how many sweeps the polish made.
	#
	#   returns    a number
	#   warning    Raises an error until Polish has run
	#   see        IsConverged, SetMaxSweeps
	def Sweeps()
		This._RequirePolished("Sweeps")
		return @nSweeps

	# TRUE if the polish stopped because the change fell under the tolerance, not because it hit the cap.
	#
	#   returns    1 or 0
	#   warning    Raises an error until Polish has run
	#   see        Sweeps, SetTolerance
	def IsConverged()
		This._RequirePolished("IsConverged")
		return @bConverged

	# Returns the largest gap between a cell and its fit plus residual over the table, which is 0 when Data equals Fit plus Residual.
	#
	#   returns    a number, 0 up to rounding
	#   note       a check of the contract, not of the fit's quality
	#   warning    Raises an error until Polish has run
	#   see        Why, Residuals
	#@ aka  THE CONTRACT, CHECKED: the largest |data - (fit + residual)| over the table
	def Check()
		This._RequirePolished("Check")
		_nMax_ = 0
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nCols
				_d_ = fabs(@aRows[_i_][_j_] - (This.Fitted(_i_, _j_) + @aResiduals[_i_][_j_]))
				if _d_ > _nMax_  _nMax_ = _d_  ok
			next
		next
		return _nMax_

	# Returns the fourth-spread of all the residuals, the scale a coded display bands by.
	#
	#   returns    a number
	#   note       1 for the 5 by 3 table 14, 15, 14 / 7, 4, 7 / 8, 2, 10 / 15, 9, 10 / 0, 2, 10
	#   warning    Raises an error until Polish has run
	#   see        Residuals, Diagnostics
	#@ aka  the fourth-spread of the residuals, the scale a coded display bands by
	def ResidualScale()
		This._RequirePolished("ResidualScale")
		_a_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nCols
				_a_ + @aResiduals[_i_][_j_]
			next
		next
		return StzTukeySummaryQ(_a_).FourthSpread()

	# Returns the verdicts on the fit in the house rule shape: far-out residuals are errors, a polish stopped at its cap a warning.
	#
	#   pcSubject   what the table is called in the rows
	#   returns     a list of rows [ :rule, :subject, :where, :severity, :message ]; empty when all
	#               is well
	#   note        the rules are far_out and not_converged; when every other residual is 0 any
	#               residual counts as far out
	#   warning     Raises an error until Polish has run
	#   see         Residuals, StzTukeyReportQ
	#@ aka  the verdicts (TK4): a cell whose residual lies beyond Tukey's far-out fence on the residual batch -- hinge -+ 3 fourth-spreads, the rule the summary and the residual plot use -- is an error the fit does not describe; a polish that hit its cap is a warning
	def Diagnostics(pcSubject)
		This._RequirePolished("Diagnostics")
		_c_ = "" + pcSubject
		if _c_ = ""  _c_ = "table"  ok
		_a_ = []
		_aFlat_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nCols
				_aFlat_ + @aResiduals[_i_][_j_]
			next
		next
		_aH_ = StzEngineTukeyFourths(_aFlat_)
		_nS_ = _aH_[2] - _aH_[1]
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nCols
				_r_ = @aResiduals[_i_][_j_]
				# A ZERO SPREAD: every other residual is 0, the fences collapse onto
				# the hinge, and any residual at all is beyond them -- an exactly
				# additive table with one wild cell lands here (4 x 4 + 1000, 2026-09-26)
				if _nS_ = 0 and _r_ != 0
					_a_ + [ :rule = "far_out", :subject = _c_, :where = "cell (" + _i_ + ", " + _j_ + ")", :severity = :error,
					        :message = "residual " + _FfNum(_r_, 4) + " on a residual batch whose fourth-spread is 0 -- every other cell sits on the fit, so any residual is beyond the far-out fence" ]
				ok
				if _nS_ > 0 and (_r_ < _aH_[1] - 3 * _nS_ or _r_ > _aH_[2] + 3 * _nS_)
					_nK_ = (_r_ - _aH_[2]) / _nS_
					if _r_ < _aH_[1]  _nK_ = (_aH_[1] - _r_) / _nS_  ok
					_a_ + [ :rule = "far_out", :subject = _c_, :where = "cell (" + _i_ + ", " + _j_ + ")", :severity = :error,
					        :message = "residual " + _FfNum(_r_, 4) + " lies " + _FfNum(_nK_, 2) +
					        " fourth-spread(s) past the hinge, beyond the far-out fence at 3" ]
				ok
			next
		next
		if NOT @bConverged
			_a_ + [ :rule = "not_converged", :subject = _c_, :where = "the polish", :severity = :warning,
			        :message = "the polish stopped at the cap of " + @nSweeps + " sweep(s) without converging to " + @nEps ]
		ok
		return _a_

	# Returns one sentence on the fit: the common value, the sweeps, whether it converged, and how well Data equals Fit plus Residual.
	#
	#   returns    a text; before Polish it says the table is not yet polished
	#   see        Check, Sweeps
	def Why()
		if NOT @bPolished
			return "a two-way table of " + @nRows + " x " + @nCols + ", not yet polished"
		ok
		_c_ = "a median polish of " + @nRows + " x " + @nCols + ": common " + _FfNum(@nCommon, 4) +
			", " + @nSweeps + " sweep(s), "
		if @bConverged  _c_ += "converged"  else  _c_ += "stopped at the cap"  ok
		return _c_ + "; Data = Fit + Residual holds to " + _FfNum(This.Check(), 9)

#-- the resistant line -----------------------------------------------------

# Fits Tukey's resistant three-group line through paired values, so one wild point barely moves it.
#
# The line is R's line(): the points are split into three groups by x, the slope comes from the
# medians of the outer groups, and passes over the residuals refine it. Call Fit first; Slope,
# Intercept, Iterations and Residuals raise an error until then. Fit(n) matches R's iter = n + 1.
# Known defect: points that all share one x give slope 0 and intercept 0 without an error.
#
#   receiver   o1 = new stzTukeyLine([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ], [ 2.1, 3.9, 6.2,
#              7.8, 10.1, 12.2, 13.8, 16.1, 18.0, 19.9, 22.2, 24.1 ]); o1.Fit(0)
#   example    ? o1.Slope()
#              #--> 2.00
#              ? o1.Iterations()
#              #--> 0
#   see        stzTukeyFit, stzTukeySmoother
class stzTukeyLine from stzObject

	@aX = []
	@aY = []
	@nSlope = 0
	@nIntercept = 0
	@nIterations = 0
	@bFitted = 0

	# Builds a resistant line to be fitted through paired values, x against y.
	#
	#   paX        the x values, a list of numbers
	#   paY        the y values, a list of numbers of the same length, at least three points
	#   returns    nothing; the object is built
	#   see        Fit, Slope
	def init(paX, paY)
		if NOT isList(paX) or NOT isList(paY) or ring_len(paX) != ring_len(paY) or ring_len(paX) < 3
			stzraise("stzTukeyLine: two lists of the same length, at least three points.")
		ok
		@aX = paX
		@aY = paY

	# Fits Tukey's three-group line, then improves it with passes over the residuals, as R's line does.
	#
	#   pnIterations   the number of passes over the residuals after the first fit
	#   returns        the line itself, so calls chain
	#   note           on x 1 to 12 with y near twice x it gives slope 2.0056 and intercept 0.0444
	#                  after 5 passes, and one wild y barely moves it
	#   warning        Fit(0) equals R's line with iter 1 and Fit(1) equals iter 2, so the count
	#                  here is one less than R's; points that all share one x give slope 0 and
	#                  intercept 0 with no error, which is a defect
	#   see            Slope, Intercept, Residuals
	#@ aka  Tukey's three-group line, with pnIterations passes over the residuals
	def Fit(pnIterations)
		_n_ = pnIterations
		if NOT isNumber(_n_) or _n_ < 0  _n_ = 5  ok
		_a_ = StzEngineTukeyLine(@aX, @aY, _n_)
		if NOT isList(_a_) or ring_len(_a_) < 3
			stzraise("stzTukeyLine.Fit: the engine refused the points (fewer than three, or the outer groups share an x).")
		ok
		@nSlope = _a_[1]
		@nIntercept = _a_[2]
		@nIterations = _a_[3]
		@bFitted = 1
		return This

		def FitQ(pnIterations)
			return This.Fit(pnIterations)

	def _RequireFitted(pcWhat)
		if NOT @bFitted
			stzraise("stzTukeyLine." + pcWhat + ": Fit() first.")
		ok

	# Returns the slope of the fitted line.
	#
	#   returns    a number
	#   warning    Raises an error until Fit has run
	#   see        Intercept, Fit
	def Slope()
		This._RequireFitted("Slope")
		return @nSlope

	# Returns the intercept of the fitted line, its y at x equal to 0.
	#
	#   returns    a number
	#   warning    Raises an error until Fit has run
	#   see        Slope, Fit
	def Intercept()
		This._RequireFitted("Intercept")
		return @nIntercept

	# Returns how many residual passes the last Fit made.
	#
	#   returns    a number
	#   warning    Raises an error until Fit has run
	#   see        Fit
	def Iterations()
		This._RequireFitted("Iterations")
		return @nIterations

	# Returns each y minus the line's value at its x, in the order given.
	#
	#   returns    a list of numbers
	#   warning    Raises an error until Fit has run
	#   see        Slope, Intercept
	def Residuals()
		This._RequireFitted("Residuals")
		_a_ = []
		_n_ = ring_len(@aX)
		for _i_ = 1 to _n_
			_a_ + (@aY[_i_] - (@nIntercept + @nSlope * @aX[_i_]))
		next
		return _a_

	# Returns one sentence that gives the fitted equation and the number of passes.
	#
	#   returns    a text; before Fit it says the line is not yet fitted
	#   see        Fit
	def Why()
		if NOT @bFitted
			return "a resistant line over " + ring_len(@aX) + " points, not yet fitted"
		ok
		return "Tukey's three-group line over " + ring_len(@aX) + " points: y = " +
			_FfNum(@nIntercept, 4) + " + " + _FfNum(@nSlope, 4) + " x, after " + @nIterations + " residual pass(es)"

#-- the one-way fit ---------------------------------------------------------

# Fits groups of numbers by one-way median polish: a common value, an effect per group and a residual per value.
#
# The common value is the median of the group medians, each effect is a group's median minus it, and
# each residual is a value minus its group's median. Diagnostics does not need Polish: it warns when
# the spread of the groups grows with their level, with the power to try.
#
#   receiver   o1 = new stzTukeyOneWay([ [ 1, 2, 3 ], [ 4, 5, 9 ], [ 10, 12, 20, 30 ] ]);
#              o1.Polish()
#   example    ? o1.Common()
#              #--> 5
#              ? @@( o1.Effects() )
#              #--> [ -3, 0, 11 ]
#   see        stzTukeyFit, stzTukeyReexpression, stzTukeySummary
class stzTukeyOneWay from stzObject

	@aGroups = []
	@nCommon = 0
	@aEffects = []
	@aResiduals = []
	@bPolished = 0

	# Builds a one-way table of groups of numbers, to be fitted by median polish.
	#
	#   paGroups   at least two groups, each a non-empty list of numbers, of lengths that may differ
	#   returns    nothing; the object is built
	#   see        Polish, NumberOfGroups
	def init(paGroups)
		if NOT isList(paGroups) or ring_len(paGroups) < 2
			stzraise("stzTukeyOneWay: give at least two groups, each a list of numbers.")
		ok
		_n_ = ring_len(paGroups)
		for _i_ = 1 to _n_
			if NOT isList(paGroups[_i_]) or ring_len(paGroups[_i_]) = 0
				stzraise("stzTukeyOneWay: group " + _i_ + " is not a non-empty list of numbers.")
			ok
		next
		@aGroups = paGroups

	# Returns how many groups the table has.
	#
	#   returns    a number
	#   see        Polish
	def NumberOfGroups()
		return ring_len(@aGroups)

	# Fits the groups by medians: a common value, an effect per group and a residual per value.
	#
	#   returns    the fit itself, so calls chain
	#   note       for 1, 2, 3 / 4, 5, 9 / 10, 12, 20, 30 the common value is 5 and the effects are
	#              -3, 0 and 11
	#   warning    Common, Effects, Residuals and Check raise an error until Polish has run
	#   see        Common, Effects, Residuals, Check
	def Polish()
		_n_ = ring_len(@aGroups)
		_aMed_ = []
		for _i_ = 1 to _n_
			_aMed_ + StzEngineStatsMedian(StzEngineStatsCreate(@aGroups[_i_]))
		next
		@nCommon = StzEngineStatsMedian(StzEngineStatsCreate(_aMed_))
		@aEffects = []
		@aResiduals = []
		for _i_ = 1 to _n_
			@aEffects + (_aMed_[_i_] - @nCommon)
			_aR_ = []
			_m_ = ring_len(@aGroups[_i_])
			for _k_ = 1 to _m_
				_aR_ + (@aGroups[_i_][_k_] - _aMed_[_i_])
			next
			@aResiduals + _aR_
		next
		@bPolished = 1
		return This

	def _RequirePolished(pcWhat)
		if NOT @bPolished
			stzraise("stzTukeyOneWay." + pcWhat + ": Polish() first.")
		ok

	# Returns the median of the group medians.
	#
	#   returns    a number
	#   note       5 for the groups above
	#   warning    Raises an error until Polish has run
	#   see        Effects, Polish
	def Common()
		This._RequirePolished("Common")
		return @nCommon

	# Returns each group's median minus the common value.
	#
	#   returns    a list of numbers, one per group
	#   note       -3, 0, 11 for the groups above
	#   warning    Raises an error until Polish has run
	#   see        Common, Residuals
	def Effects()
		This._RequirePolished("Effects")
		return @aEffects

	# Returns each value minus the median of its group.
	#
	#   returns    a list of lists, one per group, in the order given
	#   note       [ -1, 0, 1 ], [ -1, 0, 4 ], [ -6, -4, 4, 14 ] for the groups above
	#   warning    Raises an error until Polish has run
	#   see        Effects, Check
	def Residuals()
		This._RequirePolished("Residuals")
		return @aResiduals

	# Returns the largest gap between a value and common plus effect plus residual, which is 0 when Data equals Fit plus Residual.
	#
	#   returns    a number, 0 up to rounding
	#   warning    Raises an error until Polish has run
	#   see        Why, Residuals
	#@ aka  THE CONTRACT, CHECKED: the largest |value - (common + effect + residual)|
	def Check()
		This._RequirePolished("Check")
		_nMax_ = 0
		_n_ = ring_len(@aGroups)
		for _i_ = 1 to _n_
			_m_ = ring_len(@aGroups[_i_])
			for _k_ = 1 to _m_
				_d_ = fabs(@aGroups[_i_][_k_] - (@nCommon + @aEffects[_i_] + @aResiduals[_i_][_k_]))
				if _d_ > _nMax_  _nMax_ = _d_  ok
			next
		next
		return _nMax_

	# Returns a warning when the spread of the groups grows with their level, from the slope of log fourth-spread on log median.
	#
	#   pcSubject   what the groups are called in the rows
	#   returns     a list of rows [ :rule, :subject, :where, :severity, :message ]; empty when the
	#               slope is within 0.5
	#   note        spreads that double with the level, as 10 to 12, 20 to 24, 40 to 48 and 80 to
	#               96, give slope 1 and the power 0, the log
	#   warning     it does not need Polish; the rule is spread_tracks_level and the message gives
	#               the suggested power
	#   see         StzTukeySpreadLevel, stzTukeyReexpression
	#@ aka  the verdict (TK4): spread that tracks level, as the slope of log spread on log level over the groups, past the measured threshold
	def Diagnostics(pcSubject)
		_c_ = "" + pcSubject
		if _c_ = ""  _c_ = "groups"  ok
		_a_ = []
		_r_ = StzTukeySpreadLevel(@aGroups)
		if _r_[:ok] and fabs(_r_[:slope]) > StzTukeySpreadLevelThreshold()
			_a_ + [ :rule = "spread_tracks_level", :subject = _c_, :where = "across " + ring_len(@aGroups) + " group(s)", :severity = :warning,
			        :message = "log-spread on log-level slope " + _FfNum(_r_[:slope], 4) + " (threshold " +
			        StzTukeySpreadLevelThreshold() + "); try power " + _FfNum(_r_[:power], 2) + " (" + StzTukeyPowerName(_r_[:power]) + ")" ]
		ok
		return _a_

	# Returns one sentence on the fit: the common value, the effects, and how well Data equals Fit plus Residual.
	#
	#   returns    a text; before Polish it says the table is not yet polished
	#   see        Check, Common
	def Why()
		if NOT @bPolished
			return "a one-way table of " + ring_len(@aGroups) + " group(s), not yet polished"
		ok
		return "a one-way median polish of " + ring_len(@aGroups) + " group(s): common " +
			_FfNum(@nCommon, 4) + ", effects " + @@(@aEffects) + "; Data = Fit + Residual holds to " + _FfNum(This.Check(), 9)

#-- the smoothers, R's 3-family and 4253H ----------------------------------------
/*
	Tukey's resistant smoothers, R's stats::smooth transcribed in eda.zig and
	verified against R 4.5.1's own output (MATH-R-ORACLE-01, answered
	2026-09-26; the transcript is base/test/math/oracle/r_smooth.txt):

	    oS = StzTukeySmootherQ([ 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2 ])
	    ? @@( oS.Smooth3R() )
	    #--> [ 3, 3, 3, 6, 6, 4, 4, 4, 2, 2, 2 ]

	Kinds: "3" (running median of three), "3R" (repeated to convergence),
	"S" (splitting of two-flats), "3RSS", "3RS3R" (R's default), "3RSR".
	The end rule is Tukey's by default (:Copy on request); SetSplitEnds is
	R's do.ends. Twice(kind) is R's twiceit: the smooth of the rough added
	back. Hanning() and Smooth4253H() are this plane's, with the ends
	COPIED -- their windows are R's per-window median() and filter(), and
	their end treatment is named here rather than borrowed.
*/

# Smooths a series resistantly with Tukey's medians-of-three family, Hanning and 4253H, and spots a level shift.
#
# The kinds 3, 3R, S, 3RSS, 3RS3R and 3RSR are R's smooth, run in the engine; on 4, 1, 3, 6, 6, 4,
# 1, 6, 2, 4, 2 all six equal R 4.5.1's output. Hanning and 4253H copy their ends, and 4253H equals
# a hand computation. Rough returns data minus smooth, and Twice adds the smooth of the rough back.
# ChangePoint is a verdict with a measured threshold, made from 40 values. A series of fewer than 4
# numbers is refused.
#
#   receiver   o1 = new stzTukeySmoother([ 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2 ])
#   example    ? @@( o1.Smooth3R() )
#              #--> [ 3, 3, 3, 6, 6, 4, 4, 4, 2, 2, 2 ]
#              ? @@( o1.WindowMedians(3) )
#              #--> [ 3, 3, 6, 6, 4, 4, 2, 4, 2 ]
#   see        stzTukeySummary, stzTukeyLine, stzTukeyFit
class stzTukeySmoother from stzObject

	@aNumbers = []
	@cEndRule = "tukey"
	@bSplitEnds = 0

	# Builds a smoother over a series of numbers, kept in the order given, with Tukey's end rule.
	#
	#   paNumbers   the series, a list of at least four numbers
	#   returns     nothing; the object is built
	#   see         Smooth, Numbers
	def init(paNumbers)
		if NOT isList(paNumbers) or ring_len(paNumbers) < 4
			stzraise("stzTukeySmoother: give at least four numbers -- below four, R's smooth reads memory it never set, and this face refuses rather than imitate it.")
		ok
		_n_ = ring_len(paNumbers)
		for _i_ = 1 to _n_
			if NOT isNumber(paNumbers[_i_])
				stzraise("stzTukeySmoother: item " + _i_ + " is not a number.")
			ok
		next
		@aNumbers = paNumbers

	# Returns the series as it was given.
	#
	#   returns    a list of numbers
	#   see        Count, Smooth
	def Numbers()
		return @aNumbers

	# Returns how many values the series holds.
	#
	#   returns    a number
	#   see        Numbers
	def Count()
		return ring_len(@aNumbers)

	# Chooses how the two end values of a smooth are treated: Tukey's end-point rule, or copied from the data.
	#
	#   pcRule     Tukey or Copy, in any case
	#   returns    the smoother itself, so calls chain
	#   note       on 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2 the first value of Smooth3 is 3 under Tukey
	#              and 4 under Copy
	#   see        EndRule, Smooth3
	def SetEndRule(pcRule)
		_c_ = StzLower(ring_trim("" + pcRule))
		if _c_ = "tukey"
			@cEndRule = "tukey"
		but _c_ = "copy"
			@cEndRule = "copy"
		else
			stzraise("stzTukeySmoother.SetEndRule: :Tukey (the end-point rule) or :Copy -- '" + pcRule + "' is neither.")
		ok
		return This

		def SetEndRuleQ(pcRule)
			return This.SetEndRule(pcRule)

	# Returns the end rule in force.
	#
	#   returns    tukey or copy
	#   see        SetEndRule
	def EndRule()
		return @cEndRule

	# Switches on or off the splitting of two-flats at the ends too, as R's do.ends.
	#
	#   pbOn       1 to split at the ends as well, 0 for not, the default
	#   returns    the smoother itself, so calls chain
	#   note       it changed nothing on the series 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2
	#   see        Split, Smooth3RSS
	#@ aka  R's do.ends: split the two-flats at the ends too
	def SetSplitEnds(pbOn)
		@bSplitEnds = 0
		if pbOn  @bSplitEnds = 1  ok
		return This

	def _EndRuleCode()
		if @cEndRule = "copy"  return 1  ok
		return 2

	def _KindCode(pcKind)
		_c_ = StzUpper(ring_trim("" + pcKind))
		_ac_ = StzTukeySmoothKinds()
		for _i_ = 1 to ring_len(_ac_)
			if _ac_[_i_] = _c_  return _i_ - 1  ok
		next
		stzraise("stzTukeySmoother: the kinds are " + @@(_ac_) + " -- '" + pcKind + "' is none of them.")

	# Returns the smooth of a given kind, as R's smooth does with the end rule and the split-ends setting in force.
	#
	#   pcKind     3, 3R, S, 3RSS, 3RS3R or 3RSR, in any case
	#   returns    a list of numbers of the same length as the series
	#   note       on 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2 kind 3R gives 3, 3, 3, 6, 6, 4, 4, 4, 2, 2, 2
	#              and all six kinds equal R 4.5.1's
	#   see        Smooth3R, Twice, Rough
	#@ aka  the smooth of the given kind, as R's smooth(x, kind, endrule, do.ends)
	def Smooth(pcKind)
		_a_ = StzEngineTukeySmooth(@aNumbers, This._KindCode(pcKind), This._EndRuleCode(), @bSplitEnds, 0)
		if NOT isList(_a_)
			stzraise("stzTukeySmoother.Smooth: the engine refused the series.")
		ok
		return _a_

	# Returns the running median of three, taken once over the series.
	#
	#   returns    a list of numbers
	#   note       3, 3, 3, 6, 6, 4, 4, 2, 4, 2, 2 for 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2
	#   see        Smooth3R, Smooth
	def Smooth3()
		return This.Smooth("3")
	# Returns the running median of three repeated until nothing changes.
	#
	#   returns    a list of numbers
	#   note       3, 3, 3, 6, 6, 4, 4, 4, 2, 2, 2 for 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2
	#   see        Smooth3, Smooth3RS3R
	def Smooth3R()
		return This.Smooth("3R")
	# Returns the series with its flat pairs of equal values split, Tukey's S smoother.
	#
	#   returns    a list of numbers
	#   note       it leaves 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2 unchanged, as R does
	#   see        Smooth3RSS, SetSplitEnds
	def Split()
		return This.Smooth("S")
	# Returns 3R followed by two splitting passes.
	#
	#   returns    a list of numbers
	#   note       3, 3, 3, 3, 4, 4, 4, 4, 2, 2, 2 for 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2
	#   see        Smooth3RS3R, Split
	def Smooth3RSS()
		return This.Smooth("3RSS")
	# Returns 3R, a splitting pass, then 3R again, R's default smoother.
	#
	#   returns    a list of numbers
	#   note       3, 3, 3, 3, 4, 4, 4, 4, 2, 2, 2 for 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2
	#   see        Smooth3RSR, Twice
	def Smooth3RS3R()
		return This.Smooth("3RS3R")
	# Returns 3R then splitting passes repeated until nothing changes.
	#
	#   returns    a list of numbers
	#   note       the same as 3RS3R on 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2
	#   see        Smooth3RS3R
	def Smooth3RSR()
		return This.Smooth("3RSR")

	# Returns the smooth of a kind with the smooth of its rough added back, as R's twiceit.
	#
	#   pcKind     3, 3R, S, 3RSS, 3RS3R or 3RSR, in any case
	#   returns    a list of numbers
	#   see        Smooth, Rough
	#@ aka  twicing, R's twiceit: the same smoother on the rough, added back
	def Twice(pcKind)
		_a_ = StzEngineTukeySmooth(@aNumbers, This._KindCode(pcKind), This._EndRuleCode(), @bSplitEnds, 1)
		if NOT isList(_a_)
			stzraise("stzTukeySmoother.Twice: the engine refused the series.")
		ok
		return _a_

	# Returns each value minus its smooth, the part the smooth leaves out, so that Data equals Smooth plus Rough.
	#
	#   pcKind     3, 3R, S, 3RSS, 3RS3R or 3RSR, in any case
	#   returns    a list of numbers
	#   note       1, -2, 0, 0, 0, 0, -3, 2, 0, 2, 0 for kind 3R on 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2
	#   see        Smooth, Twice
	#@ aka  the rough: data minus smooth, the contract Data = Smooth + Rough
	def Rough(pcKind)
		_aS_ = This.Smooth(pcKind)
		_a_ = []
		for _i_ = 1 to ring_len(@aNumbers)
			_a_ + (@aNumbers[_i_] - _aS_[_i_])
		next
		return _a_

	# Returns the series smoothed by the weights 1/4, 1/2 and 1/4, with the two end values copied.
	#
	#   returns    a list of numbers
	#   note       the second value of 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2 becomes 2.25
	#   see        Smooth4253H, WindowMedians
	def Hanning()
		return StzEngineTukeyHanning(@aNumbers)

	# Returns the 4253H smooth: medians of 4 and 2, then 5, then 3, then Hanning, with the ends copied at every stage.
	#
	#   returns    a list of numbers
	#   note       4, 4, 4.19, 4.56, 4.75, 4.56, 4.19, 4, 3.75, 3, 2 for 4, 1, 3, 6, 6, 4, 1, 6, 2,
	#              4, 2, as a hand computation gives
	#   warning    needs at least seven values and raises an error with fewer
	#   see        Smooth4253HTwice, Hanning
	#@ aka  4253H: medians of 4 and 2, then 5, then 3, then Hanning; ends copied at every stage
	def Smooth4253H()
		if ring_len(@aNumbers) < 7
			stzraise("stzTukeySmoother.Smooth4253H: seven values at least -- the 4 and 2 stages need them.")
		ok
		return StzEngineTukeySmooth4253H(@aNumbers, 0)

	# Returns the 4253H smooth with the smooth of its rough added back.
	#
	#   returns    a list of numbers
	#   warning    needs at least seven values and raises an error with fewer
	#   see        Smooth4253H
	def Smooth4253HTwice()
		if ring_len(@aNumbers) < 7
			stzraise("stzTukeySmoother.Smooth4253HTwice: seven values at least.")
		ok
		return StzEngineTukeySmooth4253H(@aNumbers, 1)

	# Returns the median of every run of consecutive values of a given length, with no end values.
	#
	#   pnK        the span, from 1 up to the count
	#   returns    a list of numbers, count minus span plus one of them
	#   note       with span 3 on 4, 1, 3, 6, 6, 4, 1, 6, 2, 4, 2 it gives 3, 3, 6, 6, 4, 4, 2, 4, 2
	#   see        Smooth3, Hanning
	#@ aka  the medians of every window of k values, n - k + 1 of them (no ends)
	def WindowMedians(pnK)
		if NOT isNumber(pnK) or pnK < 1 or pnK > ring_len(@aNumbers)
			stzraise("stzTukeySmoother.WindowMedians: a span from 1 to the count.")
		ok
		return StzEngineTukeyWindowMedians(@aNumbers, pnK)

	# Looks for a level shift: the largest contrast between medians of ten values either side of a cut, over the spread of the steps.
	#
	#   returns    a hash list with the keys contrast, at, scale, threshold, fires, judged and
	#              because
	#   note       a step of 6 in the middle of 60 values gives contrast 3 at index 30, past the
	#              threshold 1.8
	#   warning    a verdict is made from 40 values; under that judged is 0 and because says so; a
	#              series with no spread in its differences is not judged either
	#   see        Diagnostics, Why
	#@ aka  -- the change point, a verdict with its threshold (plan row 9) --------------
	def ChangePoint()
		_n_ = ring_len(@aNumbers)
		_w_ = StzTukeyChangePointWindow()
		_r_ = [ :contrast = 0, :at = 0, :scale = 0, :threshold = StzTukeyChangePointThreshold(), :fires = 0, :judged = 0,
		        :because = "" ]
		if _n_ < StzTukeyChangePointMinCount()
			_r_[:because] = "a change-point verdict needs " + StzTukeyChangePointMinCount() + " values; the threshold was measured from there"
			return _r_
		ok
		_aDx_ = []
		for _i_ = 1 to _n_ - 1  _aDx_ + (@aNumbers[_i_ + 1] - @aNumbers[_i_])  next
		_nF_ = StzTukeySummaryQ(_aDx_).FourthSpread()
		_r_[:scale] = _nF_
		if _nF_ <= 0
			_r_[:because] = "the consecutive differences have no spread; a step in a flat series is not a change point but a jump the rough shows"
			return _r_
		ok
		_nMax_ = 0
		_nAt_ = 0
		for _t_ = _w_ to _n_ - _w_
			_aB_ = []
			_aA_ = []
			for _i_ = _t_ - _w_ + 1 to _t_  _aB_ + @aNumbers[_i_]  next
			for _i_ = _t_ + 1 to _t_ + _w_  _aA_ + @aNumbers[_i_]  next
			_d_ = fabs(StzEngineStatsMedian(StzEngineStatsCreate(_aA_)) - StzEngineStatsMedian(StzEngineStatsCreate(_aB_))) / _nF_
			if _d_ > _nMax_
				_nMax_ = _d_
				_nAt_ = _t_ + 1
			ok
		next
		_r_[:contrast] = _nMax_
		_r_[:at] = _nAt_
		_r_[:judged] = 1
		if _nMax_ > StzTukeyChangePointThreshold()  _r_[:fires] = 1  ok
		_r_[:because] = "the medians of " + _w_ + " values either side of index " + _nAt_ + " differ by " + _FfNum(_nMax_, 3) +
			" spread(s) of the consecutive differences (threshold " + StzTukeyChangePointThreshold() + ")"
		return _r_

	# Returns a warning when a level shift is found, naming where and by how much.
	#
	#   pcSubject   what the series is called in the rows
	#   returns     a list of rows [ :rule, :subject, :where, :severity, :message ]; empty when none
	#               is found or the series is too short to judge
	#   note        the rule is level_shift
	#   see         ChangePoint, StzTukeyReportQ
	#@ aka  the verdict in the house shape: a level shift is a warning naming where and by how much
	def Diagnostics(pcSubject)
		_c_ = "" + pcSubject
		if _c_ = ""  _c_ = "series"  ok
		_a_ = []
		_r_ = This.ChangePoint()
		if _r_[:fires]
			_a_ + [ :rule = "level_shift", :subject = _c_, :where = "index " + _r_[:at], :severity = :warning,
			        :message = _r_[:because] ]
		ok
		return _a_

	# Returns one sentence on the series: the largest rough under 3RS3R, the kinds available and the change-point verdict.
	#
	#   returns    a text
	#   see        ChangePoint, Smooth
	def Why()
		_aS_ = This.Smooth("3RS3R")
		_nMax_ = 0
		for _i_ = 1 to ring_len(@aNumbers)
			if fabs(@aNumbers[_i_] - _aS_[_i_]) > _nMax_  _nMax_ = fabs(@aNumbers[_i_] - _aS_[_i_])  ok
		next
		_c_ = "a Tukey smoother over " + ring_len(@aNumbers) + " value(s), end rule " + @cEndRule +
			": under 3RS3R the largest rough is " + _FfNum(_nMax_, 4) + "; kinds " + @@(StzTukeySmoothKinds()) +
			", Hanning and 4253H with copied ends"
		_r_ = This.ChangePoint()
		if _r_[:judged]
			if _r_[:fires]
				_c_ += "; a level shift at index " + _r_[:at] + " (contrast " + _FfNum(_r_[:contrast], 3) + " past " + _r_[:threshold] + ")"
			else
				_c_ += "; no level shift (largest contrast " + _FfNum(_r_[:contrast], 3) + ", threshold " + _r_[:threshold] + ")"
			ok
		else
			_c_ += "; change point unjudged: " + _r_[:because]
		ok
		return _c_

#-- re-expression, measured ---------------------------------------------------

# Measures whether a two-way table needs a change of scale, and recommends the power that makes it additive.
#
# Each rung of the ladder -1, -0.5, 0, 0.5, 1, 2 is tried and the slope of the residuals on
# comparison values is measured; a recommendation fires only when the slope at power 1 passes the
# threshold 0.5. A table that is the product of a row factor and a column factor gives the log.
# Known defect: a table holding a zero cannot take the negative powers or the log, and Recommend can
# then fire with power 1, as is.
#
#   receiver   o1 = new stzTukeyReexpression([ [ 1, 2, 4 ], [ 2, 4, 8 ], [ 4, 8, 16 ], [ 8, 16, 32 ]
#              ])
#   example    ? o1.Recommend()[:name]
#              #--> log
#              ? o1.Recommend()[:fires]
#              #--> 1
#   see        stzTukeyFit, stzTukeyOneWay
class stzTukeyReexpression from stzObject

	@aRows = []
	@aLadder = []          # [ [ power, slope, residual scale, ok ], ... ]
	@bEvaluated = 0

	# Builds a two-way table whose need for a change of scale is to be measured.
	#
	#   paRows     the table as a list of rows, each a list of numbers
	#   returns    nothing; the object is built
	#   see        Ladder, Recommend
	def init(paRows)
		if NOT isList(paRows) or ring_len(paRows) = 0 or NOT isList(paRows[1])
			stzraise("stzTukeyReexpression: give the two-way table as a list of rows.")
		ok
		@aRows = paRows

	# Returns the measured limit that the slope at power 1 must pass for a re-expression to be recommended.
	#
	#   returns    a number, 0.5
	#   see        Recommend
	#@ aka  the measured threshold the engine carries: a recommendation fires only when |slope at power 1| exceeds it
	def Threshold()
		return StzEngineTukeyThreshold()

	# Returns the slope of the residuals on the comparison values of the table as it stands, and the power it suggests.
	#
	#   returns    a hash list with the keys slope, intercept, power and ok
	#   note       a table of 1, 2, 4 / 2, 4, 8 / 4, 8, 16 / 8, 16, 32, a product of a row and a
	#              column factor, gives slope 1 and power 0
	#   see        Ladder, Recommend
	#@ aka  the non-additivity slope of the table as it stands: residuals on comparison values, with the suggested power 1 - slope
	def NonAdditivity()
		_a_ = StzEngineTukeyNonAdditivity(@aRows)
		if NOT isList(_a_) or ring_len(_a_) < 4
			stzraise("stzTukeyReexpression.NonAdditivity: the engine refused the table.")
		ok
		return [ :slope = _a_[1], :intercept = _a_[2], :power = _a_[3], :ok = _a_[4] ]

	# Returns every rung of the ladder of powers, from -1 to 2, with the slope and the residual scale found after raising the table to it.
	#
	#   returns    a list of rows [ power, slope, residual scale, ok ]; ok is 0 for a rung that
	#              cannot be taken
	#   note       for the product table above the log rung, power 0, has slope 0 and residual scale
	#              0
	#   warning    the engine is crossed once and the answer kept
	#   see        Rung, LadderTable, Recommend
	#@ aka  EVERY RUNG IN ONE CROSSING: [ [ power, slope, residual scale, ok ], ... ]
	def Ladder()
		if NOT @bEvaluated
			@aLadder = StzEngineTukeyLadder(@aRows, StzTukeyLadderPowers())
			if NOT isList(@aLadder) or ring_len(@aLadder) = 0
				stzraise("stzTukeyReexpression.Ladder: the engine refused the table.")
			ok
			@bEvaluated = 1
		ok
		return @aLadder

	# Returns one row of the ladder.
	#
	#   pnPower    one of -1, -0.5, 0, 0.5, 1 or 2
	#   returns    a list [ power, slope, residual scale, ok ]
	#   see        Ladder, Recommend
	def Rung(pnPower)
		_a_ = This.Ladder()
		_n_ = ring_len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][1] = pnPower  return _a_[_i_]  ok
		next
		stzraise("stzTukeyReexpression.Rung: " + pnPower + " is not a rung of the ladder " + @@(StzTukeyLadderPowers()) + ".")

	# Returns the verdict on the table: the power with the flattest slope when the slope at power 1 passes the threshold, else leave it as it is.
	#
	#   returns    a hash list with the keys power, name, slope, fires and evidence
	#   note       the product table gives power 0, log, fires 1; an additive table 1, 2, 3 / 2, 3,
	#              4 / 3, 4, 5 / 4, 5, 6 gives power 1, fires 0
	#   warning    when the table holds a zero the negative powers and the log cannot be taken, and
	#              the verdict can come out as fires 1 with power 1, as is, which says to re-express
	#              and to leave it at once; seen on two tables
	#   see        Ladder, Threshold, Diagnostics
	#@ aka  THE RECOMMENDATION, AS A VERDICT WITH ITS EVIDENCE: [ :power, :name, :slope, :evidence, :fires ] fires = 0 means "leave it alone", and the slope at power 1 says why
	def Recommend()
		_a_ = This.Ladder()
		_r1_ = This.Rung(1)
		_nT_ = This.Threshold()
		if _r1_[4] = 0
			stzraise("stzTukeyReexpression.Recommend: the table as it stands could not be polished.")
		ok
		if fabs(_r1_[2]) <= _nT_
			return [ :power = 1, :name = "as is", :slope = _r1_[2], :fires = 0,
			         :evidence = "residuals on comparison values slope " + _FfNum(_r1_[2], 4) +
			                     " at power 1, within the threshold " + _FfNum(_nT_, 2) + ": leave it" ]
		ok
		_best_ = 0
		_n_ = ring_len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][4] = 0  loop  ok
			if _best_ = 0 or fabs(_a_[_i_][2]) < fabs(_a_[_best_][2])  _best_ = _i_  ok
		next
		_p_ = _a_[_best_][1]
		return [ :power = _p_, :name = StzTukeyPowerName(_p_), :slope = _a_[_best_][2], :fires = 1,
		         :evidence = "residuals on comparison values slope " + _FfNum(_r1_[2], 4) +
		                     " at power 1, past the threshold " + _FfNum(_nT_, 2) + "; flattest at power " +
		                     _p_ + " (" + StzTukeyPowerName(_p_) + "), slope " + _FfNum(_a_[_best_][2], 4) ]

	# Returns the ladder as a text table with one line per rung, a star on the recommended one and the evidence beneath.
	#
	#   returns    a text of several lines
	#   see        Ladder, Recommend
	#@ aka  the diagnostics in the house rule shape, for stzRuleReport (plan 2.6) the ladder as a table: power, its name, the slope, the residual scale
	def LadderTable()
		_a_ = This.Ladder()
		_r_ = This.Recommend()
		_c_ = "  power  re-expression             slope  residual scale" + char(10)
		for _i_ = 1 to ring_len(_a_)
			_cMark_ = " "
			if _r_[:fires] and _a_[_i_][1] = _r_[:power]  _cMark_ = "*"  ok
			if NOT _r_[:fires] and _a_[_i_][1] = 1  _cMark_ = "*"  ok
			if _a_[_i_][4] = 0
				_c_ += "  " + _TkPad(_FfNum(_a_[_i_][1], 1), 5) + "  " + _TkPad(StzTukeyPowerName(_a_[_i_][1]), 22) + "  (cannot be taken)" + char(10)
			else
				_c_ += _cMark_ + " " + _TkPad(_FfNum(_a_[_i_][1], 1), 5) + "  " + _TkPad(StzTukeyPowerName(_a_[_i_][1]), 22) + "  " +
					_TkPad(_FfNum(_a_[_i_][2], 4), 7) + "  " + _FfNum(_a_[_i_][3], 4) + char(10)
			ok
		next
		_c_ += "  * " + _r_[:evidence] + char(10)
		return _c_

	# Returns a warning when the table is not additive enough, with the evidence and the power to try.
	#
	#   pcSubject   what the table is called in the rows
	#   returns     a list of rows [ :rule, :subject, :where, :severity, :message ]; empty when the
	#               table is left as it is
	#   note        the rule is non_additive
	#   see         Recommend, StzTukeyReportQ
	def Diagnostics(pcSubject)
		_c_ = "" + pcSubject
		if _c_ = ""  _c_ = "table"  ok
		_r_ = This.Recommend()
		_a_ = []
		if _r_[:fires]
			_a_ + [ :rule = "non_additive", :subject = _c_, :where = "residuals on comparison values",
			        :severity = :warning, :message = _r_[:evidence] ]
		ok
		return _a_

	# Returns one sentence on the table's size and the evidence for or against a re-expression.
	#
	#   returns    a text
	#   see        Recommend
	def Why()
		_r_ = This.Recommend()
		if _r_[:fires]
			return "re-expression of a " + ring_len(@aRows) + " x " + ring_len(@aRows[1]) + " table: " + _r_[:evidence]
		ok
		return "re-expression of a " + ring_len(@aRows) + " x " + ring_len(@aRows[1]) + " table: " + _r_[:evidence]
