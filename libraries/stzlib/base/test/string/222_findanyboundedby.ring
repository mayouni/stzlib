load "../../stzBase.ring"
load "../_narrated.ring"

# The FindAnyBoundedBy / AnyBoundedBy family with a distinct [open,close] pair.
# Archive block #222.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): FindAnyBoundedBy returns the
# SUBSTRINGS (not the positions [6,17]), and FindAnyBoundedByIB returns the
# [from,to] SECTIONS (not the positions [4,15]). The ...AsSections and
# AnyBoundedBy[IB] forms are correct and asserted.

Scenario("Finding content bounded by << >>")
	Given('"...<<ring>>...<<softanza>>..."')
	o1 = new stzString("...<<ring>>...<<softanza>>...")
	Then("FindAnyBoundedByAsSections gives the content spans",
		ListEq( o1.FindAnyBoundedByAsSections(["<<",">>"]), [ [6, 9], [17, 24] ] ), TRUE)
	Then("AnyBoundedBy gives the enclosed substrings",
		ListEq( o1.AnyBoundedBy(["<<",">>"]), ["ring", "softanza"] ), TRUE)
	Then("FindAnyBoundedByAsSectionsIB gives the bound-inclusive spans",
		ListEq( o1.FindAnyBoundedByAsSectionsIB(["<<",">>"]), [ [4, 11], [15, 26] ] ), TRUE)
	Then("AnyBoundedByIB gives the bound-inclusive substrings",
		ListEq( o1.AnyBoundedByIB(["<<",">>"]), ["<<ring>>", "<<softanza>>"] ), TRUE)
	# Wrong-type forms:
	? "  NOTE  FindAnyBoundedBy -> " + @@(o1.FindAnyBoundedBy(["<<",">>"])) + "  (want positions [6,17] -- deferred)"
	? "  NOTE  FindAnyBoundedByIB -> " + @@(o1.FindAnyBoundedByIB(["<<",">>"])) + "  (want positions [4,15] -- deferred)"
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
