load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 1 (slice 3, the last) of the numeric foundation: RATIONALS -- exact
# fractions p/q, and the rung of the ladder that decimals cannot reach.
#
# Slice 1 made decimal arithmetic exact by computing on scaled integers, and it is
# honest about the one thing it cannot do: a third has no finite decimal form, so
#
#     (new stzNumber("1")).Divide(3)   -->  0.333333, IsExact() FALSE
#
# and the object says why. As a FRACTION the same value is exact, and the sum that
# the plan opens its Pillar 1 example with becomes true:
#
#     "1/3" + "2/3"  is exactly  1
#
# Stored as the content string "p/q", always in LOWEST TERMS, sign on the
# numerator, collapsing to a plain integer when the denominator reduces to 1.
# Every operation ends in a reduction, which is why the gcd went into the engine
# (std.math.big) rather than being an Euclid loop across the Ring boundary.

Scenario("a fraction arrives in lowest terms")
	Then("a third is itself", (new stzNumber("1/3")).Content(), "1/3")
	Then("two quarters reduce", (new stzNumber("2/4")).Content(), "1/2")
	Then("six thirds reduce past being a fraction at all", (new stzNumber("6/3")).Content(), "2")
	Then("...and report themselves as an integer", (new stzNumber("4/2")).Representation(), :integer)
	Then("a zero numerator is just zero", (new stzNumber("0/5")).Content(), "0")

	Then("the sign lives on the numerator", (new stzNumber("-1/2")).Content(), "-1/2")
	Then("...even when it was written on the denominator", (new stzNumber("1/-2")).Content(), "-1/2")
	# 1/-2 and -1/2 are the same number; keeping one form means two equal numbers
	# compare equal without a special case for where the minus sign was typed.

	Then("a fraction knows what it is", (new stzNumber("1/3")).Representation(), :rational)
	Then("...and answers the predicate", (new stzNumber("1/3")).IsRational(), TRUE)
	Then("while a decimal does not", (new stzNumber("0.5")).IsRational(), FALSE)
EndScenario()

Scenario("exact arithmetic, including the sum decimals cannot do")
	oThird = new stzNumber("1/3")
	oThird.Add("2/3")
	Then("a third plus two thirds is ONE", oThird.Content(), "1")
	Then("...exactly", oThird.IsExact(), TRUE)
	Then("...and equals the number 1", oThird.Same(1), TRUE)
	# THE POINT OF THE WHOLE SLICE. Through decimals this is 0.333333 + 0.666667,
	# which is 1.000000 only by luck of rounding and cannot be claimed as exact.

	Then("a third plus a sixth", (new stzNumber("1/3")).AddQ("1/6").Content(), "1/2")
	Then("a half less a third", (new stzNumber("1/2")).SubtractQ("1/3").Content(), "1/6")
	Then("two thirds of three quarters", (new stzNumber("2/3")).MultiplyByQ("3/4").Content(), "1/2")
	Then("a half divided by a quarter is two", (new stzNumber("1/2")).DivideQ("1/4").Content(), "2")
	Then("every one of those is exact", (new stzNumber("2/3")).MultiplyByQ("3/4").IsExact(), TRUE)

	When("a fraction meets a whole number")
	Then("a third times three is one", (new stzNumber("1/3")).MultiplyByQ(3).Content(), "1")
	Then("...and adding zero changes nothing", (new stzNumber("1/3")).AddQ(0).Content(), "1/3")
EndScenario()

Scenario("promotion is UPWARD: a fraction meeting a decimal stays a fraction")
	oMix = new stzNumber("1/4")
	oMix.Add("0.25")
	Then("a quarter plus 0.25 is a half", oMix.Content(), "1/2")
	Then("...as a fraction, not 0.5", oMix.Representation(), :rational)
	Then("...and exactly", oMix.IsExact(), TRUE)
	# Both spellings are exact here, so either answer would be defensible -- but the
	# rule has to be decided once rather than per operation, and the representation
	# that can hold EVERY answer exactly is the fraction. 1/3 + 0.5 has no decimal
	# form at all, so choosing decimals would mean choosing to lose it sometimes.
	Then("...which is what lets a third survive meeting a decimal",
	     (new stzNumber("1/3")).AddQ("0.5").Content(), "5/6")
EndScenario()

Scenario("the contrast that justifies the rung")
	oExact = new stzNumber("1/3")
	Then("a third as a FRACTION is exact", oExact.IsExact(), TRUE)
	Then("...and keeps its digits", oExact.Content(), "1/3")

	oDivided = new stzNumber("1")
	oDivided.Divide(3)
	Then("a third by DIVISION is not exact", oDivided.IsExact(), FALSE)
	Then("...and says why", StzFindFirst("does not terminate", oDivided.Why()) > 0, TRUE)
	# Same value, two representations, and the object tells you which one you are
	# holding. That is the exactness register from slice 1 doing its job.

	nThird = (new stzNumber("1/3")).Value()
	Then("a fraction still gives a float when one is needed",
	     nThird > 0.333 and nThird < 0.334, TRUE)
	Then("...the nearest one", Rnd4((new stzNumber("1/4")).Value()), 0.25)
	# NumericValue divides the fraction out. That result is an APPROXIMATION of an
	# exact value, which is the whole reason the fraction is kept as a fraction.
EndScenario()

Scenario("Same() compares NUMBERS across every representation")
	oHalf = new stzNumber("1/2")
	Then("a half is 0.5", oHalf.Same("0.5"), TRUE)
	Then("...whether written as a string or a number", oHalf.Same(0.5), TRUE)
	Then("...and equals another spelling of itself", oHalf.Same("2/4"), TRUE)
	Then("...and is not 0.6", oHalf.Same("0.6"), FALSE)

	Then("a third is NOT 0.333", (new stzNumber("1/3")).Same("0.333"), FALSE)
	Then("...nor 0.3333333333", (new stzNumber("1/3")).Same("0.3333333333"), FALSE)
	# no finite decimal is a third, and saying otherwise would make the exactness
	# claim meaningless. The comparison cross-multiplies through big integers, so it
	# is exact however long the operands are.

	Then("a whole number reached through fractions compares equal",
	     (new stzNumber("2/3")).AddQ("1/3").Same(1), TRUE)
EndScenario()

Scenario("big fractions, because the parts are big integers")
	oBig = new stzNumber("1/99999999999999999999999999999999")
	Then("a 32-digit denominator survives construction",
	     oBig.Content(), "1/99999999999999999999999999999999")
	Then("...and reports as a fraction", oBig.Representation(), :rational)

	oSum = new stzNumber("1/99999999999999999999999999999999")
	oSum.Add("1/99999999999999999999999999999999")
	Then("adding it to itself doubles the numerator",
	     oSum.Content(), "2/99999999999999999999999999999999")
	Then("...exactly", oSum.IsExact(), TRUE)
	# the gcd, the cross-multiplications and the reduction all run on the engine's
	# arbitrary-precision integers, so nothing here is bounded by 2^53.

	Then("a fraction that reduces from big parts still lands on the small answer",
	     (new stzNumber("123456789012345678901234567890/246913578024691357802469135780")).Content(),
	     "1/2")
EndScenario()

Summary()

func Rnd4(n)
	return ceil(n * 10000 - 0.5) / 10000
