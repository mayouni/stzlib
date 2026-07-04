load "../../stzBase.ring"
load "../_narrated.ring"

# StringIsLowercase. Archive block #720.

Scenario("A capital in the middle")
	Then("sAlut is not lowercase", StringIsLowercase("sAlut"), FALSE)
EndScenario()

Summary()
