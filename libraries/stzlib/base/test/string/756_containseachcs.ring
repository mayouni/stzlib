load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsEachCS and ContainsBoth. Archive block #756.

Scenario("Both separators of a locale string")
	o1 = new stzString("ar_TN-tun")
	Then("contains each of _ and -",
		o1.ContainsEachCS([ "_", "-" ], TRUE), TRUE)
	Then("contains both",
		o1.ContainsBoth("_", "-"), TRUE)
EndScenario()

Summary()
