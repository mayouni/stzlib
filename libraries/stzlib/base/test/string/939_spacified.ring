load "../../stzBase.ring"
load "../_narrated.ring"

# Spacified. Archive block #939.

Scenario("Letters given room")
	Then("spaces between",
		Q("SOFTANZA").Spacified(), "S O F T A N Z A")
EndScenario()

Summary()
