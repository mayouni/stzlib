load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 0 of the numeric foundation (SOFTANZA_NUMERIC_FOUNDATION.md): pay the three
# defects that probing the library turned up, before building anything new on top of
# them.
#
# All three are the same species of bug -- a numeric answer that is confidently
# wrong, or two answers to one question -- which is why they come first. A number
# layer people cannot trust is worse than a slow one.
#
#   1. "Variance" meant two different things depending on which class you held.
#   2. ConfidenceInterval was labelled t, computed z, and silently substituted the
#      95% interval for any level it did not recognise.
#   3. Two alias methods called methods that never existed.

Scenario("ONE definition of variance, and the convention is in the NAME")
	# the textbook set: population variance 4, sample variance 4.571...
	an = [ 2, 4, 4, 4, 5, 5, 7, 9 ]
	oList = new stzListOfNumbers(an)
	oData = new stzDataSet(an)

	Then("a list and a dataset now AGREE", Rnd2(oList.Variance()), Rnd2(oData.Variance()))
	Then("...on the sample variance, which is the library default", Rnd2(oList.Variance()), 4.57)
	# they did not before: stzList divided the sum of squares by N and stzDataSet by
	# N-1, so the same eight numbers had two variances and neither said which.

	When("you would rather not rely on knowing the default")
	Then("the sample convention can be asked for by name", Rnd2(oList.VarianceSample()), 4.57)
	Then("...and so can the population one", Rnd2(oList.VariancePopulation()), 4)
	Then("the dataset answers the same two questions", Rnd2(oData.VarianceSample()), 4.57)
	Then("...identically", Rnd2(oData.VariancePopulation()), 4)

	Then("standard deviation follows its variance", Rnd2(oList.Stddev()), 2.14)
	Then("...sample, by name", Rnd2(oList.StddevSample()), 2.14)
	Then("...population, by name", Rnd2(oList.StddevPopulation()), 2)
	Then("and the dataset agrees there too", Rnd2(oData.StandardDeviationPopulation()), 2)

	# Neither convention is wrong. R's var() and pandas' .var() are sample; NumPy's
	# np.var is population -- which is exactly why a library has to NAME its choice
	# rather than have one.
EndScenario()

Scenario("the divisor is decided in ONE place, so the paths cannot drift apart")
	an = [ 2, 4, 4, 4, 5, 5, 7, 9 ]
	pStats = StzEngineStatsCreate(an)

	Then("the engine's stats module offers both, named",
	     Rnd2(StzEngineStatsVarianceSample(pStats)), 4.57)
	Then("...and the population one", Rnd2(StzEngineStatsVariancePopulation(pStats)), 4)
	Then("its default is the sample variance",
	     StzEngineStatsVariance(pStats), StzEngineStatsVarianceSample(pStats))

	Then("the LIST module now answers the same way", Rnd2((new stzList(an)).Variance()), 4.57)
	Then("...because it asks stats.zig for the divisor rather than choosing one",
	     Rnd2((new stzList(an)).VariancePopulation()), 4)
	# the sum-of-squares loop still lives with its data -- only list.zig has to skip
	# non-numeric items. What moved is the one genuinely ambiguous decision.

	Given("a single observation, where the two conventions diverge sharply")
	oOne = new stzListOfNumbers([ 7 ])
	Then("a population variance is 0 -- the one value IS the population", oOne.VariancePopulation(), 0)
	Then("a sample variance is undefined, reported as 0 rather than a division by zero",
	     oOne.VarianceSample(), 0)
EndScenario()

