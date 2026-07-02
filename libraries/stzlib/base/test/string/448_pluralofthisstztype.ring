load "../../stzBase.ring"
load "../_narrated.ring"

# PluralOfThisStzType pluralizes a Softanza class name (lowercased).
# Archive block #448.

Scenario("Pluralizing a stz type name")
	Then("stzChar pluralizes", PLuralOfThisStzType("stzChar"), "stzchars")
EndScenario()

Summary()
