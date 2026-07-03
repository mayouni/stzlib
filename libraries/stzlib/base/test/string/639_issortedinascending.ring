load "../../stzBase.ring"
load "../_narrated.ring"

# The sortedness checks. Archive block #639.

Scenario("An ascending digit string")
	Then("is ascending", Q("01233445679").IsSortedInAscending(), TRUE)
	Then("not descending", Q("01233445679").IsSortedInDescending(), FALSE)
EndScenario()

Summary()
