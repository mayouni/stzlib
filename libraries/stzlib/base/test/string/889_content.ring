load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveSubStringBoundedBy -- the method spelling of the same idea.
# Archive block #889.

Scenario("A heart between carets")
	o1 = new stzString("__^^^__^^♥^^__")
	o1.RemoveSubStringBoundedBy("♥", "^^")
	Then("heart gone, carets stay", o1.Content(), "__^^^__^^^^__")
EndScenario()

Summary()
