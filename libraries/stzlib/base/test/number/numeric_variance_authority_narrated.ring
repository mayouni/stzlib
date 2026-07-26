load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 4 of the numeric foundation, third slice: THE CENTERED SUM OF SQUARES.
#
# After slice 2 vectorised the summation, variance was the laggard: it had moved
# only from 0.20s to 0.15s, because its own second pass -- the centered sum of
# squares -- was still a scalar loop, and was now the dominant term.
#
# Looking for that one loop found FIVE of it: stats.zig, numbuf.zig, list.zig and
# TWICE in pivot.zig. This is the third time this exact shape has appeared in the
# numeric layer, and each time the duplication was defended by a different
# reasonable-sounding argument:
#
#   phase 0  the variance DIVISOR was chosen independently in two modules, and
#            they disagreed -- stzList said 4 where stzDataSet said 4.57
#   phase 3  the SUMMATION was written three times, one compensated and two naive,
#            so the same 1001 numbers gave two different totals
#   phase 4  the SUM OF SQUARES was written five times. Phase 0 deliberately left
#            it with its data, reasoning that only the divisor was ever ambiguous
#
# That phase-0 reasoning was wrong in an instructive way. Nobody disagreed about
# the arithmetic -- and it still drifted, because the fifth copy (pivot.zig) also
# hardcoded `values.len - 1` instead of asking varianceDivisor, and computed its
# mean with a naive sum. It agreed with everyone else only by the accident that
# N-1 happens to be the documented default.
#
# THE LESSON, worth more than the speedup: DUPLICATION INVITES DIVERGENCE EVEN
# WHERE THERE IS NO AMBIGUITY TO DIVERGE ABOUT. "This part was never in doubt" is
# not a reason to write it twice.

Scenario("one definition, so agreement is not a coincidence")
	aT = [ 2, 4, 4, 4, 5, 5, 7, 9 ]     # the textbook set: 4 and 32/7
	oList = new stzList(aT)
	oBuf  = StzNumBufferQ(aT)
	oData = new stzDataSet(aT)

	Then("population, from a list", oList.VariancePopulation(), 4)
	Then("...from a resident buffer", oBuf.VariancePopulation(), 4)
	Then("...from a dataset", oData.VariancePopulation(), 4)

	Then("sample, from a list", Rnd2(oList.VarianceSample()), 4.57)
	Then("...from a resident buffer", Rnd2(oBuf.VarianceSample()), 4.57)
	Then("...from a dataset", Rnd2(oData.VarianceSample()), 4.57)

	Then("and the unnamed default is still sample, as since phase 0",
	     oList.Variance(), oList.VarianceSample())
	oBuf.Free()
EndScenario()

Scenario("the pivot table, which had quietly become a fourth authority")
	# Its .variance and .stdev aggregates spelled out a naive mean, their own sum
	# of squares, AND `values.len - 1` -- bypassing both the divisor authority and
	# the summation authority. Same numbers, asked through a pivot:
	aP = [ [ :GRP, :SUB, :VAL ],
	       [ "a", "x", 2 ], [ "a", "x", 4 ], [ "a", "x", 4 ], [ "a", "x", 4 ],
	       [ "a", "x", 5 ], [ "a", "x", 5 ], [ "a", "x", 7 ], [ "a", "x", 9 ] ]
	oP = new stzPivotTable(aP)
	oP.Analyze(:VAL, :with = "VARIANCE")
	oP.By(:GRP, :and = :SUB)
	oP.Generate()
	Then("the pivot agrees with every other door, by construction now",
	     Rnd2(oP.Value("a", "x")), 4.57)

	oS = new stzPivotTable(aP)
	oS.Analyze(:VAL, :with = "STDEV")
	oS.By(:GRP, :and = :SUB)
	oS.Generate()
	Then("...and its standard deviation is the root of that", Rnd2(oS.Value("a", "x")), 2.14)
EndScenario()

Scenario("dense storage no longer gets boxed just to be measured")
	# The six variance/stddev bridges resolved their argument with getLC, which
	# calls ensureBoxed() -- one heap-allocated *StzValue PER ELEMENT. So asking a
	# million integers for their variance allocated a million boxes to compute what
	# is a mean plus one more pass. Sum, Mean, Min, Max and Product were already
	# dense-aware; variance and standard deviation had been left behind.
	#
	# Measured over 1M integers, ten passes: 0.13s -> 0.04s. The gate is set
	# between them.
	an = []
	for i = 1 to 1000000
		an + (i % 1000)
	next
	oBig = new stzList(an)

	nT0 = clock()
	for k = 1 to 10
		nV = oBig.VarianceSample()
	next
	nT1 = clock()
	Then("ten variances over a million integers stay under a tenth of a second",
	     ((nT1 - nT0) / clockspersecond()) < 0.10, TRUE)

	# and the answer is independently checkable: i % 1000 over exactly 1000 full
	# cycles is the uniform set 0..999, whose population variance is
	# (1000^2 - 1) / 12 = 83333.25
	Then("...and the value is right, not merely fast",
	     Rnd2(oBig.VariancePopulation()), 83333.25)
EndScenario()

Scenario("integer storage and float storage share the one implementation")
	# centeredSumOfSquaresOf is generic over the element type precisely so that
	# list.zig's dense i64 and dense f64 modes do not need a loop each -- writing
	# it twice to satisfy the type system is how five copies started.
	aInts   = [ 2, 4, 4, 4, 5, 5, 7, 9 ]
	aFloats = [ 2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0 ]
	oI = new stzList(aInts)
	oF = new stzList(aFloats)
	Then("an int list and the same numbers as floats agree exactly",
	     oI.VariancePopulation(), oF.VariancePopulation())
	Then("...and on the sample convention too",
	     oI.VarianceSample(), oF.VarianceSample())
EndScenario()

Scenario("a large offset does not swamp a small spread")
	# The two-pass form is chosen over the textbook one-pass sum-of-squares-minus-
	# square-of-sums precisely because the latter catastrophically cancels here.
	# The variance of {1e9, 1e9+1, ...} is exactly that of {0, 1, ...}.
	aBase = []
	aOff  = []
	for i = 0 to 200
		aBase + i
		aOff + (number("1e9") + i)
	next
	oB = StzNumBufferQ(aBase)
	oO = StzNumBufferQ(aOff)
	Then("offsetting every value by 1e9 leaves the variance unchanged",
	     oB.VarianceSample(), oO.VarianceSample())
	oB.Free()  oO.Free()

	# The Chan-Golub-LeVeque correction was implemented and measured against this
	# very case, and REJECTED: it cost 11% and changed no digit, because the mean
	# it corrects for is already compensated. Fixing the summation authority
	# upstream removed the need for the patch downstream.
EndScenario()

Summary()

func Rnd2(n)
	return ceil(n * 100 - 0.5) / 100
