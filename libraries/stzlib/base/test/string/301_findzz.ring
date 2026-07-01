load "../../stzBase.ring"
load "../_narrated.ring"

# FindZZ over a list of spaced substrings + RemoveSpacesInSections, with the
# last section running to the end of the string. Archive block #301.

Scenario("Unspacing sections found by FindZZ")
	Given('"Ring langua  ge is like a r  ing at your fing er  tips!"')
	o1 = new stzString("Ring langua  ge is like a r  ing at your fing er  tips!")
	Then("the three spaced substrings are located",
		ListEq( o1.FindZZ([ "langua  ge", "r  ing", "fing er  tips!" ]),
			[ [6,15], [27,32], [42,55] ] ), TRUE)
	o1.RemoveSpacesInSections([ [ 6, 15 ], [ 27, 32 ], [ 42, 55 ] ])
	Then("the sentence reads clean",
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
