load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 2 of the numeric foundation is NUMERIC SCOPE -- naming the rounding mode,
# the precision and the overflow policy at the call site instead of leaving them to
# an invisible frame. This slice is the prerequisite nobody would think to ask for:
# BEFORE naming a rounding MODE, rounding itself has to be right.
#
# It was not. RoundTo tidied its result with a trailing-zero strip applied to the
# WHOLE string:
#
#     RoundToXT(...).ToStzString().RemoveThisTrailingCharQ("0").RemovedFromEnd(".")
#
# That is safe only while a decimal point survives the rounding. Once it does not,
# the strip walks straight into the integer:
#
#     RoundedTo(0) of  10.4   ->  "1"      a 10x error
#     RoundedTo(0) of 100.4   ->  "1"      a 100x error
#     RoundedTo(0) of  10.04  ->  "1"
#     RoundedTo(0) of 0.125   ->  ""       and then the constructor RAISED
#
# Silently, in the method every caller uses to round a number. NOT ONE of the 88
# tests in this directory caught it, because none of them rounded a value whose
# result ends in a zero -- which is exactly how a defect this size survives.

Scenario("a trailing zero LEFT of the point is a place value, not noise")
	Then("ten point four rounds to ten", (new stzNumber("10.4")).RoundedTo(0), "10")
	Then("...not to one", (new stzNumber("10.4")).RoundedTo(0) != "1", TRUE)
	Then("a hundred point four rounds to a hundred", (new stzNumber("100.4")).RoundedTo(0), "100")
	Then("...and ten point oh four to ten", (new stzNumber("10.04")).RoundedTo(0), "10")
	Then("a value that rounds to zero says zero", (new stzNumber("0.125")).RoundedTo(0), "0")
	# that last one used to RAISE, because "0" stripped of its zeros is the empty
	# string and the constructor -- correctly -- refuses to build a number from it.

	Then("rounding up past the zero still works", (new stzNumber("20.6")).RoundedTo(0), "21")
	Then("...and carries", (new stzNumber("1000.7")).RoundedTo(0), "1001")
	Then("negatives keep their magnitude", (new stzNumber("-10.4")).RoundedTo(0), "-10")
EndScenario()

Scenario("the tidying that WAS intended still happens")
	# Stripping trailing zeros is deliberate, not a bug to remove: test
	# 61_roundedto records RoundedTo(4) of 12.456 as "12.456" and not "12.4560".
	# The rule was right; its SCOPE was wrong. It now applies to the fractional part
	# only -- the same rule, and the same helper, that RemoveZerosFromRight uses.
	oPi = new stzNumber("12.456")
	Then("asking for more places than exist adds none", oPi.RoundedTo(4), "12.456")
	Then("...however many more", oPi.RoundedTo(5), "12.456")
	Then("asking for fewer rounds", oPi.RoundedTo(2), "12.46")
	Then("...and fewer still", oPi.RoundedTo(1), "12.5")
	Then("...down to a whole number", oPi.RoundedTo(0), "12")

	Then("a value whose places are all zeros tidies to the integer",
	     (new stzNumber("1.005")).RoundedTo(2), "1")
	# 1.005 is 1.00499... as a double, so two places really is 1.00, and 1.00
	# tidied is 1. Correct on both counts -- checked before assuming a defect.
EndScenario()

Scenario("what rounding does to ties, stated rather than assumed")
	# The mode is HALF-UP today: a tie goes away from zero. Half-even (banker's),
	# which the plan calls for as the accounting default, would answer 0, 2, 2, 4
	# for these -- the difference is worth stating out loud, because it is invisible
	# at the call site and money depends on it.
	Then("0.5 rounds to 1", (new stzNumber("0.5")).RoundedTo(0), "1")
	Then("1.5 rounds to 2", (new stzNumber("1.5")).RoundedTo(0), "2")
	Then("2.5 rounds to 3 -- half-even would say 2", (new stzNumber("2.5")).RoundedTo(0), "3")
	Then("3.5 rounds to 4", (new stzNumber("3.5")).RoundedTo(0), "4")
	Then("and a negative tie goes away from zero too",
	     (new stzNumber("-1.5")).RoundedTo(0), "-2")

	# This scenario asserts the CURRENT behaviour deliberately, so that introducing a
	# named half-even mode is a decision that shows up here as a change, rather than
	# something that quietly alters every existing total.
EndScenario()

Summary()
