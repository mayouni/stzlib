load "../../stzBase.ring"
load "../_narrated.ring"

# stzSplitter(n).SplitAtSections(sections): split the 1..n range AT the given
# sections, returning the COMPLEMENT spans between/around them (an empty list
# when the sections cover the whole range). Archive block #296.

Scenario("Splitting a 1..12 range at sections")
	Given('a stzSplitter(12)')
	o1 = new stzSplitter(12)
	Then("splitting at [3,5]+[8,9] leaves the three gaps",
		ListEq( o1.SplitAtSections([ [3, 5], [8, 9] ]), [ [1,2], [6,7], [10,12] ] ), TRUE)
	Then("a full-cover section leaves nothing",
		ListEq( o1.SplitAtSections([ [1, 12] ]), [ ] ), TRUE)
	Then("a section starting at 1 drops the leading gap",
		ListEq( o1.SplitAtSections([ [1, 5], [8, 9] ]), [ [6,7], [10,12] ] ), TRUE)
	Then("a section ending at 12 drops the trailing gap",
		ListEq( o1.SplitAtSections([ [3, 5], [8, 9], [12, 12] ]), [ [1,2], [6,7], [10,11] ] ), TRUE)
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
