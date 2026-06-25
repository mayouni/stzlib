load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveCharsW with a { } predicate block -- drop the characters where the
# predicate is TRUE. Engine-backed, no eval(). Migrated from the retired
# RemoveCharsWXT.

Scenario("RemoveCharsW removes a specific character")
	Given('the string "125.450"')
	Then('removing { @char = "2" } leaves "15.450"',
		Q("125.450").RemoveCharsWQ('{ @char = "2" }').Content(), "15.450")
EndScenario()

Summary()
