load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveLast, the direct spelling. Archive block #585.

Scenario("Removing the last A")
	o1 = new stzString("**A1****A2***A3")
	o1.RemoveLast("A")
	Then("the third A is gone", o1.Content(), "**A1****A2***3")
EndScenario()

Summary()
