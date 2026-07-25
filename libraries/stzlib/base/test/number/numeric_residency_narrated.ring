load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 3 of the numeric foundation: RESIDENCY -- the keystone.
#
# THE MEASUREMENT THIS PHASE EXISTS FOR. Over 200 000 numbers, a Ring loop
# computing mean+variance took 0.04s and the engine took 0.04s -- NO FASTER --
# because marshalling the list was the entire cost. The crossing is the price, not
# the arithmetic.
#
# That is why the plan says residency is not an optimisation of this plane but the
# PRECONDITION for the rest of it: a faster kernel behind a per-call marshalling
# boundary buys almost nothing. SIMD, threads and decompositions are all worth
# doing only once the data stops crossing.
#
# THE RULE, stated once because the library has been ambiguous about it: the ENGINE
# copy is the truth. stzList does the opposite -- Ring owns the content and the
# engine handle is a cache invalidated on write -- and that is right for a general
# list. Here the numbers LIVE in the engine and Ring holds a handle; ToList()
# materialises a view when you actually want to look.

Scenario("numbers that live in the engine")
	oBuf = StzNumBufferQ([ 2, 4, 6, 8 ])
	Then("it knows how many it holds", oBuf.Size(), 4)
	Then("...and can be read one at a time, 1-based", oBuf.Item(1), 2)
	Then("...to the end", oBuf.Item(4), 8)
	Then("a reduction comes back as a scalar", oBuf.Sum(), 20)
	Then("...and another", oBuf.Mean(), 5)

	When("a chain of elementwise operations is applied")
	oBuf.Scale(10).AddScalar(1)
	Then("each was a full pass over resident memory", oBuf.Item(1), 21)
	Then("...with nothing marshalled between them", oBuf.Item(4), 81)
	Then("the view is taken ONCE, at the end", @@(oBuf.ToList()), "[ 21, 41, 61, 81 ]")

	oBuf.Free()
	Then("and it can be released, since Ring has no destructors", oBuf.IsFreed(), TRUE)
	# that burden is named rather than hidden: owning memory outside the interpreter
	# is what buys the residency, and pretending otherwise would be worse.
EndScenario()

Scenario("two buffers, elementwise, without either leaving the engine")
	oA = StzNumBufferQ([ 1, 2, 3 ])
	oB = StzNumBufferQ([ 10, 20, 30 ])

	Then("the dot product is one call and one scalar", oA.Dot(oB), 140)   # 10+40+90

	oA.AddBuffer(oB)
	Then("elementwise addition lands in place", @@(oA.ToList()), "[ 11, 22, 33 ]")
	oA.SubtractBuffer(oB)
	Then("...and subtracts back", @@(oA.ToList()), "[ 1, 2, 3 ]")
	oA.MultiplyBuffer(oB)
	Then("...and multiplies", @@(oA.ToList()), "[ 10, 40, 90 ]")

	Given("buffers of different lengths, where the operation is meaningless")
	oShort = StzNumBufferQ([ 1, 2 ])
	bRaised = FALSE
	try
		oA.AddBuffer(oShort)
	catch
		bRaised = TRUE
	done
	Then("it is REFUSED rather than half-applied", bRaised, TRUE)
	Then("...leaving the buffer untouched", @@(oA.ToList()), "[ 10, 40, 90 ]")

	oA.Free()  oB.Free()  oShort.Free()
EndScenario()

Scenario("built engine-side, so even the filling costs one call")
	oRange = StzNumBufferRangeQ(5, 1, 1)
	Then("a range is written straight into resident memory", @@(oRange.ToList()), "[ 1, 2, 3, 4, 5 ]")
	Then("...and reduces there too", oRange.Sum(), 15)
	oRange.Free()

	oZeros = StzNumBufferOfSizeQ(4)
	Then("a sized buffer starts at zero", oZeros.Sum(), 0)
	oZeros.FillWith(7)
	Then("...and fills without a list ever existing in Ring", oZeros.Sum(), 28)
	oZeros.Free()
	# building 200 000 numbers as a Ring list only to marshal them is the very cost
	# this phase is about; a range or a fill never pays it.
EndScenario()

Scenario("the sum is COMPENSATED, which matters exactly when a buffer is big")
	oBig = StzNumBufferOfSizeQ(1001)
	oBig.FillWith(1)
	oBig.SetItem(1, number("1e16"))

	Then("the compensated sum keeps the thousand ones",
	     oBig.Sum() = (number("1e16") + 1000), TRUE)
	# a naive running total answers exactly 1e16 here: once the total is 1e16, each
	# 1.0 falls off the end of the mantissa and is simply lost. Neumaier
	# compensation carries that lost part along and adds it back. It costs one extra
	# add per element and removes an error class that is INVISIBLE until the data
	# gets big -- which is precisely when a buffer like this is used.
	oBig.Free()
EndScenario()

Scenario("the variance convention is asked of the one authority, not decided again")
	oV = StzNumBufferQ([ 2, 4, 4, 4, 5, 5, 7, 9 ])
	Then("population, by name", oV.VariancePopulation(), 4)
	Then("sample, by name", Rnd2(oV.VarianceSample()), 4.57)
	Then("the default is sample, as everywhere else since phase 0",
	     oV.Variance(), oV.VarianceSample())
	Then("standard deviation follows it", oV.StddevPopulation(), 2)
	# numbuf.zig calls stats.varianceDivisor rather than choosing a divisor. The
	# phase-0 repair exists precisely because two modules once chose their own, and
	# a third would have re-created the bug in a new place.
	oV.Free()
EndScenario()

Scenario("a copy is independent, because the truth is engine-side")
	oOrig = StzNumBufferQ([ 1, 2, 3 ])
	oCopy = oOrig.Copy()
	oCopy.Scale(100)
	Then("the copy moved", @@(oCopy.ToList()), "[ 100, 200, 300 ]")
	Then("...and the original did not", @@(oOrig.ToList()), "[ 1, 2, 3 ]")
	# worth asserting because Ring copies objects on assignment and list insertion:
	# a buffer that shared its handle would have two owners of one allocation, and
	# freeing either would poison the other.
	oOrig.Free()  oCopy.Free()
EndScenario()

Summary()

func Rnd2(n)
	return ceil(n * 100 - 0.5) / 100
