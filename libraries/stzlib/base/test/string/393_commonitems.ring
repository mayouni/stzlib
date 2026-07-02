load "../../stzBase.ring"
load "../_narrated.ring"

# The set intersection of two substring lists, via stzList.CommonItems
# (direct-list arg) and stzListOfLists.CommonItems. Both dedupe and keep
# the first list's order. (The archive's second #--> showed a different
# enumeration order for the same 12-item set; both forms now agree on the
# host-order reading.) Archive block #393.

Scenario("Common items of two substring lists")
	aList1 = Q("Ring is nice").SubStrings()
	aList2 = Q("I love Ring").SubStrings()
	Then("the direct-arg form",
		ListEq( Q(aList1).CommonItems(aList2),
			[ "R", "Ri", "Rin", "Ring", "i", "in", "ing", "n", "ng", "g", " ", "e" ] ), TRUE)
	o1 = new stzListOfLists([ aList1, aList2 ])
	Then("the list-of-lists form agrees",
		ListEq( o1.CommonItems(),
			[ "R", "Ri", "Rin", "Ring", "i", "in", "ing", "n", "ng", "g", " ", "e" ] ), TRUE)
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
