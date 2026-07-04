load "../../stzBase.ring"
load "../_narrated.ring"

# ... and the arguments swap too. Archive block #893.

Scenario("Empty list first")
	o1 = new stzString("/♥♥♥\__/♥\/♥♥\__/♥\__")
	o1.RemoveXT([], "♥")
	Then("same result", o1.Content(), "/\__/\/\__/\__")
EndScenario()

Summary()
