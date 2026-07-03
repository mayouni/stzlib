load "../../stzBase.ring"
load "../_narrated.ring"

# Strict equality, the CS dial, and IsUppercaseOf. Archive block #684.

Scenario("Comparing across cases")
	o1 = new stzString("SOFTANZA IS AWSOME!")
	Then("strictly different", o1.IsEqualTo("softanza is awsome!"), FALSE)
	Then("equal case-aside",
		o1.IsEqualToCS("softanza is awsome!", :CS = FALSE), TRUE)
	Then("it IS the uppercase of it",
		o1.IsUppercaseOf("softanza is awsome!"), TRUE)
EndScenario()

Summary()
