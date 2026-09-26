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

class stzTukeySummary from stzObject

	@aNumbers = []
	@cConvention = "fourths"     # "fourths" (Tukey) | "percentile" (stzDataSet's)

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

	def Numbers()
		return @aNumbers

	def Count()
		return ring_len(@aNumbers)

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

	def Convention()
		return @cConvention

	def _ConventionCode()
		if @cConvention = "percentile"  return 1  ok
		return 0

	def Median()
		return StzEngineStatsMedian(This._Handle())

	def _Handle()
		return StzEngineStatsCreate(@aNumbers)

	# Tukey's fourths, whatever the convention in force: the two hinges
	def Fourths()
		return StzEngineTukeyFourths(@aNumbers)

	# percentile quartiles, stats.zig's rank = p/100 * (n-1)
	def Quartiles()
		return StzEngineTukeyQuartiles(@aNumbers)

	# the pair the convention in force names
	def Hinges()
		if @cConvention = "percentile"  return This.Quartiles()  ok
		return This.Fourths()

	def FourthSpread()
		_a_ = This.Hinges()
		return _a_[2] - _a_[1]

	# [ lower, upper ] at a multiplier of the fourth-spread, under the convention in force
	def Fences(pnMult)
		if NOT isNumber(pnMult) or pnMult <= 0
			stzraise("stzTukeySummary.Fences: the multiplier is a positive number -- 1.5 outside, 3 far out.")
		ok
		return StzEngineTukeyFences(@aNumbers, pnMult, This._ConventionCode())

	def OutsideFences()
		return This.Fences(1.5)

	def FarOutFences()
		return This.Fences(3)

	# the values beyond the outside fences (1.5), in the order given
	def Outside()
		return This._Beyond(This.OutsideFences())

	# the values beyond the far-out fences (3)
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

	# the ladder from M outward: [ [ letter, depth, lower, upper, mid, spread ], ... ]
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

	def Trimean()
		return StzEngineTukeyTrimean(@aNumbers)

	# the ladder as a table: letter, depth, lower, mid, upper, spread
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

	# the median absolute deviation, unscaled
	def Mad()
		return StzEngineTukeyMad(@aNumbers)

	# the biweight midvariance with the tuning constant (9 is usual)
	def Biweight(pnC)
		_c_ = pnC
		if NOT isNumber(_c_) or _c_ <= 0  _c_ = 9  ok
		return StzEngineTukeyBiweight(@aNumbers, _c_)

	#-- the shape, measured, and the verdicts (TK4) -----------------------------

	# skewness: the mean drift of the F, E and D mid-summaries from the
	# median, over the fourth-spread; positive leans right
	def Skewness()
		_lv_ = This.LetterValues(4)
		_m_ = _lv_[1][5]
		_f_ = _lv_[2][6]
		if _f_ <= 0  return 0  ok
		return ((_lv_[2][5] - _m_) + (_lv_[3][5] - _m_) + (_lv_[4][5] - _m_)) / 3 / _f_

	# tail weight: the sixteenth-spread over the fourth-spread, against the
	# Gaussian's ratio; 1 is Gaussian, above 1.2 is heavy by the measurement
	def TailWeight()
		_lv_ = This.LetterValues(4)
		_f_ = _lv_[2][6]
		if _f_ <= 0  return 1  ok
		return (_lv_[4][6] / _f_) / StzTukeyGaussianDOverF()

	# the shape as words, with the numbers they were read from
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

	# the verdicts in the house shape [ :rule, :subject, :where, :severity, :message ]:
	# a far-out value is an error, a shape is a warning, and every message
	# names the measurement and the threshold it crossed
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

	def NumberOfRows()
		return @nRows

	def NumberOfColumns()
		return @nCols

	# R's defaults: eps 0.01 of the residual sum, at most 10 sweeps
	def SetTolerance(pnEps)
		if NOT isNumber(pnEps) or pnEps <= 0
			stzraise("stzTukeyFit.SetTolerance: a positive fraction of the residual sum.")
		ok
		@nEps = pnEps
		return This

	def SetMaxSweeps(pnMax)
		if NOT isNumber(pnMax) or pnMax < 1
			stzraise("stzTukeyFit.SetMaxSweeps: at least one sweep.")
		ok
		@nMaxSweeps = pnMax
		return This

	# THE POLISH, R's stats::medpolish exactly, in one engine crossing
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

	def IsPolished()
		return @bPolished

	def Common()
		This._RequirePolished("Common")
		return @nCommon

	def Effects(pcWhich)
		This._RequirePolished("Effects")
		_c_ = StzLower(ring_trim("" + pcWhich))
		if _c_ = "row" or _c_ = "rows"  return @aRowEffects  ok
		if _c_ = "col" or _c_ = "cols" or _c_ = "column" or _c_ = "columns"  return @aColEffects  ok
		stzraise("stzTukeyFit.Effects: :Row or :Col.")

	def Residuals()
		This._RequirePolished("Residuals")
		return @aResiduals

	def Residual(pnRow, pnCol)
		This._RequirePolished("Residual")
		return @aResiduals[pnRow][pnCol]

	# common + row effect + column effect
	def Fitted(pnRow, pnCol)
		This._RequirePolished("Fitted")
		return @nCommon + @aRowEffects[pnRow] + @aColEffects[pnCol]

	def Sweeps()
		This._RequirePolished("Sweeps")
		return @nSweeps

	def IsConverged()
		This._RequirePolished("IsConverged")
		return @bConverged

	# THE CONTRACT, CHECKED: the largest |data - (fit + residual)| over the table
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

	# the fourth-spread of the residuals, the scale a coded display bands by
	def ResidualScale()
		This._RequirePolished("ResidualScale")
		_a_ = []
		for _i_ = 1 to @nRows
			for _j_ = 1 to @nCols
				_a_ + @aResiduals[_i_][_j_]
			next
		next
		return StzTukeySummaryQ(_a_).FourthSpread()

	# the verdicts (TK4): a cell whose residual lies beyond Tukey's far-out
	# fence on the residual batch -- hinge -+ 3 fourth-spreads, the rule the
	# summary and the residual plot use -- is an error the fit does not
	# describe; a polish that hit its cap is a warning
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

	def Why()
		if NOT @bPolished
			return "a two-way table of " + @nRows + " x " + @nCols + ", not yet polished"
		ok
		_c_ = "a median polish of " + @nRows + " x " + @nCols + ": common " + _FfNum(@nCommon, 4) +
			", " + @nSweeps + " sweep(s), "
		if @bConverged  _c_ += "converged"  else  _c_ += "stopped at the cap"  ok
		return _c_ + "; Data = Fit + Residual holds to " + _FfNum(This.Check(), 9)

