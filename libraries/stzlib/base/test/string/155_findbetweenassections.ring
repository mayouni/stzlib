load "../../stzBase.ring"
load "../_narrated.ring"

# Finding a substring bounded by markers, as sections / positions. Archive #155.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): FindBoundedByAsSections([sub, bound])
# returns garbled reversed spans ([ [8,7], [16,15] ]), and the FindXT/
# FindAsSectionsXT :Between named-param forms return [] (not parsed). The
# FindBetweenAsSections form and the :BoundedBy named-param forms work and ARE
# asserted.

Scenario("Finding ABC bounded by | markers")
	Given('"---|ABC|---|ABC|---"')
	o1 = new stzString("---|ABC|---|ABC|---")
	Then("FindBetweenAsSections('ABC','|','|') gives both spans",
		ListEq( o1.FindBetweenAsSections("ABC", "|", "|"), [ [ 5, 7 ], [ 13, 15 ] ] ), TRUE)
	Then("FindXT(..., :BoundedBy='|') gives the start positions",
		ListEq( o1.FindXT("ABC", :BoundedBy = "|"), [ 5, 13 ] ), TRUE)
	Then("FindAsSectionsXT(..., :BoundedBy='|') gives both spans",
		ListEq( o1.FindAsSectionsXT("ABC", :BoundedBy = "|"), [ [ 5, 7 ], [ 13, 15 ] ] ), TRUE)
	Then("FindXT(..., :Between=['|','|']) gives the start positions",
		ListEq( o1.FindXT("ABC", :Between = [ "|", "|" ]), [ 5, 13 ] ), TRUE)
	Then("FindAsSectionsXT(..., :Between=['|','|']) gives both spans",
		ListEq( o1.FindAsSectionsXT("ABC", :Between = [ "|", "|" ]), [ [ 5, 7 ], [ 13, 15 ] ] ), TRUE)
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
