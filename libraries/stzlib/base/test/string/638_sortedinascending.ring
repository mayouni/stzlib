load "../../stzBase.ring"
load "../_narrated.ring"

# Sorting digits. Archive block #638.

Scenario("Digits sorted both ways")
	o1 = new stzString("73964532041")
	Then("ascending", o1.SortedInAscending(), "01233445679")
	Then("descending", o1.SortedInDescending(), "97654433210")
EndScenario()

Summary()
