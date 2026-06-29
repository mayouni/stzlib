load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringsBoundedBy([open, close]) -- the substrings enclosed by each bound
# pair. Archive block #167.
#
# Its companion BoundedByZZ pairs each substring with its [from,to] span.

Scenario("The substrings enclosed by << >>")
	Given('"...<<--hi!-->>...<<-->>...<<hi!>>..."')
	o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
	Then("the three enclosed substrings",
		ListEq( o1.SubStringsBoundedBy([ "<<", ">>" ]), [ "--hi!--", "--", "hi!" ] ), TRUE)
	Then("BoundedByZZ pairs each substring with its span",
		ListEq( o1.BoundedByZZ([ "<<", ">>" ]),
			[ [ "--hi!--", [6,12] ], [ "--", [20,21] ], [ "hi!", [29,31] ] ] ), TRUE)
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
