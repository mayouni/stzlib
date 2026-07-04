load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(sub, :AtPositions = [...]). Archive block #896.

Scenario("The outer hearts")
	o1 = new stzString("♥^^♥^^♥")
	o1.RemoveXT( "♥", :AtPositions = [1, 7])
	Then("the middle one stays", o1.Content(), "^^♥^^")
EndScenario()

Summary()
