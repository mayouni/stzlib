load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(sub, :From = context): rebind then remove.
# Archive block #865.

Scenario("A heart in the wrong place")
	o1 = new stzString("Ring programming♥ language")
	o1.RemoveXT("♥", :From = "programming♥")
	Then("gone", o1.Content(), "Ring programming language")
EndScenario()

Summary()