#-- the resistant line -----------------------------------------------------

class stzTukeyLine from stzObject

	@aX = []
	@aY = []
	@nSlope = 0
	@nIntercept = 0
	@nIterations = 0
	@bFitted = 0

	def init(paX, paY)
		if NOT isList(paX) or NOT isList(paY) or ring_len(paX) != ring_len(paY) or ring_len(paX) < 3
			stzraise("stzTukeyLine: two lists of the same length, at least three points.")
		ok
		@aX = paX
		@aY = paY

	# Tukey's three-group line, with pnIterations passes over the residuals
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

	def Slope()
		This._RequireFitted("Slope")
		return @nSlope

	def Intercept()
		This._RequireFitted("Intercept")
		return @nIntercept

	def Iterations()
		This._RequireFitted("Iterations")
		return @nIterations

	def Residuals()
		This._RequireFitted("Residuals")
		_a_ = []
		_n_ = ring_len(@aX)
		for _i_ = 1 to _n_
			_a_ + (@aY[_i_] - (@nIntercept + @nSlope * @aX[_i_]))
		next
		return _a_

	def Why()
		if NOT @bFitted
			return "a resistant line over " + ring_len(@aX) + " points, not yet fitted"
		ok
		return "Tukey's three-group line over " + ring_len(@aX) + " points: y = " +
			_FfNum(@nIntercept, 4) + " + " + _FfNum(@nSlope, 4) + " x, after " + @nIterations + " residual pass(es)"