Scenario("a confidence interval that does not misrepresent itself")
	oData = new stzDataSet([ 10, 20, 30, 40, 50 ])

	aCI = oData.ConfidenceInterval(95)
	Then("the 95% interval is unchanged", Rnd2(aCI[1]), 16.14)
	Then("...upper bound too", Rnd2(aCI[2]), 43.86)

	When("a level the table does not hold is asked for")
	bRaised = FALSE
	cWhy = ""
	try
		oData.ConfidenceInterval(97)
	catch
		bRaised = TRUE
		cWhy = cCatchError
	done
	Then("it RAISES", bRaised, TRUE)
	Then("...naming the levels it does support", StzFindFirst("Supported:", cWhy) > 0, TRUE)
	Then("...and saying what is missing to do better",
	     StzFindFirst("incomplete beta", cWhy) > 0, TRUE)
	# it used to return the 95% interval for 97, 80, 42 or anything else -- a wrong
	# answer wearing a right answer's face, which is the worst kind.

	When("a level the table DOES hold is asked for")
	a80 = oData.ConfidenceInterval(80)
	Then("80% is genuinely narrower than 95%", a80[2] < aCI[2], TRUE)
	Then("...and differs from it at all", Rnd2(a80[1]) != Rnd2(aCI[1]), TRUE)
	Then("the supported levels are published, not folklore",
	     len(StzNormalConfidenceLevels()) >= 8, TRUE)
	Then("...and 95 is among them", StzFindFirst(95, StzNormalConfidenceLevels()) > 0, TRUE)
EndScenario()

Scenario("...and it tells you what it did, and where it is weak")
	oSmall = new stzDataSet([ 12, 15, 11, 14, 13 ])          # n = 5
	aXT = oSmall.ConfidenceIntervalXT(95)

	Then("the method is named", aXT[:method], :normal)
	Then("...with the critical value it used", Rnd2(aXT[:critical]), 1.96)
	Then("...and the sample size", aXT[:n], 5)
	Then("a small sample earns a warning", len(aXT[:note]) > 0, TRUE)
	Then("...that says which way the error goes",
	     StzFindFirst("understates", aXT[:note]) > 0, TRUE)
	# THE HONEST POSITION. This is a z interval: for n=5 the correct t margin is
	# 2.776*s/sqrt(n), not 1.96*s/sqrt(n), so the interval really is too narrow --
	# by 41% here. Fixing that needs an inverse incomplete beta function, which the
	# engine does not have (phase 4). What phase 0 buys is that the method no longer
	# CLAIMS to be a t interval, and says out loud where it is weak.

	When("the sample is large enough for the approximation to hold")
	an = []
	for i = 1 to 40
		an + ((i % 7) + 10)      # parenthesised: `an + x + y` appends TWICE in Ring
	next
	aBig = (new stzDataSet(an)).ConfidenceIntervalXT(95)
	Then("there is no warning", aBig[:note], "")
	Then("...and n is reported", aBig[:n], 40)

	Given("fewer than two observations, where no interval exists")
	aNone = (new stzDataSet([ 5 ])).ConfidenceIntervalXT(95)
	Then("the method says none", aNone[:method], :none)
	Then("...and explains rather than returning a bare [0,0]",
	     StzFindFirst("at least two", aNone[:note]) > 0, TRUE)
EndScenario()

Scenario("two aliases that called methods which never existed")
	oData = new stzDataSet([ 10, 20, 30, 40, 50 ])

	Then("ConfInt() works", len(oData.ConfInt()), 2)
	Then("...and agrees with the 95% default", Rnd2(oData.ConfInt()[1]), Rnd2(oData.ConfidenceInterval(95)[1]))
	# it called This.ConfidentialInterval() -- a misspelling of a method that does
	# not exist -- and raised R14 for every caller, forever.

	Then("BoxPlotData() works", len(oData.BoxPlotData()) > 0, TRUE)
	Then("...and agrees with the method it aliases",
	     len(oData.BoxPlotData()), len(oData.BoxPlotStats()))
	# it called This.BoxPlot(); the real method is BoxPlotStats(). This one was NOT
	# in the original defect list -- it was found by auditing every This.X() call in
	# the class against the methods its inheritance chain actually defines. That
	# audit is worth repeating on any class with a long alias tail: a broken alias
	# raises only when someone finally calls it.
EndScenario()

Summary()

func Rnd2(n)
	return ceil(n * 100 - 0.5) / 100
