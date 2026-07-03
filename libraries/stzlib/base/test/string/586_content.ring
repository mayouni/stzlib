load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFirst, its mirror. Archive block #586.

Scenario("Removing the first A")
	o1 = new stzString("**A1****A2***A3")
	o1.RemoveFirst("A")
	Then("the first A is gone", o1.Content(), "**1****A2***A3")
EndScenario()

Summary()