#-- the one-way fit ---------------------------------------------------------

class stzTukeyOneWay from stzObject

	@aGroups = []
	@nCommon = 0
	@aEffects = []
	@aResiduals = []
	@bPolished = 0

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

	def NumberOfGroups()
		return ring_len(@aGroups)

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

	def Common()
		This._RequirePolished("Common")
		return @nCommon

	def Effects()
		This._RequirePolished("Effects")
		return @aEffects

	def Residuals()
		This._RequirePolished("Residuals")
		return @aResiduals

	# THE CONTRACT, CHECKED: the largest |value - (common + effect + residual)|
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

	# the verdict (TK4): spread that tracks level, as the slope of log
	# spread on log level over the groups, past the measured threshold
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

	def Why()
		if NOT @bPolished
			return "a one-way table of " + ring_len(@aGroups) + " group(s), not yet polished"
		ok
		return "a one-way median polish of " + ring_len(@aGroups) + " group(s): common " +
			_FfNum(@nCommon, 4) + ", effects " + @@(@aEffects) + "; Data = Fit + Residual holds to " + _FfNum(This.Check(), 9)

#-- re-expression, measured ---------------------------------------------------

class stzTukeyReexpression from stzObject

	@aRows = []
	@aLadder = []          # [ [ power, slope, residual scale, ok ], ... ]
	@bEvaluated = 0

	def init(paRows)
		if NOT isList(paRows) or ring_len(paRows) = 0 or NOT isList(paRows[1])
			stzraise("stzTukeyReexpression: give the two-way table as a list of rows.")
		ok
		@aRows = paRows

	# the measured threshold the engine carries: a recommendation fires
	# only when |slope at power 1| exceeds it
	def Threshold()
		return StzEngineTukeyThreshold()

	# the non-additivity slope of the table as it stands: residuals on
	# comparison values, with the suggested power 1 - slope
	def NonAdditivity()
		_a_ = StzEngineTukeyNonAdditivity(@aRows)
		if NOT isList(_a_) or ring_len(_a_) < 4
			stzraise("stzTukeyReexpression.NonAdditivity: the engine refused the table.")
		ok
		return [ :slope = _a_[1], :intercept = _a_[2], :power = _a_[3], :ok = _a_[4] ]

	# EVERY RUNG IN ONE CROSSING: [ [ power, slope, residual scale, ok ], ... ]
	def Ladder()
		if NOT @bEvaluated
			@aLadder = StzEngineTukeyLadder(@aRows, StzTukeyLadderPowers())
			if NOT isList(@aLadder) or ring_len(@aLadder) = 0
				stzraise("stzTukeyReexpression.Ladder: the engine refused the table.")
			ok
			@bEvaluated = 1
		ok
		return @aLadder

	def Rung(pnPower)
		_a_ = This.Ladder()
		_n_ = ring_len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][1] = pnPower  return _a_[_i_]  ok
		next
		stzraise("stzTukeyReexpression.Rung: " + pnPower + " is not a rung of the ladder " + @@(StzTukeyLadderPowers()) + ".")

	# THE RECOMMENDATION, AS A VERDICT WITH ITS EVIDENCE:
	#   [ :power, :name, :slope, :evidence, :fires ]
	# fires = 0 means "leave it alone", and the slope at power 1 says why
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

	# the diagnostics in the house rule shape, for stzRuleReport (plan 2.6)
	# the ladder as a table: power, its name, the slope, the residual scale
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

	def Why()
		_r_ = This.Recommend()
		if _r_[:fires]
			return "re-expression of a " + ring_len(@aRows) + " x " + ring_len(@aRows[1]) + " table: " + _r_[:evidence]
		ok
		return "re-expression of a " + ring_len(@aRows) + " x " + ring_len(@aRows[1]) + " table: " + _r_[:evidence]
