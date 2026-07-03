load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveNthChar. Archive block #666.

Scenario("Dropping the last digit")
	o1 = new stzString("125.450")
	o1.RemoveNthChar(7)
	Then("the 7th char is gone", o1.Content(), "125.45")
EndScenario()

Summary()
