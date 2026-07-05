load "../../stzBase.ring"
load "../_narrated.ring"

# Positional spec form (no named params), :LastChars boundary.
# Archive block #282.

Scenario("Positional multi-phase")
	o1 = new stzString("12345269775114")
	o1.SpacifyXT( [ " ", ".", :LastChars = 6 ], [ 3, 2 ], :Backward )
	Then("head-3, tail-2", o1.Content(), "12 345 269.77 51 14")
EndScenario()

Summary()
