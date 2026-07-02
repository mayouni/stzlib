load "../../stzBase.ring"
load "../_narrated.ring"

# StzSplitterQ(n).SplitAround(position): the two complement spans around
# one position. Archive block #362.

Scenario("Splitting a range around a position")
	Then("around position 8 of 1..10",
		ListEq( StzSplitterQ(10).splitAround(8), [ [1, 7], [9, 10] ] ), TRUE)
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
