load "../../stzBase.ring"
load "../_narrated.ring"

# The reverse checks: is this string the plural of some (or a given)
# Softanza type? Archive block #449.

Scenario("Recognizing type plurals")
	Then("stzchars is a plural of a stz type",
		Q("stzchars").IsPluralOfAStzType(), TRUE)
	Then("... specifically of stzchar",
		Q("stzchars").IsPluralOfThisStzType("stzchar"), TRUE)
EndScenario()

Summary()
