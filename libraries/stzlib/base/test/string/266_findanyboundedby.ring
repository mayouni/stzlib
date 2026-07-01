load "../../stzBase.ring"
load "../_narrated.ring"

# The FindAnyBoundedBy family with a distinct << >> pair: positions, spans and
# substrings, plus the IB (include-bounds) variants. Archive block #266.

Scenario("Finding content bounded by << >>")
	Given('"I love <<Ring>> and <<Softanza>>!"')
	o1 = new stzString("I love <<Ring>> and <<Softanza>>!")
	Then("FindAnyBoundedBy gives the content starts",
		ListEq( o1.FindAnyBoundedBy([ "<<", ">>" ]), [ 10, 23 ] ), TRUE)
	Then("FindAnyBoundedByAsSections gives the content spans",
		ListEq( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]), [ [10,13], [23,30] ] ), TRUE)
	Then("AnyBoundedBy gives the substrings",
		ListEq( o1.AnyBoundedBy([ "<<", ">>" ]), [ "Ring", "Softanza" ] ), TRUE)
	Then("FindAnyBoundedByIB gives the bound-inclusive starts",
		ListEq( o1.FindAnyBoundedByIB([ "<<", ">>" ]), [ 8, 21 ] ), TRUE)
	Then("FindAnyBoundedByAsSectionsIB gives the bound-inclusive spans",
		ListEq( o1.FindAnyBoundedByAsSectionsIB([ "<<", ">>" ]), [ [8,15], [21,32] ] ), TRUE)
	Then("AnyBoundedByIB gives the bound-inclusive substrings",
		ListEq( o1.AnyBoundedByIB([ "<<", ">>" ]), [ "<<Ring>>", "<<Softanza>>" ] ), TRUE)
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
