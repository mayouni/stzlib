load "../../stzBase.ring"
load "../_narrated.ring"

# FirstChar / LastChar. Archive block #678.

Scenario("The ends of ABC")
	o1 = new stzString("ABC")
	Then("first", o1.FirstChar(), "A")
	Then("last", o1.LastChar(), "C")
EndScenario()

Summary()
