load "../../stzBase.ring"
load "../_narrated.ring"

# IsLocaleAbbreviation validates the ISO lang[_Script][_COUNTRY] shape.
# Archive block #649.

Scenario("A full locale abbreviation")
	o1 = new stzString("ar_Arab_TN")
	Then("well formed", o1.IsLocaleAbbreviation(), TRUE)
EndScenario()

Summary()
