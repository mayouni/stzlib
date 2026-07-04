load "../../stzBase.ring"
load "../_narrated.ring"

# stzSplitter: N parts vs parts-of-N-items. Archive block #933.

Scenario("A 2-wide splitter")
	o1 = new stzSplitter(2)
	Then("two parts of one",
		ListEq( o1.SplitToNParts(2), [ [ 1, 1 ], [ 2, 2 ] ] ), TRUE)
	Then("one part of two",
		ListEq( o1.SplitToPartsOfNItemsXT(2), [ [ 1, 2 ] ] ), TRUE)
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
