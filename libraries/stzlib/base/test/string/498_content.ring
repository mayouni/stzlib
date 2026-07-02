load "../../stzBase.ring"
load "../_narrated.ring"

# The narrative @()-chain: name a substring, remove it, and then
# uppercase the host string. Archive block #498.

Scenario("Naming, removing, transforming")
	o1 = new stzString("__Ri__ng__")
	o1.@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheString()
	Then("the underscores are gone, the rest shouted", o1.Content(), "RING")
EndScenario()

Summary()
