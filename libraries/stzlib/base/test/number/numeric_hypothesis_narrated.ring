load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 5 of the numeric foundation, first slice: INFERENTIAL STATISTICS.
#
# Phase 5 is "algorithms come down from Ring, and every definition gets one
# authority". Its last item is different from the rest -- not a migration but a gap:
# "Inferential statistics -- NEW. Once special functions land: t/z/chi2/F
# distributions, correct confidence intervals, and the hypothesis tests that
# stzDataSet cannot currently express."
#
# IT COULD NOT EXPRESS ANY OF THEM. stzDataSet had correlation, covariance, regression
# coefficients, z-scores and (since phase 4) a correct t-based confidence interval --
# every one of them DESCRIPTIVE, answering "what does this data look like?". Nothing
# answered "could this have happened by chance?", because until phase 4's special.zig
# there was no way to compute a tail probability at all. That is what slice 5 of phase
# 4 was for, and this is the thing it unblocked.
#
# WHY EVERY TEST RETURNS A RECORD AND NEVER A BARE p-VALUE
# -------------------------------------------------------
# A p-value is the probability of data at least this extreme IF THE NULL WERE TRUE,
# and nothing else. It is not the probability the null is true; a large p is not "no
# effect"; and a small p says nothing about whether the effect MATTERS. That last one
# is measured, not asserted -- see the fourth scenario.

Scenario("a one-sample t test, checked against arithmetic anyone can redo")
	# mean = 5.1625, sum of squared deviations = 0.49875, so s = 0.2669270 and
	#   t = (5.1625 - 5) / (0.2669270 / sqrt(8)) = 1.7218921
	aR = StzTTestOneSample([ 5.1, 4.9, 5.6, 5.2, 5.0, 5.3, 4.8, 5.4 ], 5)

	Then("the test names itself", aR[:test], "one-sample t")
	Then("it ran", aR[:ran], TRUE)
	Then("the statistic", Rnd7(aR[:statistic]), 1.7218921)
	Then("...on 7 degrees of freedom", aR[:df], 7)
	Then("the p-value", Rnd7(aR[:pvalue]), 0.1287617)
	Then("...and the effect size, which a p-value alone would not tell you",
	     Rnd7(aR[:effect]), 0.6087808)
	Then("not significant at 0.05", aR[:significant], FALSE)

	# testing against the sample's OWN mean must give t = 0 and p = 1 exactly -- a
	# sanity check that needs no reference value at all
	aZ = StzTTestOneSample([ 5.1, 4.9, 5.6, 5.2, 5.0, 5.3, 4.8, 5.4 ], 5.1625)
	Then("testing against its own mean gives t = 0", Rnd9(aZ[:statistic]), 0)
	Then("...and p = 1", Rnd9(aZ[:pvalue]), 1)
EndScenario()

Scenario("the paired test IS the one-sample test on the differences")
	# Not a coincidence to verify but a definition to honour: the paired test is
	# implemented AS the one-sample test on the differences, so the two cannot drift
	# into disagreement.
	aBefore = [ 200, 190, 210, 205, 195, 220, 185 ]
	aAfter  = [ 195, 183, 200, 197, 190, 210, 180 ]
	aP = StzTTestPaired(aBefore, aAfter)

	aDiff = []
	for i = 1 to 7
		aDiff + (aBefore[i] - aAfter[i])
	next
	aOne = StzTTestOneSample(aDiff, 0)

	Then("the statistics are identical", aP[:statistic], aOne[:statistic])
	Then("...and the p-values", aP[:pvalue], aOne[:pvalue])
	Then("the differences are 5,7,10,8,5,10,5 giving t = 8.3333333",
	     Rnd7(aP[:statistic]), 8.3333333)
	Then("...which is highly significant", aP[:significant], TRUE)

	Given("mismatched lengths, where pairing is meaningless")
	Then("it raises, and points at the independent-samples test instead",
	     RaisesPaired([1,2,3], [1,2]), TRUE)
