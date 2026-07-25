load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 1 (slice 1) of the numeric foundation: EXACTNESS, and the number saying so.
#
# The plan opens on this line:
#
#     ? (9007199254740992 + 1) = 9007199254740992      # --> 1  (TRUE)
#
# Ring's number is a C double, so integer exactness ends at 2^53 and 0.1 + 0.2 is
# not 0.3. What this slice does is stop stzNumber INHERITING those limits, because
# it never had to: it stores its value as a STRING, so the digits were always
# there -- the arithmetic was throwing them away by routing through an f64.
#
# Two defects, one chokepoint (pvtCalculate):
#
#   1. The result's decimal places came from the RECEIVER alone, for every
#      operation. Right for + and - sometimes, never right for *. It gave
#      0.1 * 0.1 = 0.0 and 19.99 * 0.15 = 3.00 -- money quietly wrong.
#   2. Integers beyond 2^53 were flattened, though the engine has had correct
#      arbitrary-precision integers all along.
#
# Both are now computed on SCALED INTEGERS through the engine: 19.99 * 0.15 becomes
# 1999 * 15 = 29985 with the point four from the right. Exact by construction, not
# f64-then-rounded-and-hope.
#
# (The chains below use MultiplyByQ, not MultiplyQ: `Multiply` is an alternative
# form of `MultiplyBy` and has no Q twin of its own, which is a gap in the
# library's own "every mutator gets both twins" rule -- noted, not fixed here.)

Scenario("money: the arithmetic a shop needs")
	Then("0.1 + 0.2 is 0.3", (new stzNumber("0.1")).AddQ("0.2").Content(), "0.3")
	Then("0.1 * 0.1 is 0.01, not 0.0", (new stzNumber("0.1")).MultiplyByQ("0.1").Content(), "0.01")
	Then("0.5 * 0.5 is 0.25, not 0.3", (new stzNumber("0.5")).MultiplyByQ("0.5").Content(), "0.25")
	Then("a price times a rate keeps its cents",
	     (new stzNumber("19.99")).MultiplyByQ("0.15").Content(), "2.9985")
	Then("...and times a whole number", (new stzNumber("19.99")).MultiplyByQ(3).Content(), "59.97")
	Then("0.25 * 0.25 is 0.0625", (new stzNumber("0.25")).MultiplyByQ("0.25").Content(), "0.0625")
	Then("0.01 * 0.01 is 0.0001", (new stzNumber("0.01")).MultiplyByQ("0.01").Content(), "0.0001")
	# every one of those returned a coarser number before: the product was rendered
	# to the RECEIVER's decimal places, when a product needs the SUM of both
	# operands' places. 0.1 has one place, so 0.01 was rendered as 0.0.

	When("the operand carries more places than the receiver")
	Then("1 + 0.001 is 1.001, not 1.00", (new stzNumber("1")).AddQ("0.001").Content(), "1.001")
	Then("0.5 + 0.125 is 0.625, not 0.6", (new stzNumber("0.5")).AddQ("0.125").Content(), "0.625")
	Then("10 - 0.001 is 9.999, not 10.00", (new stzNumber("10")).SubtractQ("0.001").Content(), "9.999")
	# addition takes the MAXIMUM of the two place counts; it used to take the
	# receiver's, so the operand's extra places were simply rounded away.
EndScenario()

Scenario("integers past 2^53, which is where Ring's own numbers stop")
	Then("2^53 + 1 is 9007199254740993",
	     (new stzNumber("9007199254740992")).AddQ(1).Content(), "9007199254740993")
	# in raw Ring, (9007199254740992 + 1) = 9007199254740992 is TRUE.

	Then("a 32-digit integer gains one correctly",
	     (new stzNumber("99999999999999999999999999999999")).AddQ(1).Content(),
	     "100000000000000000000000000000000")
	Then("999999999 squared is exact",
	     (new stzNumber("999999999")).MultiplyByQ("999999999").Content(), "999999998000000001")
	Then("a 20-digit product keeps all 40 digits",
	     (new stzNumber("12345678901234567890")).MultiplyByQ("98765432109876543210").Content(),
	     "1219326311370217952237463801111263526900")
	# the engine's std.math.big integers were present and correct all along -- the
	# arithmetic simply never asked them.

	Then("small integer arithmetic is untouched", (new stzNumber("2")).MultiplyByQ("2").Content(), "4")
	# and stays on the fast f64 path, where it is exact anyway. The exact path is
	# taken only when there are decimals, or when the integers could overflow it.
