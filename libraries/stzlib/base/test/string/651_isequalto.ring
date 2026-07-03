load "../../stzBase.ring"
load "../_narrated.ring"

# IsEqualTo and its CS dial. Archive block #651.

Scenario("Equality with a case dial")
	o1 = new stzString("ritekode")
	Then("plain equality", o1.IsEqualTo("ritekode"), TRUE)
	Then("case aside", o1.IsEqualToCS("RiteKode", :CS = FALSE), TRUE)
	Then("case strict", o1.IsEqualToCS("RiteKode", TRUE), FALSE)
EndScenario()

Summary()
