load "../../stzBase.ring"
load "../_narrated.ring"

# Sections(list) returns the substrings at the given spans;
# RemoveSpacesInSections then unspaces exactly those spans.
# Archive block #300.

Scenario("Reading sections then unspacing them")
	Given('"R  in  g language is like a r  ing at your fingertips!"')
	o1 = new stzString("R  in  g language is like a r  ing at your fingertips!")
	Then("the two sections read back",
		ListEq( o1.Sections([ [ 1, 8 ], [ 29, 34 ] ]), [ "R  in  g", "r  ing" ] ), TRUE)
	o1.RemoveSpacesInSections([ [ 1, 8 ], [ 29, 34 ] ])
	Then("their spaces are removed in place",
		o1.Content(), "Ring language is like a ring at your fingertips!")
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
