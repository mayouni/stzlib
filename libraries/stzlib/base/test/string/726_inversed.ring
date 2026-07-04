load "../../stzBase.ring"
load "../_narrated.ring"

# Inversed reverses the order of the chars. Archive block #726.

Scenario("Five names backwards")
	Then("LIFE", Q("LIFE").Inversed(), "EFIL")
	Then("GAYA", Q("GAYA").Inversed(), "AYAG")
	Then("TIBA", Q("TIBA").Inversed(), "ABIT")
	Then("HANEEN", Q("HANEEN").Inversed(), "NEENAH")
	Then("even with digits and symbols",
		Q("MILLAVOY (Y908$)").Inversed(), ")$809Y( YOVALLIM")
EndScenario()

Summary()
