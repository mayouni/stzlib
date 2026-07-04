load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSection in the middle. Archive block #964.

Scenario("The second number becomes a tilde")
	o1 = new stzString("--345--89--")
	o1.ReplaceSection(8, 9, "~")
	Then("collapsed", o1.Content(), "--345--~--")
EndScenario()

Summary()
