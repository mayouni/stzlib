load "../../stzBase.ring"
load "../_narrated.ring"

# PRINCIPAL COMPONENT ANALYSIS, ON THE SVD.
#
# PCA asks one question -- along which directions does this data vary most? -- and the
# answer is the singular value decomposition of the CENTERED data matrix. The right
# singular vectors are the directions, the singular values say how much variance each
# accounts for, and U*S puts every sample into those coordinates.
#
# SO THERE IS ALMOST NO NEW ARITHMETIC HERE. The SVD was built in phase 4 and its
# factors were exposed a moment ago; this is what they were exposed FOR. What there is
# instead is three decisions, and each of them changes the answer:
#
#   1. CENTERING, which is not optional and is done for you. PCA on uncentered data
#      does not find the direction of greatest VARIANCE -- it finds the direction of
#      greatest second moment, which for data far from the origin is approximately the
#      direction of the mean. The first component comes back pointing at the centroid,
#      appearing to explain nearly everything and explaining nothing. It is the most
#      common way to get a wrong PCA, so it is not left to the caller.
#
#   2. STANDARDISING, which is a genuine choice with no safe default -- so Fit()
#      REFUSES until you have made it. Standardize() and Center() are ACTIVE verbs --
#      they do it and return nothing; Standardized() and Centered() are the PASSIVE
#      forms and hand back the prepared DATA. Centering alone gives COVARIANCE PCA: each
#      feature contributes in proportion to its own variance, in its own units.
#      Measure height in metres and mass in grams and the mass axis has a million
#      times the variance, so the first component is "mass" -- a fact about the unit,
#      not about the data. Dividing each column by its standard deviation gives
#      CORRELATION PCA, where every feature counts equally. The scenario below
#      measures the difference rather than describing it.
#
#   3. THE VARIANCE CONVENTION, which is not PCA's to invent. An explained variance
#      is a variance, and this library settled what that means in phase 0 after
#      finding two modules disagreeing about the divisor. The engine has ONE
#      authority (stats.varianceDivisor) and this asks it, so the variances reported
#      here and the ones stzDataSet reports can never drift apart.
#
# HOW IT IS CHECKED. Partly against a genuinely standard reference -- the data from
# Lindsay Smith's PCA tutorial, whose mean, components and variances are published and
# reproduced widely enough to be worth comparing to. But mostly against IDENTITIES,
# which need no reference at all:
#
#     the explained variances SUM to the total variance
#     the variance of score column j EQUALS explained variance j
#     every score column averages zero  (which is what proves the centering happened)
#     Transform() on the training data reproduces the training scores
#
# A reference dataset tests the case someone tabulated. An identity tests every case.

Scenario("the standard reference, which is worth having exactly once")
	# Lindsay Smith's tutorial data. Published mean (1.81, 1.91), first component
	# (0.6779, 0.7352), variances 1.2840 and 0.0491.
	aD = [ [2.5,2.4], [0.5,0.7], [2.2,2.9], [1.9,2.2], [3.1,3.0],
	       [2.3,2.7], [2.0,1.6], [1.0,1.1], [1.5,1.6], [1.1,0.9] ]
	oPca = new stzPCA(aD)
	oPca.Center()
	oPca.Fit()

	Then("the mean of feature 1", Rnd4(oPca.Mean()[1]), 1.81)
	Then("...and of feature 2", Rnd4(oPca.Mean()[2]), 1.91)
	Then("the first component", Rnd4(oPca.Components()[1][1]), 0.6779)
	Then("...its second entry", Rnd4(oPca.Components()[2][1]), 0.7352)
	Then("the first explained variance", Rnd4(oPca.ExplainedVariance()[1]), 1.284)
	Then("...and the second", Rnd4(oPca.ExplainedVariance()[2]), 0.0491)
	Then("the first component carries 96% of the variance",
	     Rnd3(oPca.ExplainedVarianceRatio()[1]), 0.963)
	Then("...so one component suffices for 95%", oPca.NumberOfComponentsFor(0.95), 1)
EndScenario()

