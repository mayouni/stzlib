load "../../stzBase.ring"
load "../_narrated.ring"

# A "marquer" is a Softanza placeholder token like "#01" (a "#" followed by
# digits). IsMarquer tests one; BothAreMarquers tests a pair. Archive block #50.

Scenario("Recognising marquer placeholder tokens")
	Then("'#01' is a marquer", IsMarquer("#01"), TRUE)
	Then("'#02' is a marquer", IsMarquer("#02"), TRUE)
	Then("'#01' and '#02' are both marquers", BothAreMarquers("#01", "#02"), TRUE)
EndScenario()

Summary()
