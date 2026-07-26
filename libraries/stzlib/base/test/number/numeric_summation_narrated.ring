load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 3 of the numeric foundation, third slice: ONE SUMMATION.
#
# Adding f64s left to right silently loses the low bits of every addend once the
# running total grows large relative to them. Add 1e16 and then a thousand 1.0s
# and a naive loop answers exactly 1e16 -- each 1.0 is smaller than the last bit
# of the mantissa at that magnitude, so it lands nowhere. NEUMAIER COMPENSATION
# carries the lost part in a second accumulator and adds it back at the end: one
# extra add per element, and an error class that is invisible until the data gets
# big simply disappears.
#
# THE POINT OF THIS GUARD IS NOT THE ALGORITHM. It is that the algorithm has ONE
# home. stzNumBuffer arrived in the previous slice with a compensated sum while
# stats.zig and list.zig kept naive ones, so the SAME 1001 numbers gave two
# different answers depending on which door they went through:
#
#     stzListOfNumbers.Sum()  ->  10000000000000000     the thousand ones, lost
#     stzDataSet.Sum()        ->  10000000000000000     lost again
#     stzNumBuffer.Sum()      ->  10000000000001000     right
#
# That is the phase-0 disease -- two definitions of one thing -- recreated in a
# new place by the very phase that added the correct version. So summation moved
# next to the variance divisor in stats.zig, and everyone asks it.

Scenario("the case that separates a compensated sum from a naive one")
	an = [ number("1e16") ]
	for i = 1 to 1000
		an + 1
	next

	Then("a thousand ones were added to ten quadrillion", len(an), 1001)
	oL = new stzListOfNumbers(an)
	nGot = oL.Sum()
	Then("...and the total keeps every one of them", nGot, number("1e16") + 1000)
	# a naive loop answers 1e16 here. Not approximately: exactly, every time.
EndScenario()

Scenario("...and every door gives the same answer, which is the actual repair")
	an = [ number("1e16") ]
	for i = 1 to 1000
		an + 1
	next

	oList = new stzListOfNumbers(an)
	oData = new stzDataSet(an)
	oBuf  = StzNumBufferQ(an)

	nTrue = number("1e16") + 1000
	Then("stzListOfNumbers", oList.Sum(), nTrue)
	Then("stzDataSet", oData.Sum(), nTrue)
	Then("stzNumBuffer", oBuf.Sum(), nTrue)

	Then("list and dataset agree", oList.Sum() = oData.Sum(), TRUE)
	Then("dataset and buffer agree", oData.Sum() = oBuf.Sum(), TRUE)

	When("the mean is asked, since it is a sum divided by a count")
	Then("list and dataset agree", oList.Mean() = oData.Mean(), TRUE)
	Then("dataset and buffer agree", oData.Mean() = oBuf.Mean(), TRUE)

	oBuf.Free()
EndScenario()

Scenario("compensation changes nothing for ordinary data, and that is the point")
	# The repair had to be provable as safe. All 74 tests across number, list-of-
	# numbers, stats, dataset and matrix that touch a sum or a mean were captured
	# with the naive engine and again with the compensated one: six files differed
	# and every difference was a timing line. Not one numeric value moved.
	#
	# The reason is arithmetic, not luck: when the addends are of similar magnitude
	# the compensation term stays zero, so the two algorithms are bit-identical.
	an = [ 2, 4, 4, 4, 5, 5, 7, 9 ]
	oList = new stzListOfNumbers(an)
	Then("a small sum is exactly what it always was", oList.Sum(), 40)
	Then("...and the mean", oList.Mean(), 5)
	oDs = new stzDataSet(an)
	nVar = oDs.VariancePopulation()
	Then("...and the derived statistics are untouched", nVar, 4)

	anMixed = [ 0.1, 0.2, 0.3 ]
	oMix = new stzListOfNumbers(anMixed)
	nMix = Rnd6(oMix.Sum())
	Then("even where binary floats are already lossy, nothing new is introduced",
	     nMix, 0.6)
EndScenario()

Scenario("the whole-number cases the engine keeps as integers")
	# list.zig stores ints, floats and mixed items in three different
	# representations, so there were three naive loops, and all three now feed the
	# same accumulator.
	oInts = new stzListOfNumbers([ 1, 2, 3, 4, 5 ])
	Then("integers", oInts.Sum(), 15)

	oFloats = new stzListOfNumbers([ 1.5, 2.5, 3.5 ])
	Then("floats", oFloats.Sum(), 7.5)

	oMixed = new stzListOfNumbers([ 1, 2.5, 3 ])
	Then("mixed", oMixed.Sum(), 6.5)
EndScenario()

Summary()

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
