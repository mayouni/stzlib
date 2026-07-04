load "../../stzBase.ring"
load "../_narrated.ring"

# Replace replaces ALL occurrences. Archive block #807.

Scenario("Rixo to Ring, thrice")
	Then("all three replaced",
		Q("Rixo Rixo Rixo").ReplaceQ("xo", "ng").Content(),
		"Ring Ring Ring")
EndScenario()

Summary()
