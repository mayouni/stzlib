load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisLeadingChar and its CS dial. Archive block #783.

Scenario("Removing an o-run named in uppercase")
	o1 = new stzString("oooTunisia")
	o1.RemoveThisLeadingChar("O")
	Then("case-sensitive: no match, no change", o1.Content(), "oooTunisia")
	o1.RemoveThisLeadingCharCS("O", :CS = FALSE)
	Then("case-blind: the run goes", o1.Content(), "Tunisia")
EndScenario()

Summary()
