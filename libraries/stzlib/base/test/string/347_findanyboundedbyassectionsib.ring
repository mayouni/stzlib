load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedByAsSectionsIB spans the whole bounded regions including
# the bounds; with same "♥♥♥" bounds the enclosed content sections come
# back (overlapping rule). Archive block #347.

Scenario("IB sections and same-bounds content sections")
	Given('"12♥♥♥67♥♥♥12♥♥♥67"')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")
	Then("the 12..67 regions, bounds included",
		ListEq( o1.FindAnyBoundedByAsSectionsIB([ "12", "67" ]),
			[ [1, 7], [11, 17] ] ), TRUE)
	Then("the gaps between the hearts",
		ListEq( o1.FindAnyBoundedByAsSections([ "♥♥♥", "♥♥♥" ]),
			[ [6, 7], [11, 12] ] ), TRUE)
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
