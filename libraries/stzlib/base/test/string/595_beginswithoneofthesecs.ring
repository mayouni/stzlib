load "../../stzBase.ring"
load "../_narrated.ring"

# BeginsWithOneOfTheseCS with an inline :Or spelling. Archive block #595.

Scenario("A W-expression prefix")
	o1 = new stzString("@str = Q(@str).Uppercased()")
	Then("it begins with one of the spellings",
		o1.BeginsWithOneOfTheseCS([ "@str =", :Or = "@str=" ], TRUE), TRUE)
EndScenario()

Summary()
