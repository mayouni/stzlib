load "../../stzBase.ring"
load "../_narrated.ring"

# The global ListContainsCS with the case-insensitivity dial.
# Archive block #454.

Scenario("Case-insensitive containment")
	Then("a matches A when case is off",
		ListContainsCS([ "A", "A", "A", "B", "B", "C" ], "a", FALSE), TRUE)
EndScenario()

Summary()