Scenario("the identities, which need no reference")
	aD = [ [1,2,3], [4,5,7], [7,8,2], [1,9,3], [4,4,4], [6,8,2],
	       [3,5,5], [5,5,1], [2,8,9], [1,7,3] ]
	oPca = new stzPCA(aD)
	oPca.Center()
	oPca.Fit()

	# the decomposition redistributes the variance; it cannot create or destroy any
	aV = oPca.ExplainedVariance()
	nSum = 0
	_aV149_ = aV
	_nV149_ = len(_aV149_)
	for _iV149_ = 1 to _nV149_
		v = _aV149_[_iV149_]
		nSum += v
	next
	Then("the explained variances sum to the total",
	     Rnd8(nSum), Rnd8(oPca.TotalVariance()))
	Then("...so the ratios sum to 1",
	     Rnd8(oPca.CumulativeVarianceRatio()[len(aV)]), 1)

	# the scores are the data in component coordinates, so their spread along axis j
	# is exactly what component j was said to explain
	aS = oPca.Scores()
	Then("the variance of score column 1 is explained variance 1",
	     Rnd6(ColVariance(aS, 1)), Rnd6(aV[1]))
	Then("...and of column 2", Rnd6(ColVariance(aS, 2)), Rnd6(aV[2]))
	Then("...and of column 3", Rnd6(ColVariance(aS, 3)), Rnd6(aV[3]))

	# every score column averages zero -- the direct evidence that centering happened
	Then("score column 1 is centered", Rnd8(ColMean(aS, 1)), 0)
	Then("...column 2", Rnd8(ColMean(aS, 2)), 0)
	Then("...column 3", Rnd8(ColMean(aS, 3)), 0)

	# components descend by the variance they explain
	Then("the components are ordered by variance",
	     aV[1] >= aV[2] and aV[2] >= aV[3], TRUE)
EndScenario()

Scenario("CENTERING is what makes it variance rather than distance from zero")
	# Data far from the origin with a clear internal structure. If PCA did not
	# center, the first component would point at the centroid -- roughly (1,1)
	# normalised -- and would "explain" almost everything. Centered, it finds the
	# direction the data actually varies along, which here is the anti-diagonal.
	aFar = [ [1000,1000], [1001,999], [999,1001], [1002,998], [998,1002] ]
	oPca = new stzPCA(aFar)
	oPca.Center()
	oPca.Fit()

	# the real structure: x and y move in OPPOSITE directions, so the loadings have
	# opposite signs. An uncentered analysis would give them the SAME sign, both
	# near 0.707, because it would be describing the direction of the mean.
	aC = oPca.Components()
	Then("the first component has opposite signs -- the real structure",
	     aC[1][1] * aC[2][1] < 0, TRUE)
	Then("...and it explains everything, because the data is one-dimensional",
	     Rnd6(oPca.ExplainedVarianceRatio()[1]), 1)
	Then("the mean was found and removed", Rnd4(oPca.Mean()[1]), 1000)

	# and the scores are small numbers around zero, not numbers around 1414
	Then("the scores are centered, not offset by the distance to the origin",
	     fabs(oPca.Scores()[1][1]) < 10, TRUE)
EndScenario()

Scenario("STANDARDISING changes which component comes first")
	# Two features: one with an enormous spread, one with a small one. This is the
	# height-in-metres against mass-in-grams situation, and the two analyses give
	# genuinely different answers -- which is why neither can be the default.
	aU = []
	for i = 1 to 20
		aU + [ i * 1000, sin(i) ]
	next

	oCov = new stzPCA(aU)
	oCov.Center()
	oCov.Fit()
	oCor = new stzPCA(aU)
	oCor.Standardize()
	oCor.Fit()

	Then("covariance PCA follows the big feature almost entirely",
	     fabs(oCov.Components()[1][1]) > 0.999, TRUE)
	Then("...and calls it essentially all the variance",
	     oCov.ExplainedVarianceRatio()[1] > 0.999, TRUE)

	Then("correlation PCA lets both features count",
	     fabs(oCor.Components()[1][1]) < 0.99, TRUE)
	Then("...so the first component explains less",
	     oCor.ExplainedVarianceRatio()[1] < oCov.ExplainedVarianceRatio()[1], TRUE)
	Then("it reports which analysis it did", oCor.IsStandardized(), TRUE)
	Then("...and says so in words",
	     StzFindFirst("correlation", oCor.Why()) > 0, TRUE)
	Then("...while the other says covariance",
	     StzFindFirst("covariance", oCov.Why()) > 0, TRUE)
EndScenario()

Scenario("perfectly correlated features collapse onto one component")
	# y = 2x exactly: all the variance lies along one direction, so the second
	# component explains nothing. This is what PCA is FOR -- noticing that two
	# columns are one measurement.
	aC = [ [1,2], [2,4], [3,6], [4,8], [5,10] ]
	oPca = new stzPCA(aC)
	oPca.Center()
	oPca.Fit()
	Then("the first component explains everything",
	     Rnd8(oPca.ExplainedVarianceRatio()[1]), 1)
	Then("...and the second nothing", oPca.ExplainedVariance()[2] < 0.0000000001, TRUE)
	Then("one component is enough for 99%", oPca.NumberOfComponentsFor(0.99), 1)
