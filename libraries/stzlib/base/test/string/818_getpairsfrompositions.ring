load "../../stzBase.ring"
load "../_narrated.ring"

# stzSplitter: positions to pairs, and split-before sections.
# Archive block #818.

Scenario("A 10-wide splitter")
	o1 = new stzSplitter(10)
	Then("pairs chain the positions",
		ListEq( o1.GetPairsFromPositions([ 1, 3, 8 ]),
			[ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ] ] ), TRUE)
	Then("split-before sections",
		ListEq( o1.SplitBeforePositions([ 1, 3, 8, 10 ]),
			[ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 10 ] ] ), TRUE)
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
