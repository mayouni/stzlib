load "../../stzBase.ring"
load "../_narrated.ring"

# - with a string removes ALL its occurrences. Archive block #797.

Scenario("Both Lands go")
	Then("Ringoria remains",
		Q("RingoriaLandLand") - "Land", "Ringoria")
EndScenario()

Summary()
