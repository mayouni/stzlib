load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyChars() inserts a space between every pair of chars, in place.
# Archive block #268.

Scenario("Spacing out the chars of a string")
	Given('"99999999999"')
	o1 = new stzString("99999999999")
	o1.SpacifyChars()
	Then("a space is inserted between every 9", o1.Content(), "9 9 9 9 9 9 9 9 9 9 9")
EndScenario()

Summary()
