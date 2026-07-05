load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceCharAt with named params. Archive block #252.

Scenario("Fixing the fourth char")
	o1 = new stzString("ABC*EF")
	o1.ReplaceCharAt( :Position = 4, :By = "D")
	Then("the star became D", o1.Content(), "ABCDEF")
EndScenario()

Summary()
