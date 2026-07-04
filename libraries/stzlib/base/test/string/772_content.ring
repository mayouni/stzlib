load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceLeadingChars / ReplaceTrailingChars replace the WHOLE run
# with the given string (once). Archive block #772.

Scenario("Collapsing each run to one star")
	o1 = new stzString("___VAR---")
	o1.ReplaceLeadingChars(:With = "*")
	Then("leading run collapsed", o1.Content(), "*VAR---")
	o2 = new stzString("___VAR---")
	o2.ReplaceTrailingChars(:With = "*")
	Then("trailing run collapsed", o2.Content(), "___VAR*")
	o3 = new stzString("___VAR---")
	o3.ReplaceLeadingAndTrailingChars(:With = "*")
	Then("both at once", o3.Content(), "*VAR*")
EndScenario()

Summary()
