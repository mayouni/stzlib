load "../../stzBase.ring"
load "../_narrated.ring"

# FindD and its section/Z/ZZ companions going :Backward -- nearest first.
# (The archive's "[13, 5]" in the AsSections line is a typo for [13, 15].)
# Archive block #335.

Scenario("Backward list finders")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the positions, nearest first",
		ListEq( o1.FindD( "♥♥♥", :Backward ), [ 13, 8, 3 ] ), TRUE)
	Then("their sections",
		ListEq( o1.FindAsSectionsD( "♥♥♥", :Backward ),
			[ [13, 15], [8, 10], [3, 5] ] ), TRUE)
	Then("FindDZ is the position list",
		ListEq( o1.FindDZ( "♥♥♥", :Backward), [ 13, 8, 3 ] ), TRUE)
	Then("FindDZZ is the span list",
		ListEq( o1.FindDZZ( "♥♥♥", :Backward), [ [13, 15], [8, 10], [3, 5] ] ), TRUE)
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
