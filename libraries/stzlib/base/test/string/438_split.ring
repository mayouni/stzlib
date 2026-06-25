load "../../stzBase.ring"
load "../_narrated.ring"

# Split on a literal delimiter, and SplitW splitting at chars matching a
# predicate (the split chars are dropped). SplitW is engine-backed, no eval().
# Migrated from the retired SplitAtCharsWXT.

Scenario("Split a hyphenated word into its parts")
	Given('the string "ONE-TWO-THREE"')
	Then("Split on the literal hyphen", @@( Q("ONE-TWO-THREE").Split("-") ), @@([ "ONE", "TWO", "THREE" ]))
	Then("SplitW at every non-letter is equivalent",
		@@( Q("ONE-TWO-THREE").SplitW('{ Q(@char).IsNotLetter() }') ), @@([ "ONE", "TWO", "THREE" ]))
EndScenario()

Summary()
