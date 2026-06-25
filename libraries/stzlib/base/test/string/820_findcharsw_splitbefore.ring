load "../../stzBase.ring"
load "../_narrated.ring"

# FindCharsW feeding SplitBeforePositions -- find the uppercase letters, then
# split the string before each. Engine-backed, no eval(). Migrated from the
# retired FindCharsWXT.

Scenario("Split a CamelCase string before each uppercase letter")
	Given('the string "NoWomanNoCry"')
	Then("FindCharsW reports the uppercase positions",
		@@( Q("NoWomanNoCry").FindCharsW('isUppercase(@char)') ), @@([ 1, 3, 8, 10 ]))
	Then("SplitBeforePositions on them yields the words",
		@@( Q("NoWomanNoCry").SplitBeforePositions( Q("NoWomanNoCry").FindCharsW('isUppercase(@char)') ) ),
		@@([ "No", "Woman", "No", "Cry" ]))
EndScenario()

Summary()
