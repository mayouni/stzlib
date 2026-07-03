load "../../stzBase.ring"
load "../_narrated.ring"

# FirstChar / LastChar again, on a dashed string. Archive block #679.

Scenario("The ends of ---Ring")
	o1 = new stzString("---Ring")
	Then("first", o1.FirstChar(), "-")
	Then("last", o1.LastChar(), "g")
EndScenario()

Summary()
