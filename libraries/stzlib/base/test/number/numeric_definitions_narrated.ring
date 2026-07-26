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

Scenario("a confidence interval that is finally the one it claimed to be")
	# THREE STAGES, and this scenario has been rewritten at each of them -- worth
	# saying plainly, because a guard whose expectations change is either tracking a
	# real capability change or being bent to fit. This is the first kind.
	#
	#   originally  ConfidenceInterval() was labelled "t-distribution" and hardcoded
	#               three z values. Any level but 90/95/99 SILENTLY returned the 95%
	#               interval -- a wrong answer wearing a right answer's face.
	#   phase 0     eight published levels, RAISING on anything else, `:method`
	#               reported as :normal, and a warning on small n. Honest, but still
	#               a z interval and still restricted: the engine had no inverse
	#               incomplete beta, so a t value could not be computed at all.
	#   phase 4     special.zig supplies the incomplete beta, so the interval is now
	#               genuinely t-based, at any level, with no table.
	#
	# The assertions phase 0 wrote pinned the LIMITATION -- `:method = :normal`, a
	# critical value of 1.96, a raise mentioning "incomplete beta". Phase 4 removes
	# the limitation, so those assertions had to go with it.
	oData = new stzDataSet([ 10, 20, 30, 40, 50 ])
	aCI = oData.ConfidenceInterval(95)

	# n = 5, so df = 4 and t = 2.77644511, where z was 1.95996398.
	# s = sqrt(250) = 15.81138830, so the margin is
	#   2.77644511 * 15.81138830 / sqrt(5) = 19.63243161
	# giving [10.36756839, 49.63243161] where z gave [16.14, 43.86].
	Then("the 95% interval now uses t, so it is WIDER than the old z one",
	     Rnd2(aCI[1]), 10.37)
	Then("...upper bound too", Rnd2(aCI[2]), 49.63)
	Then("the old z interval was [16.14, 43.86] -- narrower by 41%",
	     Rnd2(aCI[2] - aCI[1]) > Rnd2(43.86 - 16.14), TRUE)

	When("a level no table ever held is asked for")
	Then("97% simply works now", len(oData.ConfidenceInterval(97)), 2)
	Then("...as does 42%", len(oData.ConfidenceInterval(42)), 2)
	Then("...and 99.99%", len(oData.ConfidenceInterval(99.99)), 2)
	# the phase-0 raise, and the "Supported:" list it named, are gone -- there is
	# nothing left to be unsupported.

	Then("a higher level is a wider interval, monotonically",
	     oData.ConfidenceInterval(99)[2] > oData.ConfidenceInterval(95)[2], TRUE)
	Then("...and a lower one narrower",
	     oData.ConfidenceInterval(80)[2] < aCI[2], TRUE)

	Then("the common levels are still published, as a starting point not a limit",
	     len(StzNormalConfidenceLevels()) >= 8, TRUE)
	Then("...and 95 is among them", StzFindFirst(95, StzNormalConfidenceLevels()) > 0, TRUE)

	When("a level outside 0..100 is asked for, which is not a level at all")
	bBad = FALSE
	try
		oData.ConfidenceInterval(140)
	catch
		bBad = TRUE
	done
	Then("that still raises", bBad, TRUE)
EndScenario()

Scenario("...and it says which distribution it used")
	oSmall = new stzDataSet([ 12, 15, 11, 14, 13 ])          # n = 5
	aXT = oSmall.ConfidenceIntervalXT(95)

	Then("the method is t, not normal", aXT[:method], :t)
	Then("...with the t critical value for 4 degrees of freedom",
	     Rnd2(aXT[:critical]), 2.78)
	Then("...the degrees of freedom are reported", aXT[:df], 4)
	Then("...and the sample size", aXT[:n], 5)
	Then("there is no warning left to give, because nothing is approximated",
	     aXT[:note], "")
	# The phase-0 note said "this NORMAL approximation understates the interval; a
	# t-based interval would be wider". It is the t-based interval now, so the note
	# would be false rather than merely unnecessary.

	Then("t is 41% wider than z here, exactly as the old warning said",
	     Rnd2(StzTCriticalValue(95, 4) / StzNormalCriticalValue(95)), 1.42)

	When("the sample is large, where t and z agree")
	an = []
	for i = 1 to 5000
		an + ((i % 50) + 1)
	next
	aBig = (new stzDataSet(an)).ConfidenceIntervalXT(95)
	Then("the critical value has converged on z to two decimals",
	     Rnd2(aBig[:critical]), Rnd2(StzNormalCriticalValue(95)))
	Then("...and it is STILL reported as t, since that is what it is",
	     aBig[:method], :t)
	# which is why there is no small-sample threshold any more: t is correct at
	# every n and converges on z by itself.

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