EndScenario()

Scenario("projecting data the fit has not seen")
	aD = [ [2.5,2.4], [0.5,0.7], [2.2,2.9], [1.9,2.2], [3.1,3.0], [2.3,2.7] ]
	oPca = new stzPCA(aD)
	oPca.Center()
	oPca.Fit()

	# projecting the TRAINING data must reproduce the training scores exactly. If
	# Transform centered by the new data's own mean instead of the fit's, it would
	# not -- and that is the mistake it exists to prevent.
	aT = oPca.Transform(aD)
	Then("the training data projects back to its own scores",
	     Rnd8(aT[1][1]), Rnd8(oPca.Scores()[1][1]))
	Then("...every row", Rnd8(aT[4][2]), Rnd8(oPca.Scores()[4][2]))

	# a genuinely new point lands somewhere sensible
	aN = oPca.Transform([ [2.0, 2.0] ])
	Then("a new point gets coordinates", len(aN[1]), 2)
	Then("...near the middle, since it is near the mean",
	     fabs(aN[1][1]) < 1, TRUE)

	Then("a row of the wrong width is refused", RaisesTransform(oPca, [ [1] ]), TRUE)
	Then("...naming the width it wanted",
	     StzFindFirst("fitted on 2", WhyTransform(oPca, [ [1] ])) > 0, TRUE)
EndScenario()

Scenario("the variance convention comes from the library's one authority")
	# Phase 0 made stats.varianceDivisor the single definition after finding two
	# modules disagreeing. PCA asks it rather than writing n-1, so sample and
	# population differ by exactly n/(n-1) and the PROPORTIONS are identical --
	# the convention scales every component by the same factor.
	aD = [ [1,2], [4,5], [7,8], [1,9], [4,4] ]
	oS = new stzPCA(aD)
	oS.Center()
	oS.UseSampleVariance()
	oS.Fit()
	oPop = new stzPCA(aD)
	oPop.Center()
	oPop.UsePopulationVariance()
	oPop.Fit()

	Then("sample over population is exactly n/(n-1)",
	     Rnd8(oS.ExplainedVariance()[1] / oPop.ExplainedVariance()[1]), Rnd8(5/4))
	Then("...and the proportions are unchanged",
	     Rnd8(oS.ExplainedVarianceRatio()[1]), Rnd8(oPop.ExplainedVarianceRatio()[1]))
EndScenario()

Scenario("THE NAME FORMS, which in Softanza carry the semantics")
	# This class shipped with Standardized() MUTATING the analysis and returning
	# This, which got both Softanza laws wrong at once:
	#
	#   the FORM law -- an active verb DOES the thing and returns nothing; the
	#   passive ...ed form returns a transformed COPY and leaves the object alone;
	#   the Q twin does it and returns the object so calls chain.
	#
	#   the Q law -- a plain method returns DATA, never a Softanza object. Only a
	#   ...Q() form hands back something you can keep calling methods on.
	#
	# Reading a name should tell you what it does to the receiver, so the two are
	# pinned here rather than left to the docstring.
	aD = [ [1,2], [3,4], [5,7], [2,2] ]

	# ACTIVE: does it, returns nothing
	oAct = new stzPCA(aD)
	Then("Standardize() returns nothing", isNull(oAct.Standardize()), TRUE)
	Then("...and it CHANGED the analysis", oAct.IsStandardized(), TRUE)
	oAct2 = new stzPCA(aD)
	Then("Center() returns nothing", isNull(oAct2.Center()), TRUE)
	Then("...and it changed it the other way", oAct2.IsStandardized(), FALSE)

	# PASSIVE: returns the prepared DATA, receiver untouched
	oPas = new stzPCA(aD)
	oPas.Center()
	aCentered = oPas.Centered()
	Then("Centered() returns data, not an object", isList(aCentered), TRUE)
	Then("...of the same shape as the input", len(aCentered), 4)
	Then("...actually centered", Rnd8(ColMean(aCentered, 1)), 0)
	Then("...and the analysis is UNCHANGED by asking", oPas.IsStandardized(), FALSE)

	aStd = oPas.Standardized()
	Then("Standardized() also returns data", isList(aStd), TRUE)
	Then("...scaled to unit variance", Rnd6(ColVariance(aStd, 1)), 1)
	Then("...and STILL did not change the analysis", oPas.IsStandardized(), FALSE)

	# FLUENT: does it AND returns the object, so calls chain
	oFlu = new stzPCA(aD)
	oFlu.StandardizeQ().UseSampleVarianceQ().FitQ()
	Then("the Q forms chain", oFlu.IsFitted(), TRUE)
	Then("...and did the thing", oFlu.IsStandardized(), TRUE)

	# and the mutators that are not transformations follow the same law
	oVar = new stzPCA(aD)
	Then("UseSampleVariance() returns nothing", isNull(oVar.UseSampleVariance()), TRUE)
	Then("...and it took effect", oVar.UsesSampleVariance(), TRUE)
	oVar.UsePopulationVariance()
	Then("...as does its opposite", oVar.UsesSampleVariance(), FALSE)

	# Fit() is an act: nothing back, and FitQ() to chain
	oFit = new stzPCA(aD)
	oFit.Center()
	Then("Fit() returns nothing", isNull(oFit.Fit()), TRUE)
	Then("...but it fitted", oFit.IsFitted(), TRUE)
