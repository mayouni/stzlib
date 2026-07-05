load "../../stzBase.ring"
load "../_narrated.ring"

# The - operator is NON-mutating. Archive block #996.

Scenario("Minus leaves the object alone")
	o1 = new stzString("A**BC***DE***")
	Then("stars removed in the result", o1 - "*", "ABCDE")
	Then("... but the object keeps them", o1.Content(), "A**BC***DE***")
EndScenario()

Summary()
