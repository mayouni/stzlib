load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveW / RemoveWQ -- drop the characters where the predicate is TRUE
# (RemoveWQ returns This for chaining). Engine-backed, no eval(). Migrated from
# the retired RemoveWXT; the Q(@char).isLowercase() sugar lowers to the engine
# predicate isLowercase(@char).

Scenario("RemoveW drops the lowercase characters")
	Given('the string "SOooooFTAaaannnNZA"')
	Then("removing isLowercase(@char) leaves the uppercase letters",
		Q("SOooooFTAaaannnNZA").RemoveWQ('isLowercase(@char)').Content(), "SOFTANZA")
EndScenario()

Summary()