EndScenario()

Scenario("WELCH is the default two-sample test, and that is a decision")
	# Student's pooled test assumes the two populations have equal variances. That
	# assumption is usually untestable and usually wrong, and when it fails Student's
	# test reports significance that is not there. Welch drops it.
	aA = [ 10, 12, 11, 13, 12, 14, 11, 12 ]
	aB = [ 15, 17, 16, 14, 18, 15, 16, 17 ]
	aW = StzTTestTwoSamples(aA, aB)
	aS = StzTTestTwoSamplesPooled(aA, aB)

	Then("the default is named as Welch", aW[:test], "Welch two-sample t")
	Then("the statistic", Rnd7(aW[:statistic]), -6.4541256)
	Then("...on FRACTIONAL degrees of freedom, which is Welch's signature",
	     Rnd7(aW[:df]), 13.9662198)
	Then("Student's df is a whole number by contrast", aS[:df], 14)

	# WITH EQUAL SAMPLE SIZES the two share the same statistic exactly; only the df
	# differ. That is a property of the formulas rather than a coincidence.
	Then("equal sizes give the two tests the SAME statistic",
	     Rnd9(aW[:statistic]), Rnd9(aS[:statistic]))
	Then("...so their p-values are very close here",
	     fabs(aW[:pvalue] - aS[:pvalue]) < 0.0001, TRUE)

	# WHERE THEY DIVERGE, and why the default matters: very unequal variances with
	# very unequal sizes.
	aWild = [ 1, 2, 3, 100, -95 ]                                  # huge variance, n=5
	aTight = [ 10, 11, 10, 11, 10, 11, 10, 11, 10, 11, 10, 11 ]    # tiny, n=12
	aW2 = StzTTestTwoSamples(aWild, aTight)
	aS2 = StzTTestTwoSamplesPooled(aWild, aTight)
	Then("Student fixes df at n1+n2-2 = 15", aS2[:df], 15)
	Then("...while Welch shrinks toward the smaller, less informative sample",
	     aW2[:df] < 5, TRUE)
	Then("...and is therefore SLOWER to call it significant",
	     aW2[:pvalue] > aS2[:pvalue], TRUE)
EndScenario()

Scenario("THE MEASUREMENT THAT JUSTIFIES REPORTING AN EFFECT SIZE")
	# The same underlying pattern -- values cycling 0.1, 1.1, 2.1, 3.1, 4.1, so a mean
	# of 2.1 -- tested against 2.0, at three sample sizes.
	a10 = []
	a1k = []
	a10k = []
	for i = 0 to 9
		a10 + ((i % 5) + 0.1)
	next
	for i = 0 to 999
		a1k + ((i % 5) + 0.1)
	next
	for i = 0 to 9999
		a10k + ((i % 5) + 0.1)
	next

	aR10 = StzTTestOneSample(a10, 2)
	aR1k = StzTTestOneSample(a1k, 2)
	aR10k = StzTTestOneSample(a10k, 2)

	# THE EFFECT SIZE DOES NOT MOVE
	Then("Cohen's d at n=10", Rnd4(aR10[:effect]), 0.0671)
	Then("...at n=1000", Rnd4(aR1k[:effect]), 0.0707)
	Then("...and at n=10000, unchanged", Rnd4(aR10k[:effect]), 0.0707)

	# WHILE THE p-VALUE FALLS ELEVEN ORDERS OF MAGNITUDE
	Then("p at n=10 is nowhere near significant", aR10[:pvalue] > 0.8, TRUE)
	Then("...at n=1000 it crosses the usual threshold", aR1k[:pvalue] < 0.05, TRUE)
	Then("...and at n=10000 it is overwhelming", aR10k[:pvalue] < 0.0000000001, TRUE)

	# AND THE EFFECT IS NEGLIGIBLE THE WHOLE TIME. 0.2 is the conventional threshold
	# for "small"; this never reaches a third of it.
	Then("yet the effect is below even 'small' throughout",
	     aR10k[:effect] < 0.2, TRUE)
	Then("so 'significant' at n=10000 means a difference that does not matter",
	     aR10k[:significant] = TRUE and aR10k[:effect] < 0.2, TRUE)
	# THIS is why a bare p-value is not an answer.
