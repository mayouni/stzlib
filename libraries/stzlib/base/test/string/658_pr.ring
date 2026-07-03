load "../../stzBase.ring"
load "../_narrated.ring"

# The river again: Ring's byte-based upper() vs the Softanza check.
# Archive block #658.

Scenario("Casing checks on der fluss")
	Then("Ring's upper leaves the eszett (byte-based)",
		upper("der fluß"), "DER FLUß")
	Then("StringIsLowercase sees it lowercase",
		StringIsLowercase("der fluß"), TRUE)
EndScenario()

Summary()