EndScenario()

Scenario("what it refuses, and why")
	aD = [ [1,2], [3,4], [5,7] ]

	# THE CHOICE IS REQUIRED. Defaulting either way would quietly decide which
	# component comes first for every caller who did not think about it.
	oNo = new stzPCA(aD)
	Then("Fit refuses before you have chosen", RaisesFit(oNo), TRUE)
	Then("...explaining that there is no safe default",
	     StzFindFirst("no safe default", WhyFit(oNo)) > 0, TRUE)

	# and everything else must be asked after fitting
	oNot = new stzPCA(aD)
	oNot.Center()
	Then("the results refuse before Fit", RaisesComponents(oNot), TRUE)

	Then("one sample has no spread to decompose",
	     RaisesOneSample(), TRUE)
	Then("ragged samples are refused", RaisesRagged(), TRUE)
	Then("an empty list is refused", RaisesEmpty(), TRUE)

	oOk = new stzPCA(aD)
	oOk.Center()
	oOk.Fit()
	Then("a fraction outside 0..1 is refused", RaisesFraction(oOk), TRUE)
	Then("...and a sensible one is not", oOk.NumberOfComponentsFor(0.5) >= 1, TRUE)
EndScenario()

Scenario("THE INVERSE IS THE TRANSPOSE, and its error is the discarded variance")
	# This is where PCA differs in KIND from t-SNE and UMAP, not merely in quality. The
	# forward map is a ROTATION onto an orthonormal basis, so undoing it needs no second
	# model, no training and no lookup: multiply by the same loadings the other way
	# round, put the scale back, put the mean back.
	#
	# Those two must fit a DECODER to (position, row) pairs and hand back a plausible
	# row rather than a recovered one. Here the arithmetic was already in the fit.
	aD = RankThreeData(60)

	oP = new stzPCA(aD)
	oP.Center()
	oP.Fit()

	# KEEPING EVERYTHING: the data comes back, to rounding
	Then("a full reconstruction returns the data itself",
	     MaxAbsError(aD, oP.Reconstructed()) < 0.000001, TRUE)

	# DROPPING COMPONENTS: the mean squared error EQUALS the sum of the discarded
	# eigenvalues. MEASURED:
	#
	#     k=1   mse 1.540040   discarded variance 1.540040
	#     k=2   mse 0.126675   discarded variance 0.126675
	#     k=3   mse 0.000000   discarded variance 0.000000
	#
	# An identity, not an approximation -- the residual IS the projection onto the
	# eigenvectors that were dropped, so its size is their eigenvalues and nothing else.
	# The third column of that table is zero because this data is genuinely rank three,
	# which is itself the identity holding.
	#
	# THIS IS A FAR STRONGER CHECK THAN THE LEARNED INVERSES CAN OFFER. Their
	# reconstruction error says only that the result looked plausible; this says the
	# arithmetic is RIGHT. Transpose the loadings the wrong way, or put the scale back
	# before the mean, and the numbers would still look reasonable while this fails.
	Then("dropping to 1 component costs exactly the variance it discarded",
	     ReconstructionMatchesVariance(oP, aD, 1), TRUE)
	Then("...and dropping to 2 does the same",
	     ReconstructionMatchesVariance(oP, aD, 2), TRUE)

	# reconstructing from FEWER components than were kept is the usual question, and
	# from more is not a question at all
	Then("more components than were kept is refused", RefusesTooManyScores(oP), TRUE)
EndScenario()


Summary()

func Rnd8(n)
	return ceil(n * 100000000 - 0.5) / 100000000

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000