EndScenario()

Scenario("chi-square, for counts rather than measurements")
	# A die rolled 60 times. Expected 10 of each face.
	aG = StzChiSquareGoodnessOfFit([ 8, 9, 10, 11, 12, 10 ], [ 10, 10, 10, 10, 10, 10 ])
	Then("the statistic is 1", Rnd9(aG[:statistic]), 1)
	Then("...on 5 degrees of freedom", aG[:df], 5)
	Then("the p-value is large: this die looks fair", Rnd7(aG[:pvalue]), 0.9625658)
	Then("...so not significant", aG[:significant], FALSE)
	Then("the total count is reported", aG[:n], 60)

	# a PERFECT fit gives chi-square 0 and p = 1
	aPerfect = StzChiSquareGoodnessOfFit([ 10, 10, 10 ], [ 10, 10, 10 ])
	Then("a perfect fit gives statistic 0", Rnd9(aPerfect[:statistic]), 0)
	Then("...and p = 1", Rnd9(aPerfect[:pvalue]), 1)

	# a 2x2 contingency table, given as rows
	aI = StzChiSquareIndependence([ [20, 30], [30, 20] ])
	Then("the independence statistic", Rnd9(aI[:statistic]), 4)
	Then("...on 1 degree of freedom", aI[:df], 1)
	Then("...p just under 0.05", Rnd7(aI[:pvalue]), 0.0455003)
	Then("Cramer's V, which does NOT grow with the sample size",
	     Rnd9(aI[:effect]), 0.2)

	# counts that are exactly independent give a statistic of 0
	aInd = StzChiSquareIndependence([ [10, 20], [20, 40] ])
	Then("perfectly independent counts give 0", Rnd9(aInd[:statistic]), 0)
EndScenario()

Scenario("ANOVA, and the identity that ties it to the t test")
	# WITH TWO GROUPS, ANOVA IS THE POOLED t TEST SQUARED. F with 1 and v degrees of
	# freedom IS t with v, squared -- so if these disagreed one of them would be
	# wrong. Two routes through two different distributions.
	aA = [ 10, 12, 11, 13, 12, 14 ]
	aB = [ 15, 17, 16, 14, 18, 15 ]
	aF = StzAnovaOneWay([ aA, aB ])
	aT = StzTTestTwoSamplesPooled(aA, aB)
	Then("F equals t squared", Rnd7(aF[:statistic]), Rnd7(aT[:statistic] * aT[:statistic]))
	Then("...and the p-values agree", Rnd9(aF[:pvalue]), Rnd9(aT[:pvalue]))

	# three groups: SS between = 21.7333, SS within = 9.5
	#   F = (21.7333/2) / (9.5/12) = 13.7142857
	aF3 = StzAnovaOneWay([ [5,6,7,6,5], [8,9,7,8,9], [6,5,6,7,5] ])
	Then("three groups give F = 13.7142857", Rnd7(aF3[:statistic]), 13.7142857)
	Then("...on 2 degrees of freedom", aF3[:df], 2)
	Then("...and it is significant", aF3[:significant], TRUE)
	Then("eta-squared is the fraction of variation the grouping explains",
	     Rnd7(aF3[:effect]), 0.6956522)
	Then("...so it lies between 0 and 1",
	     aF3[:effect] > 0 and aF3[:effect] < 1, TRUE)

	# identical groups: nothing to explain
	aSame = StzAnovaOneWay([ [1,2,3], [1,2,3] ])
	Then("identical groups give F = 0", Rnd9(aSame[:statistic]), 0)
	Then("...and p = 1", Rnd9(aSame[:pvalue]), 1)

	Then("one group is refused -- there is nothing to compare it to",
	     RaisesAnova([ [1,2,3] ]), TRUE)
