load "../../stzBase.ring"
load "../_narrated.ring"

# FindSubStringsAsSectionsWF -- the [start,end] sections of the substrings
# matching a Ring anonymous-function predicate (no eval()). Migrated from the
# retired FindSubStringsAsSectionsWXT.

Scenario("FindSubStringsAsSectionsWF returns matching sections")
	Given('the string "..(h)^^(h)..^(h)(h)^.." with heart chars')
	Then("the length-4 sections containing a heart pair",
		@@( Q("..♥^^♥..^♥♥^..").FindSubStringsAsSectionsWF( func s { return Q(s).NumberOfChars() = 4 and Q(s).ContainsCS("♥♥", 1) } ) ),
		@@([ [ 8, 11 ], [ 9, 12 ], [ 10, 13 ] ]))
EndScenario()

Summary()
