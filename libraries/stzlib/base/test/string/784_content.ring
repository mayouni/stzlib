load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceLeadingChar and its CS dial -- collapse the run when it is
# made of the named char. Archive block #784.

Scenario("Replacing an o-run named in uppercase")
	o1 = new stzString("oooTunisia")
	o1.ReplaceLeadingChar("O", :With = "")
	Then("case-sensitive: no match", o1.Content(), "oooTunisia")
	o1.ReplaceLeadingCharCS("O", :With = "", :CS = FALSE)
	Then("case-blind: collapsed away", o1.Content(), "Tunisia")
EndScenario()

Summary()
