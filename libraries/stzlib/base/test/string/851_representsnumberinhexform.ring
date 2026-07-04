load "../../stzBase.ring"
load "../_narrated.ring"

# The bare x prefix also reads as hex. Archive block #851.

Scenario("x without the 0")
	Then("hex form",
		Q("x4E992").RepresentsNumberInHexForm(), TRUE)
EndScenario()

Summary()
