load "../../stzBase.ring"
load "../_narrated.ring"

# OnlyNumbers extracts the digits. Archive block #856.

Scenario("Two numbers squeezed out")
	Then("digits only",
		Q("number 12500 number 18200").OnlyNumbers(), "1250018200")
EndScenario()

Summary()
