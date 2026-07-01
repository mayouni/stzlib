load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfSections.MergeOverlapping() merges inclusive/overlapping (and
# adjacent) sections into maximal disjoint spans -- the primitive behind
# stzString.RemoveSections() on overlapping input. Archive block #289.

Scenario("Merging overlapping sections")
	Given('[ [8,11], [9,12], [10,13], [11,14], [12,15], [26,29] ]')
	o1 = new stzListOfSections([ [ 8, 11 ], [ 9, 12 ], [ 10, 13 ], [ 11, 14 ], [ 12, 15 ], [ 26, 29 ] ])
	o1.MergeOverlapping()
	Then("the overlapping runs collapse to two spans",
		ListEq( o1.Content(), [ [ 8, 15 ], [ 26, 29 ] ] ), TRUE)
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
