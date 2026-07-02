load "../../stzBase.ring"
load "../_narrated.ring"

# MergeContiguous on a stzListOfSections: touching spans fuse, separated
# ones stay -- the sections here come from FindZZ("12") on a run-together
# string. Archive block #420.

Scenario("Merging contiguous sections")
	Given('"...12..1212..121212..12."')
	o1 = new stzString("...12..1212..121212..12.")
	aSections = o1.FindZZ("12")
	Then("the raw sections",
		ListEq( aSections,
			[ [4, 5], [8, 9], [10, 11], [14, 15], [16, 17], [18, 19], [22, 23] ] ), TRUE)
	o2 = new stzListOfSections(aSections)
	o2.MergeContiguous()
	Then("the touching runs fuse",
		ListEq( o2.Content(), [ [4, 5], [8, 11], [14, 19], [22, 23] ] ), TRUE)
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
