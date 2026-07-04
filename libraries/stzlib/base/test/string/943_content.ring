load "../../stzBase.ring"
load "../_narrated.ring"

# The string twin of 942. Archive block #943.

Scenario("Spaces before the even positions")
	o1 = new stzString("SOFTANZA")
	o1.InsertBeforePositions([ 2, 4, 6, 8 ], " ")
	Then("split look", o1.Content(), "S OF TA NZ A")
EndScenario()

Summary()
