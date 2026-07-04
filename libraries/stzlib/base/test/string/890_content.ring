load "../../stzBase.ring"
load "../_narrated.ring"

# :BoundedBy with a single string bounds both sides.
# Archive block #890.

Scenario("Same, via RemoveXT")
	o1 = new stzString("__^^^__^^♥^^__")
	o1.RemoveXT("♥", :BoundedBy = "^^")
	Then("heart gone, carets stay", o1.Content(), "__^^^__^^^^__")
EndScenario()

Summary()