EndScenario()

Scenario("division is exact when it terminates, and says so when it does not")
	Then("1 / 8 is 0.125", (new stzNumber("1")).DivideQ("8").Content(), "0.125")
	Then("0.1 / 4 is 0.025", (new stzNumber("0.1")).DivideQ("4").Content(), "0.025")
	Then("10 / 4 is 2.5", (new stzNumber("10")).DivideQ("4").Content(), "2.5")
	Then("22 / 5 is 4.4", (new stzNumber("22")).DivideQ("5").Content(), "4.4")
	# a quotient terminates only when the reduced denominator has no prime factors
	# besides 2 and 5. Rather than guess a precision, the exact path asks the
	# engine whether scaling by some power of ten divides evenly -- and takes the
	# SHORTEST such form, which is why 1/8 shows as 0.125 and not 0.125000.

	oThird = new stzNumber("1")
	oThird.Divide("3")
	Then("1 / 3 does NOT claim to be exact", oThird.IsExact(), FALSE)
	Then("...and says why", StzFindFirst("does not terminate", oThird.Why()) > 0, TRUE)
EndScenario()

Scenario("the exactness register: the number carries the fact")
	Then("an exact product knows it", (new stzNumber("19.99")).MultiplyByQ("0.15").IsExact(), TRUE)
	Then("...with nothing to explain", (new stzNumber("19.99")).MultiplyByQ("0.15").Why(), "")
	Then("a big-integer sum knows it",
	     (new stzNumber("9007199254740992")).AddQ(1).IsExact(), TRUE)

	oSqrt = new stzNumber("2")
	oSqrt.SquareRoot()
	Then("a square root does not pretend", oSqrt.IsExact(), FALSE)
	Then("...and names the reason", StzFindFirst("no exact decimal result", oSqrt.Why()) > 0, TRUE)
	Then("IsApproximate is its mirror", oSqrt.IsApproximate(), TRUE)
	Then("Exactness() reports the register", oSqrt.Exactness(), :inexact)
	# This is the same habit as the natural layer's evidential register: numeric
	# surprise is almost always about a frame the caller could not see, so the value
	# carries it instead of leaving them to deduce it.
EndScenario()

Scenario("Same(): equality as NUMBERS, not as rendered text")
	oPrice = new stzNumber("1.50")
	Then("1.50 and 1.5 are the same number", oPrice.Same("1.5"), TRUE)
	Then("...whether the other side is a string or a number", oPrice.Same(1.5), TRUE)
	Then("...and 1.6 is not", oPrice.Same("1.6"), FALSE)

	oZero = new stzNumber("0")
	Then("0 and -0 are the same number", oZero.Same("-0"), TRUE)
	Then("...and so is 0.000", oZero.Same("0.000"), TRUE)
	Then("IsSameAs reads the same", oZero.IsSameAs("0.00"), TRUE)

	Then("it compares against another stzNumber too", oPrice.Same(new stzNumber("1.5")), TRUE)
	# Ring's `=` on "1.50" and "1.5" is FALSE -- they are different strings. Same()
	# is the question people actually mean when they compare two prices.
EndScenario()

Scenario("what did NOT change, which is most of it")
	# The fix is confined to arithmetic. Everything else keeps the receiver's own
	# round, because that was never the defect: sin/cos/log/sqrt have no exact
	# decimal form, so the caller's requested precision is the only sensible answer.
	#
	# This scenario exists because the first version of the fix DID change them, and
	# quietly coarsened trigonometry from five places to two. Diffing the whole
	# 88-file number suite against a before-snapshot is what caught it.
	oAngle = new stzNumber("1.57079")
	oAngle.Sine()
	Then("a sine keeps the places the caller asked for", len(oAngle.Content()) > 4, TRUE)

	Then("the round is still readable", (new stzNumber("1.234")).Round(), 3)
	Then("integers report no decimals", (new stzNumber("42")).NumberOfDecimals(), 0)
	Then("...and decimals report theirs", (new stzNumber("1.2345")).NumberOfDecimals(), 4)
EndScenario()

Summary()
