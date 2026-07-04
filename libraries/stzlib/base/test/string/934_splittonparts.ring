load "../../stzBase.ring"
load "../_narrated.ring"

# ... and on a 5-wide splitter the remainders show up.
# Archive block #934.

Scenario("A 5-wide splitter")
	o1 = new stzSplitter(5)
	Then("two parts, first bigger",
		ListEq( o1.SplitToNParts(2), [ [ 1, 3 ], [ 4, 5 ] ] ), TRUE)
	Then("one full part of five",
		ListEq( o1.SplitToPartsOfNItemsXT(5), [ [ 1, 5 ] ] ), TRUE)
	Then("four plus the remainder",
		ListEq( o1.SplitToPartsOfNItemsXT(4), [ [ 1, 4 ], [ 5, 5 ] ] ), TRUE)
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