func Rnd4(n)
	return ceil(n * 10000 - 0.5) / 10000

func Rnd3(n)
	return ceil(n * 1000 - 0.5) / 1000

func ColMean(aM, j)
	n = len(aM)
	s = 0
	for i = 1 to n
		s += aM[i][j]
	next
	return s / n

func ColVariance(aM, j)
	n = len(aM)
	m = ColMean(aM, j)
	s = 0
	for i = 1 to n
		d = aM[i][j] - m
		s += d * d
	next
	return s / (n - 1)

func RaisesFit(o)
	b = FALSE
	try
		o.Fit()
	catch
		b = TRUE
	done
	return b

func WhyFit(o)
	s = ""
	try
		o.Fit()
	catch
		s = cCatchError
	done
	return s

func RaisesComponents(o)
	b = FALSE
	try
		v = o.Components()
	catch
		b = TRUE
	done
	return b

func RaisesTransform(o, aR)
	b = FALSE
	try
		v = o.Transform(aR)
	catch
		b = TRUE
	done
	return b

func WhyTransform(o, aR)
	s = ""
	try
		v = o.Transform(aR)
	catch
		s = cCatchError
	done
	return s

func RaisesOneSample()
	b = FALSE
	try
		o = new stzPCA([ [1,2] ])
		o.Center()
		o.Fit()
	catch
		b = TRUE
	done
	return b

func RaisesRagged()
	b = FALSE
	try
		o = new stzPCA([ [1,2], [3] ])
	catch
		b = TRUE
	done
	return b

func RaisesEmpty()
	b = FALSE
	try
		o = new stzPCA([])
	catch
		b = TRUE
	done
	return b

func RaisesFraction(o)
	b = FALSE
	try
		v = o.NumberOfComponentsFor(1.5)
	catch
		b = TRUE
	done
	return b

# five columns spanning only three real directions, so dropping components has a
# predictable cost rather than an arbitrary one
func RankThreeData(n)
	_r3Rows_ = []
	_r3S_ = 99
	for _r3I_ = 1 to n
		_r3S_ = (_r3S_ * 1103515245 + 12345) % 2147483648
		_r3A_ = ((floor(_r3S_/2048) % 1000) / 1000) - 0.5
		_r3S_ = (_r3S_ * 1103515245 + 12345) % 2147483648
		_r3B_ = ((floor(_r3S_/2048) % 1000) / 1000) - 0.5
		_r3S_ = (_r3S_ * 1103515245 + 12345) % 2147483648
		_r3C_ = ((floor(_r3S_/2048) % 1000) / 1000) - 0.5
		_r3Rows_ + [ _r3A_*10, _r3B_*4, _r3C_, _r3A_*3 + _r3B_, _r3A_*2 - _r3C_ ]
	next
	return _r3Rows_

func MaxAbsError(aA, aB)
	_maV_ = 0
	for _maI_ = 1 to len(aA)
		for _maJ_ = 1 to len(aA[1])
			_maE_ = fabs(aA[_maI_][_maJ_] - aB[_maI_][_maJ_])
			if _maE_ > _maV_
				_maV_ = _maE_
			ok
		next
	next
	return _maV_

# the identity: mean squared reconstruction error from k components == the sum of the
# eigenvalues of the components dropped
func ReconstructionMatchesVariance(oP, aD, k)
	_rmS_ = oP.Scores()
	_rmT_ = []
	for _rmI_ = 1 to len(aD)
		_rmR_ = []
		for _rmJ_ = 1 to k
			_rmR_ + _rmS_[_rmI_][_rmJ_]
		next
		_rmT_ + _rmR_
	next
	_rmB_ = oP.Inverse(_rmT_)

	_rmE_ = 0
	for _rmI_ = 1 to len(aD)
		for _rmJ_ = 1 to len(aD[1])
			_rmD_ = aD[_rmI_][_rmJ_] - _rmB_[_rmI_][_rmJ_]
			_rmE_ += _rmD_ * _rmD_
		next
	next
	_rmE_ = _rmE_ / (len(aD) - 1)

	_rmV_ = oP.ExplainedVariance()
	_rmDrop_ = 0
	for _rmJ_ = k+1 to len(_rmV_)
		_rmDrop_ += _rmV_[_rmJ_]
	next
	return fabs(_rmE_ - _rmDrop_) < 0.000001

func RefusesTooManyScores(oP)
	_rtB_ = FALSE
	try
		oP.Inverse([ [1,2,3,4,5,6,7,8] ])
	catch
		_rtB_ = TRUE
	done
	return _rtB_
