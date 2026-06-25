load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceCharsW with a Q(@char).isLowercase() predicate (lowers to the engine
# isLowercase). Engine-backed, no eval(). Migrated from the retired
# ReplaceCharsWXT.

Scenario("ReplaceCharsW replaces the lowercase letters")
	Given('the string "1a2b3c"')
	Then('replacing the lowercase letters with "*"',
		Q("1a2b3c").ReplaceCharsWQ(:Where = '{ Q(@char).isLowercase() }', :With = "*").Content(),
		"1*2*3*")
EndScenario()

Summary()
