load "../../stzBase.ring"
load "../_narrated.ring"

# The CS dial and the sections form of the bounded-content find: only
# occurrences that ARE a whole bounded content (so <<noword>>'s inner
# "word" never matches). Archive block #559.

Scenario("Bounded word, CI and sectional")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	Then("case-insensitively, the two real <<word>>s",
		ListEq( o1.FindSubStringBoundedByCS("word", [ "<<", ">>" ], :CaseSensitive = FALSE),
			[ 11, 43 ] ), TRUE)
	Then("their sections",
		ListEq( o1.FindSubStringBoundedByAsSections("word", [ "<<", ">>" ]),
			[ [11, 14], [43, 46] ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
