load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSection, one char wide. Archive block #253.

Scenario("Replacing a one-char section")
	o1 = new stzString("ABC*EF")
	o1.ReplaceSection( 4, 4, "D")
	Then("the star became D", o1.Content(), "ABCDEF")
EndScenario()

Summary()
