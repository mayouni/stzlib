load "../../stzBase.ring"
load "../_narrated.ring"

# Reversed(). Archive block #637.

Scenario("Countdown reversed")
	Then("digits flip", Q("9876543210").Reversed(), "0123456789")
EndScenario()

Summary()
