load "../../stzBase.ring"
load "../_narrated.ring"

# Quiet equality shines in French, where accents and case come and go.
# Archive block #686.

Scenario("Un enonce, trois graphies")
	o1 = new stzString("énoncé")
	Then("strictly different from enonce", o1.IsEqualTo("enonce"), FALSE)
	Then("but quietly equal", o1.IsQuietEqualTo("enonce"), TRUE)
	Then("... and to its uppercase", o1.IsQuietEqualTo("ÉNONCÉ"), TRUE)
EndScenario()

Summary()
