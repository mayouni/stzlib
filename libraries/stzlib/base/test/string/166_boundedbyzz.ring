load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedByZZ pairs each bounded substring with its [from,to] span; BoundedByUZZ
# does the same but groups the UNIQUE substrings with all their spans.
# Archive block #166.

Scenario("Bounded substrings paired with their spans")
	Given('"<<hi!>>..<<--♥♥♥--♥♥♥-->>..<<hi!>>"')
	o1 = new stzString("<<hi!>>..<<--♥♥♥--♥♥♥-->>..<<hi!>>")
	Then("ZZ pairs each substring with its span",
		ListEq( o1.BoundedByZZ([ "<<", ">>" ]),
			[ [ "hi!", [3,5] ], [ "--♥♥♥--♥♥♥--", [12,23] ], [ "hi!", [30,32] ] ] ), TRUE)
	Then("UZZ groups the unique substrings with their spans",
		ListEq( o1.BoundedByUZZ([ "<<", ">>" ]),
			[ [ "hi!", [ [3,5],[30,32] ] ], [ "--♥♥♥--♥♥♥--", [ [12,23] ] ] ] ), TRUE)
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
