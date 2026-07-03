load "../../stzBase.ring"
load "../_narrated.ring"

# FindAll plus the directional Next/Previous occurrence finders. (The
# archive's FindNextOccurrences #--> [18, 40] was off by one -- the
# occurrences sit at 17 and 39, as its own FindAll line shows.)
# Archive block #600.

Scenario("Occurrences in both directions")
	o1 = new stzString("ring is not the ring you ware but the ring you program with")
	Then("all three", ListEq( o1.FindAll("ring"), [ 1, 17, 39 ] ), TRUE)
	Then("the ones after 12",
		ListEq( o1.FindNextOccurrences(:Of = "ring", :StartingAt = 12), [ 17, 39 ] ), TRUE)
	Then("the ones before 32",
		ListEq( o1.FindPreviousOccurrences(:Of = "ring", :StartingAt = 32), [ 1, 17 ] ), TRUE)
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
