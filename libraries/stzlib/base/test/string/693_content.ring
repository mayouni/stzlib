load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAll. Archive block #693.

Scenario("Replacing a word")
	o1 = new stzString("one two three four")
	o1.ReplaceAll("two", "---")
	Then("two became dashes", o1.Content(), "one --- three four")
EndScenario()

Summary()
