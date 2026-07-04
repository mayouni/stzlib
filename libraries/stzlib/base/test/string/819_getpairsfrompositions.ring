load "../../stzBase.ring"
load "../_narrated.ring"

# The same on a 12-wide splitter. Archive block #819.

Scenario("A 12-wide splitter")
	o1 = new stzSplitter(12)
	Then("pairs chain to the width",
		ListEq( o1.GetPairsFromPositions([ 1, 3, 8, 10 ]),
			[ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ], [ 10, 12 ] ] ), TRUE)
	Then("split-before sections",
		ListEq( o1.SplitBeforePositions([ 1, 3, 8, 10 ]),
			[ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 12 ] ] ), TRUE)
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
