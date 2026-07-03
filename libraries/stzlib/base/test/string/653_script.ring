load "../../stzBase.ring"
load "../_narrated.ring"

# Greek casing end to end: script detection, StringCase, the case
# transforms and CI equality. Archive block #653.

Scenario("Sisyphus in Greek")
	Then("the script", TQ("Σίσυφος").Script(), :Greek)
	Then("capitalcase", Q("Σίσυφος").StringCase(), :Capitalcase)
	Then("uppercase", Q("ΣΊΣΥΦΟΣ").StringCase(), :Uppercase)
	Then("lowercased", Q("ΣΊΣΥΦΟΣ").Lowercased(), "σίσυφοσ")
	Then("uppercased", Q("σίσυφοσ").Uppercased(), "ΣΊΣΥΦΟΣ")
	Then("capitalcased", Q("σίσυφοσ").Capitalcased(), "Σίσυφοσ")
	Then("equal, case aside",
		Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", :CS = FALSE), TRUE)
	Then("not equal, case strict",
		Q("σίσυφοσ").IsEqualToCS("ΣΊΣΥΦΟΣ", TRUE), FALSE)
EndScenario()

Summary()
