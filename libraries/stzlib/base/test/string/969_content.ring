load "../../stzBase.ring"
load "../_narrated.ring"

# ... including at the head. Archive block #969.

Scenario("Head and middle shrunk")
	o1 = new stzString("123---78--")
	o1.ReplaceSectionsByMany([ [1, 3], [7, 8] ], [ "*", "~" ])
	Then("shrunk", o1.Content(), "*---~--")
EndScenario()

Summary()
