load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveCharsW / RemoveCharsWQ -- drop the characters where the predicate is
# TRUE (RemoveCharsWQ returns This for chaining). Engine-backed, no eval().
# Migrated from the retired RemoveCharsWXT; its Q(@Char).IsNumberInString()
# sugar (not part of the engine DSL) is rewritten to the char-class predicate
# isDigit(@char), which the engine W-DSL now supports.

Scenario("RemoveCharsW drops the digits of a string")
	Given('the string "(9, 7, 8)"')
	Then("removing isDigit(@char) leaves the punctuation and spaces",
		Q("(9, 7, 8)").RemoveCharsWQ('isDigit(@char)').Content(), "(, , )")
EndScenario()

Summary()
