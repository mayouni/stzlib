load "../../stzBase.ring"
load "../_narrated.ring"

# FindAllOccurrencesCS / FindAsSectionsCS with named params, and
# FindOccurrences picking ordinal occurrences. Archive block #598.

Scenario("Rings by ordinal")
	o1 = new stzString("ring is not the ring you ware but the ring you program with")
	Then("all, case aside",
		ListEq( o1.FindAllOccurrencesCS(:Of = "ring", :CS = FALSE), [ 1, 17, 39 ] ), TRUE)
	Then("their sections",
		ListEq( o1.FindAsSectionsCS(:Of = "ring", :CS = FALSE),
			[ [1, 4], [17, 20], [39, 42] ] ), TRUE)
	Then("the 1st and 3rd",
		ListEq( o1.FindOccurrences([1, 3], :Of = "ring"), [1, 39] ), TRUE)
	Then("of a missing substring, nothing",
		ListEq( o1.FindOccurrences([1, 3], :Of = "foo"), [ ] ), TRUE)
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
