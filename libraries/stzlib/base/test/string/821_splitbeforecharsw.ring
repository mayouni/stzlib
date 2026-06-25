load "../../stzBase.ring"
load "../_narrated.ring"

# SplitBeforeCharsW -- split a string before each char matching a predicate
# (the matched char starts the next piece). Engine-backed via FindCharsW, no
# eval(). Migrated from the retired SplitBeforeCharsWXT.

Scenario("Split a CamelCase string before each uppercase letter")
	Given('the string "NoWomanNoCry"')
	Then("SplitBeforeCharsW at the uppercase letters yields the words",
		@@( Q("NoWomanNoCry").SplitBeforeCharsW('Q(@char).IsUppercase()') ),
		@@([ "No", "Woman", "No", "Cry" ]))
EndScenario()

Summary()
