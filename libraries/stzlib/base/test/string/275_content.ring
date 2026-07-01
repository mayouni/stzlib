load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyXT(sep, step, :Backward) groups from the right. Archive block #275.

Scenario("Grouping from the right with a space")
	Given('"99999999999"')
	o1 = new stzString("99999999999")
	o1.SpacifyXT( " ", 3, :Backward )
	Then("spaces group every 3 from the right", o1.Content(), "99 999 999 999")
EndScenario()

Summary()
