load "../../stzBase.ring"
load "../_narrated.ring"

# ... and the * operator does the same. Archive block #758.

Scenario("a * a list")
	o1 = new stzString("a")
	Then("distributes", o1 * [ "b", "c", "d" ], "abacad")
EndScenario()

Summary()
