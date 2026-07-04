load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceLeadingChars / ReplaceTrailingChars, chained.
# Archive block #780.

Scenario("Oh Tunisia")
	o1 = new stzString("aaaaah Tunisia---")
	o1.ReplaceLeadingChars(:With = "O")
	Then("a-run collapsed to O", o1.Content(), "Oh Tunisia---")
	o1.ReplaceTrailingChars(:With = "!")
	Then("dash-run collapsed to !", o1.Content(), "Oh Tunisia!")
EndScenario()

Summary()