EndScenario()

Scenario("is a correlation real, or could it be chance?")
	aC = StzCorrelationTest([1,2,3,4,5,6,7,8,9,10], [2,4,5,4,5,7,8,9,9,11])
	Then("r itself is the effect size, already scale-free",
	     Rnd7(aC[:effect]), 0.9704318)
	Then("the t statistic", Rnd7(aC[:statistic]), 11.3714707)
	Then("...on n-2 degrees of freedom", aC[:df], 8)
	Then("...and it is significant", aC[:significant], TRUE)

	# NO relationship: r near zero, p large
	aNone = StzCorrelationTest([1,2,3,4,5,6,7,8,9,10], [1,-1,1,-1,1,-1,1,-1,1,-1])
	Then("an unrelated pair gives a small r", fabs(aNone[:effect]) < 0.3, TRUE)
	Then("...and a large p", aNone[:pvalue] > 0.3, TRUE)
	Then("...so: not significant", aNone[:significant], FALSE)
	# and the conclusion says the honest thing rather than "there is no correlation"
	Then("the conclusion refuses to claim the null is TRUE",
	     StzFindFirst("absence of evidence", aNone[:conclusion]) > 0, TRUE)
EndScenario()

Scenario("what cannot be tested says so, instead of returning zeros")
	# THE FAILURE MODE THIS GUARDS AGAINST. If an un-runnable test returned a
	# p-value of 0 like any other result, a caller would read it as overwhelming
	# significance -- the exact opposite of the truth.
	aNoVar = StzTTestOneSample([ 3, 3, 3, 3 ], 0)
	Then("no variation in the data: the test did NOT run", aNoVar[:ran], FALSE)
	Then("...and the p-value is 1, not 0", aNoVar[:pvalue], 1)
	Then("...and it is not called significant", aNoVar[:significant], FALSE)
	Then("...and it says why",
	     StzFindFirst("could not be run", aNoVar[:why]) > 0, TRUE)

	aOne = StzTTestOneSample([ 5 ], 0)
	Then("a single observation cannot be tested either", aOne[:ran], FALSE)

	Given("inputs that do not line up")
	Then("a correlation on different lengths raises",
	     RaisesCorr([1,2,3], [1,2]), TRUE)
	Then("...and so does a mismatched goodness-of-fit",
	     RaisesGof([1,2,3], [1,2]), TRUE)
	Then("a non-numeric item is caught before the engine sees it",
	     RaisesOneSample([1, "two", 3], 0), TRUE)
EndScenario()

Summary()

func RaisesPaired(a, b)
	bR = FALSE
	try
		aIgnored = StzTTestPaired(a, b)
	catch
		bR = TRUE
	done
	return bR

func RaisesAnova(a)
	bR = FALSE
	try
		aIgnored = StzAnovaOneWay(a)
	catch
		bR = TRUE
	done
	return bR

func RaisesCorr(a, b)
	bR = FALSE
	try
		aIgnored = StzCorrelationTest(a, b)
	catch
		bR = TRUE
	done
	return bR

func RaisesGof(a, b)
	bR = FALSE
	try
		aIgnored = StzChiSquareGoodnessOfFit(a, b)
	catch
		bR = TRUE
	done
	return bR

func RaisesOneSample(a, n)
	bR = FALSE
	try
		aIgnored = StzTTestOneSample(a, n)
	catch
		bR = TRUE
	done
	return bR

func Rnd4(n)
	return ceil(n * 10000 - 0.5) / 10000
func Rnd7(n)
	return ceil(n * 10000000 - 0.5) / 10000000
func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000
