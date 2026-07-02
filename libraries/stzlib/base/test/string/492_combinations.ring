load "../../stzBase.ring"
load "../_narrated.ring"

# Combinations(list, k): the k-subsets in order; CombinationsXT: the full
# cartesian k-tuples (repetition + order). Archive block #492.

Scenario("Pairs from ABC")
	Then("the 3 unordered pairs",
		ListEq( Combinations([ "A", "B", "C" ], 2),
			[ [ "A", "B" ], [ "A", "C" ], [ "B", "C" ] ] ), TRUE)
	Then("the 9 ordered pairs with repetition",
		ListEq( CombinationsXT([ "A", "B", "C" ], 2),
			[ [ "A", "A" ], [ "A", "B" ], [ "A", "C" ],
			  [ "B", "A" ], [ "B", "B" ], [ "B", "C" ],
			  [ "C", "A" ], [ "C", "B" ], [ "C", "C" ] ] ), TRUE)
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
