load "../../stzBase.ring"
load "../_narrated.ring"

# MarquersSortedZ/ZZ zip the ASCENDING-sorted marquers onto the
# text-order positions / sections. Archive block #627.

Scenario("Ascending zips")
	o1 = new stzString("My name is #1, my age is #3, and my job is #2. Again: my name is #1!")
	Then("the Z zip",
		ListEq( o1.MarquersSortedZ(),
			[ [ "#1", 12 ], [ "#1", 26 ], [ "#2", 44 ], [ "#3", 66 ] ] ), TRUE)
	Then("the ZZ zip",
		ListEq( o1.MarquersSortedZZ(),
			[ [ "#1", [12, 13] ], [ "#1", [26, 27] ],
			  [ "#2", [44, 45] ], [ "#3", [66, 67] ] ] ), TRUE)
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
