load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(sub, :AtPosition = n). Archive block #895.

Scenario("A heart at position 3")
	o1 = new stzString("^^♥^^")
	o1.RemoveXT( "♥", :AtPosition = 3)
	Then("carets only", o1.Content(), "^^^^")
EndScenario()

Summary()
