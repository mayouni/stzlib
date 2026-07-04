load "../../stzBase.ring"
load "../_narrated.ring"

# A plain string variable. Archive block #846.

Scenario("salem is salem")
	cStr = "salem"
	Then("it prints as itself", cStr, "salem")
EndScenario()

Summary()
