load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceCharAt with named params. (The archive noted the Qt-era
# QStringObject() was removed; the engine-based ReplaceCharAt is the
# replacement.) Archive block #251.

Scenario("Fixing the fourth char, named-param form")
	o1 = new stzString("ABC*EF")
	o1.ReplaceCharAt(:Position = 4, :By = "D")
	Then("the star became D", o1.Content(), "ABCDEF")
EndScenario()

Summary()
