load "../../stzBase.ring"
load "../_narrated.ring"

# FindCharsW + YieldCharsW -- find the positions of the letters, and yield the
# letters themselves (with a :Where filter). Both engine-backed, no eval().
# Migrated from the retired FindCharsWXT / YieldCharsWXT. FindCharsW (NOT FindW)
# is the char-level finder; FindW on a plain string is the substring finder.

Scenario("FindCharsW + YieldCharsW over the letters of a decorated string")
	Given('the string "..ONE...TWO.."')
	Then("FindCharsW reports the letter positions",
		@@( Q("..ONE...TWO..").FindCharsW('isLetter(@char)') ), @@([ 3, 4, 5, 9, 10, 11 ]))
	Then("YieldCharsW with :Where collects the letters",
		@@( Q("..ONE...TWO..").YieldCharsW('@char', :Where = 'isLetter(@char)') ),
		@@([ "O", "N", "E", "T", "W", "O" ]))
EndScenario()

Summary()
