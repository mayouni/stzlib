load "../../stzBase.ring"
load "../_narrated.ring"

# @FunctionNegativeForm (IsNotLetter = NOT IsLetter) and
# @FunctionPassiveForm (Removed = a copy with the removal applied,
# original untouched). Archive block #437.

Scenario("Negative form")
	Then("* is not a letter, computationally", NOT Q("*").IsLetter(), TRUE)
	Then("... and linguistically", Q("*").IsNotLetter(), TRUE)
EndScenario()

Scenario("Active vs passive removal")
	o1 = new stzString("RIxxNxG")
	o1.Remove("x")
	Then("the active form mutates", o1.Content(), "RING")
	o2 = new stzString("RIxxNxG")
	Then("the passive form returns a copy", o2.Removed("x"), "RING")
	Then("... leaving the original as is", o2.Content(), "RIxxNxG")
EndScenario()

Summary()
