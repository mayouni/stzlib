#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZHYPOTHESIS                #
#   An accelerative library for Ring applications, and more!   #
#                                                              #
#   Description  : Hypothesis tests -- t, chi-square, ANOVA,    #
#                  correlation -- over the Softanza Engine.     #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#--------------------------------------------------------------#

/*
PHASE 5 OF THE NUMERIC FOUNDATION, first slice: INFERENTIAL STATISTICS.

The library could not perform a single hypothesis test. stzDataSet had correlation,
covariance, regression coefficients, z-scores and (since phase 4) a correct t-based
confidence interval -- all DESCRIPTIVE, all answering "what does this data look
like?". Nothing answered "could this have happened by chance?", because until
phase 4's special.zig there was no way to compute a tail probability at all.

    ? StzTTestOneSample([ 5.1, 4.9, 5.6, 5.2, 5.0, 5.3, 4.8, 5.4 ], 5)
    #--> [ :statistic = 1.72, :df = 7, :pvalue = 0.13, :effect = 0.61,
    #      :n = 8, :test = "one-sample t", :significant = FALSE, ... ]

WHY A RECORD AND NEVER A BARE p-VALUE
------------------------------------
A p-value is the most misread number in statistics. It is the probability of seeing
data at least this extreme IF THE "" HYPOTHESIS WERE 1 -- and nothing else. It
is NOT the probability that the "" is 1; a large p does NOT mean "no effect";
and a small p says NOTHING about whether the effect matters.

That last one is not a quibble. The same underlying difference, tested at four
sample sizes:

    n        p             Cohen's d
    10       8.37e-1       0.067
    100      4.83e-1       0.070
    1000     2.56e-2       0.071
    10000    1.64e-12      0.071

Eleven orders of magnitude in the p-value, and the effect size does not move -- and
d = 0.07 is NEGLIGIBLE by any convention (0.2 is the threshold for "small"). At
n = 10000 you get p < 1e-11 for a difference that does not matter at all.

So every test here returns the statistic, the degrees of freedom, the p-value, the
SAMPLE SIZE, an EFFECT SIZE, and the NAME of the test that actually ran. That is the
same instinct as ConfidenceIntervalXT reporting its `:method` and stzNumber's
`IsExact()` / `Why()`: say what you did, and give the reader what they need to judge
it.
*/

# The conventional significance threshold. Named rather than buried, because 0.05 is
# a convention and not a law of nature -- and because a caller who wants 0.01 should
# not have to guess where to change it.
$nStzDefaultAlpha = 0.05


func StzHypothesisResult(paRaw, cTestName, cAlternative)
	# The engine hands back [ statistic, df, pvalue, effect, n, ok ].
	if NOT isList(paRaw) or len(paRaw) < 6
		StzRaise("StzHypothesisResult: the engine returned an unusable result.")
	ok

	if paRaw[6] = 0
		# NO TEST WAS RUN. Every field is zero, and the zero p-value must not be read
		# as overwhelming significance -- which is exactly what a caller would do if
		# this looked like an ordinary result.
		return [
			:test = cTestName,
			:ran = 0,
			:why = "the test could not be run on this data -- too few observations, " +
			       "no variation to test, or mismatched inputs",
			:statistic = 0, :df = 0, :pvalue = 1, :effect = 0, :n = 0,
			:significant = 0, :alpha = $nStzDefaultAlpha,
			:alternative = cAlternative,
			:conclusion = "no test was performed"
		]
	ok

	_nP_ = paRaw[3]
	_bSig_ = (_nP_ < $nStzDefaultAlpha)

	_cConc_ = ""
	if _bSig_
		_cConc_ = "the data would be unusual if there were no effect (p = " +
		          StzRoundTo(_nP_, 4) + " < " + $nStzDefaultAlpha + "); " +
		          "this does NOT say how large the effect is -- see :effect"
	else
		_cConc_ = "the data is consistent with there being no effect (p = " +
		          StzRoundTo(_nP_, 4) + "); this does NOT establish that there " +
		          "is none -- absence of evidence is not evidence of absence"
	ok

	return [
		:test = cTestName,
		:ran = 1,
		:statistic = paRaw[1],
		:df = paRaw[2],
		:pvalue = _nP_,
		:effect = paRaw[4],
		:n = paRaw[5],
		:significant = _bSig_,
		:alpha = $nStzDefaultAlpha,
		:alternative = cAlternative,
		:conclusion = _cConc_
	]

func StzRoundTo(n, nPlaces)
	_nF_ = pow(10, nPlaces)
	return ceil(n * _nF_ - 0.5) / _nF_


#---------------------------------------------------------------#
#  THE TESTS                                                    #
#---------------------------------------------------------------#

# Is the mean of this sample different from a hypothesised value?
func StzTTestOneSample(paData, nMu0)
	_CheckNumericList(paData, "StzTTestOneSample")
	return StzHypothesisResult(
		StzEngineTOneSample(paData, nMu0),
		"one-sample t",
		"the true mean differs from " + nMu0)

