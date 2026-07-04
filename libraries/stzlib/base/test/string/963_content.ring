load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSection at the head. Archive block #963.

Scenario("The leading number becomes a tilde")
	o1 = new stzString("123--67--")
	o1.ReplaceSection(1, 3, "~")
	Then("collapsed", o1.Content(), "~--67--")
EndScenario()

Summary()
