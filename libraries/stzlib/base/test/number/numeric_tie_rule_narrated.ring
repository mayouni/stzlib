load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 2 of the numeric foundation, applied to the first frame that needs it: THE
# TIE RULE.
#
# Scope-Oriented Programming's move M3 says the governing frame belongs IN THE VERB
# AT THE CALL SITE -- regex says MatchLine() rather than Match() with a flag set
# three lines up; system says App(:x).System() rather than a floating
# CurrentSystem(). Rounding has exactly that disease: what happens to 2.5 is
# invisible where you wrote it, it changes the answer, and money depends on it.
#
# So the mode is now something you SAY:
#
#     oPrice.RoundedToHalfEven(2)      banker's -- the accounting default
#     oPrice.RoundedToHalfUp(2)        away from zero -- the commercial one
#
# WHY HALF-EVEN EXISTS, since it looks arbitrary until you see it: half-up is
# BIASED. Every tie moves the same way, so across a long ledger the total drifts
# upward. Half-even sends half the ties down and half up, and the bias cancels.
#
# These round the DIGITS, not a double. That matters: rounding through an f64
# inherits binary tie behaviour (1.005 is really 1.00499...) and Ring's 14-place
# ceiling, and cannot express half-even at all.

Scenario("the four ties everyone uses to check a rounding mode")
	Then("half-up sends 0.5 to 1", (new stzNumber("0.5")).RoundedToHalfUp(0), "1")
	Then("...1.5 to 2", (new stzNumber("1.5")).RoundedToHalfUp(0), "2")
	Then("...2.5 to 3", (new stzNumber("2.5")).RoundedToHalfUp(0), "3")
	Then("...and 3.5 to 4", (new stzNumber("3.5")).RoundedToHalfUp(0), "4")

	Then("half-even sends 0.5 to 0", (new stzNumber("0.5")).RoundedToHalfEven(0), "0")
	Then("...1.5 to 2", (new stzNumber("1.5")).RoundedToHalfEven(0), "2")
	Then("...2.5 to 2, not 3", (new stzNumber("2.5")).RoundedToHalfEven(0), "2")
	Then("...and 3.5 to 4", (new stzNumber("3.5")).RoundedToHalfEven(0), "4")
	# 0, 2, 2, 4 -- every tie lands on an even digit, which is the whole idea.
EndScenario()

Scenario("only a TIE is decided by the mode; everything else is just rounding")
	Then("0.4 goes down under either", (new stzNumber("0.4")).RoundedToHalfEven(0), "0")
	Then("...and half-up agrees", (new stzNumber("0.4")).RoundedToHalfUp(0), "0")
	Then("0.6 goes up under either", (new stzNumber("0.6")).RoundedToHalfEven(0), "1")
	Then("...and half-up agrees", (new stzNumber("0.6")).RoundedToHalfUp(0), "1")

	Given("a tail that only LOOKS like a tie")
	Then("0.51 is more than half, so it rises even under half-even",
	     (new stzNumber("0.51")).RoundedToHalfEven(0), "1")
	Then("0.4999 is less than half, so it falls even under half-up",
	     (new stzNumber("0.4999")).RoundedToHalfUp(0), "0")
	Then("0.500 IS a tie -- trailing zeros do not change that",
	     (new stzNumber("0.500")).RoundedToHalfEven(0), "0")
	# comparing the discarded tail against one half has to look past the first
	# digit: "5" is a tie, "50" and "500" are ties, "51" is not.
EndScenario()

Scenario("money, where the difference is the point")
	Then("1.005 to two places is 1.01 commercially",
	     (new stzNumber("1.005")).RoundedToHalfUp(2), "1.01")
	Then("...and 1.00 by banker's", (new stzNumber("1.005")).RoundedToHalfEven(2), "1.00")
	Then("0.125 is 0.13 or 0.12", (new stzNumber("0.125")).RoundedToHalfUp(2), "0.13")
	Then("...depending on the rule you named", (new stzNumber("0.125")).RoundedToHalfEven(2), "0.12")
	Then("2.345 splits the same way", (new stzNumber("2.345")).RoundedToHalfEven(2), "2.34")
	Then("...but 0.135 does not, because 3 is odd",
	     (new stzNumber("0.135")).RoundedToHalfEven(2), "0.14")

	# Note 1.005: through an f64 this rounds to 1.00 under BOTH modes, because the
	# double nearest 1.005 is 1.00499... and so is not a tie at all. Rounding the
	# DIGITS gives the decimal truth, which is what a price wants.
EndScenario()

Scenario("the carry, which is where digit-rounding usually breaks")
	Then("9.99 to one place carries into the units", (new stzNumber("9.99")).RoundedToHalfUp(1), "10.0")
	Then("9.999 to none carries twice", (new stzNumber("9.999")).RoundedToHalfUp(0), "10")
	Then("99.95 carries through both", (new stzNumber("99.95")).RoundedToHalfEven(1), "100.0")
	Then("19.995 reaches twenty", (new stzNumber("19.995")).RoundedToHalfUp(2), "20.00")
	# the kept digits are incremented AS ONE INTEGER through the engine, so the
	# carry runs into the integer part instead of stopping at the decimal point.

	Given("asking for more places than the value has")
	Then("it pads rather than inventing", (new stzNumber("1.5")).RoundedToHalfEven(3), "1.500")
	Then("...and an integer gains a fraction", (new stzNumber("7")).RoundedToHalfUp(2), "7.00")
EndScenario()

Scenario("negatives round by magnitude, and never to minus zero")
	Then("-1.5 goes away from zero under half-up", (new stzNumber("-1.5")).RoundedToHalfUp(0), "-2")
	Then("...and to the even digit under half-even", (new stzNumber("-2.5")).RoundedToHalfEven(0), "-2")
	Then("-0.5 rounds to plain 0, not -0", (new stzNumber("-0.5")).RoundedToHalfEven(0), "0")
	Then("...and so does -0.4", (new stzNumber("-0.4")).RoundedToHalfUp(0), "0")
	# "-0" is a real thing in floating point and a nuisance everywhere else; a value
	# that rounds to nothing is zero.
EndScenario()

Scenario("the historical verb is untouched")
	# RoundedTo() keeps its half-up behaviour, so nothing that already worked moves.
	# The mode is something you ASK for -- which is the paradigm's point: a frame you
	# can see beats a default you have to remember.
	Then("RoundedTo still rounds half-up", (new stzNumber("2.5")).RoundedTo(0), "3")
	Then("...and still tidies trailing zeros", (new stzNumber("12.456")).RoundedTo(4), "12.456")
	Then("...and still gets 100.4 right", (new stzNumber("100.4")).RoundedTo(0), "100")
EndScenario()

Summary()
