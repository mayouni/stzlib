load "../../stzBase.ring"
load "../_narrated.ring"

# @FunctionNegativeForm reads naturally in compound conditions.
# Archive block #494.

Scenario("Negative-form conditions on a char list")
	o1 = new stzList([ "R", "I", "N", "G" ])
	Then("it is not a string", o1.IsNotAString(), TRUE)
	Then("it is not in lowercase", o1.IsNotInLowercase(), TRUE)
	Then("it does not contain a heart", o1.DoesNotContain("♥"), TRUE)
	Then("it has fewer than 5 chars", o1.NumberOfChars() < 5, TRUE)
	Then("that count is not odd", o1.NumberOfCharsQ().IsNotOdd(), TRUE)
	bAll = o1.IsNotAString() and
	       o1.IsNotInLowercase() and
	       o1.DoesNotContain("♥") and
	       o1.NumberOfChars() < 5 and
	       o1.NumberOfCharsQ().IsNotOdd()
	Then("so the compound condition holds", bAll, TRUE)
EndScenario()

Summary()
