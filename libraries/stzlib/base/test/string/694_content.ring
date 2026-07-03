load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceMany with :By. Archive block #694.

Scenario("Replacing two words at once")
	o1 = new stzString("one two three four")
	o1.ReplaceMany([ "two", "four" ], :By = "---")
	Then("both became dashes", o1.Content(), "one --- three ---")
EndScenario()

Summary()
