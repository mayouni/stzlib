load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveNLeftChars / RemoveNRightChars. Archive block #769.

Scenario("Shaving three chars off each end")
	o1 = new stzString("eeebxeTuniseee")
	o1.RemoveNLeftChars(3)
	o1.RemoveNRightChars(3)
	Then("the middle remains", o1.Content(), "bxeTunis")
EndScenario()

Summary()