# Do two INDEPENDENT samples have different means?
#
# WELCH BY DEFAULT, and that is a deliberate choice rather than an accident. Student's
# two-sample t assumes the two populations have equal variances -- an assumption that
# is usually untestable and usually wrong, and when it fails Student's test reports
# significance that is not there. Welch drops it, costs almost nothing when the
# variances ARE equal, and is what R's t.test does by default.
func StzTTestTwoSamples(paA, paB)
	_CheckNumericList(paA, "StzTTestTwoSamples")
	_CheckNumericList(paB, "StzTTestTwoSamples")
	return StzHypothesisResult(
		StzEngineTWelch(paA, paB),
		"Welch two-sample t",
		"the two means differ")

	func StzTTestWelch(paA, paB)
		return StzTTestTwoSamples(paA, paB)

# Student's pooled-variance version. Use it only when equal variance is KNOWN rather
# than hoped; otherwise prefer StzTTestTwoSamples above.
func StzTTestTwoSamplesPooled(paA, paB)
	_CheckNumericList(paA, "StzTTestTwoSamplesPooled")
	_CheckNumericList(paB, "StzTTestTwoSamplesPooled")
	return StzHypothesisResult(
		StzEngineTStudent(paA, paB),
		"Student two-sample t (pooled variance)",
		"the two means differ")

# The SAME subjects measured twice -- before and after. Mathematically a one-sample
# test on the differences, and implemented as exactly that, so the two cannot drift
# apart.
func StzTTestPaired(paBefore, paAfter)
	_CheckNumericList(paBefore, "StzTTestPaired")
	_CheckNumericList(paAfter, "StzTTestPaired")
	if len(paBefore) != len(paAfter)
		StzRaise("StzTTestPaired: a paired test needs the same number of " +
		         "observations in both lists (got " + len(paBefore) + " and " +
		         len(paAfter) + "). For independent samples use StzTTestTwoSamples.")
	ok
	return StzHypothesisResult(
		StzEngineTPaired(paBefore, paAfter),
		"paired t",
		"the mean difference is not zero")

# Do observed counts match expected ones?
func StzChiSquareGoodnessOfFit(paObserved, paExpected)
	_CheckNumericList(paObserved, "StzChiSquareGoodnessOfFit")
	_CheckNumericList(paExpected, "StzChiSquareGoodnessOfFit")
	if len(paObserved) != len(paExpected)
		StzRaise("StzChiSquareGoodnessOfFit: one expected count per observed " +
		         "count (got " + len(paObserved) + " and " + len(paExpected) + ").")
	ok
	return StzHypothesisResult(
		StzEngineChi2Gof(paObserved, paExpected),
		"chi-square goodness of fit",
		"the observed counts differ from the expected ones")

# Are the two factors of a contingency table related? Give it a list of rows.
func StzChiSquareIndependence(paTable)
	if NOT isList(paTable) or len(paTable) < 2 or NOT isList(paTable[1])
		StzRaise("StzChiSquareIndependence: give me a contingency table as a " +
		         "list of rows, at least 2 by 2.")
	ok
	_nRows_ = len(paTable)
	_nCols_ = len(paTable[1])
	_aFlat_ = []
	for _iCi_ = 1 to _nRows_
		if len(paTable[_iCi_]) != _nCols_
			StzRaise("StzChiSquareIndependence: every row must have the same " +
			         "number of columns.")
		ok
		for _jCi_ = 1 to _nCols_
			_aFlat_ + paTable[_iCi_][_jCi_]
		next
	next
	return StzHypothesisResult(
		StzEngineChi2Independence(_aFlat_, _nRows_, _nCols_),
		"chi-square test of independence",
		"the two factors are related")

# Do k groups have different means? Give it a list of groups.
func StzAnovaOneWay(paGroups)
	if NOT isList(paGroups) or len(paGroups) < 2
		StzRaise("StzAnovaOneWay: give me at least two groups. For two groups " +
		         "StzTTestTwoSamples answers the same question.")
	ok
	_aFlat_ = []
	_aSizes_ = []
	_nG_ = len(paGroups)
	for _iAv_ = 1 to _nG_
		if NOT isList(paGroups[_iAv_]) or len(paGroups[_iAv_]) = 0
			StzRaise("StzAnovaOneWay: every group must be a non-empty list of numbers.")
		ok
		_aSizes_ + len(paGroups[_iAv_])
		_nLenG_ = len(paGroups[_iAv_])
		for _jAv_ = 1 to _nLenG_
			_aFlat_ + paGroups[_iAv_][_jAv_]
		next
	next
	return StzHypothesisResult(
		StzEngineAnova(_aFlat_, _aSizes_),
		"one-way ANOVA",
		"at least one group mean differs from the others")

# Is the correlation between two variables different from zero?
func StzCorrelationTest(paA, paB)
	_CheckNumericList(paA, "StzCorrelationTest")
	_CheckNumericList(paB, "StzCorrelationTest")
	if len(paA) != len(paB)
		StzRaise("StzCorrelationTest: both lists must be the same length (got " +
		         len(paA) + " and " + len(paB) + ").")
	ok
	return StzHypothesisResult(
		StzEngineCorrelationTest(paA, paB),
		"Pearson correlation",
		"the true correlation is not zero")


#---------------------------------------------------------------#

func _CheckNumericList(paList, cWho)
	if NOT isList(paList)
		StzRaise(cWho + ": give me a list of numbers.")
	ok
	_nLen_ = len(paList)
	for _iCk_ = 1 to _nLen_
		if NOT isNumber(paList[_iCk_])
			StzRaise(cWho + ": every item must be a number (item " + _iCk_ +
			         " is not).")
		ok
	next
