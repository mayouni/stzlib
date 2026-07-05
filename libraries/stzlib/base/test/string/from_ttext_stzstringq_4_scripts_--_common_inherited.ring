load "../../stzBase.ring"
load "../_narrated.ring"

# A string of only spaces, a digit and a dhammah has no real script --
# its dominant reading is Inherited. Extracted from stzTtexttest.ring,
# block #10.

Scenario("Nothing but neutrals")
	Then("Inherited",
		StzStringQ(" 4  " + ArabicDhammah() + "  ").Script(), :Inherited)
EndScenario()

Summary()
