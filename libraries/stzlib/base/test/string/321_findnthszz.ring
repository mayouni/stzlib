load "../../stzBase.ring"
load "../_narrated.ring"

# The SZZ forms: :StartingAt + the [sub, [start, end]] grouping, forward.
# Archive block #321.

Scenario("Starting-at SZZ groupings")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the 2nd from 3",
		ListEq( o1.FindNthSZZ(2, "♥♥♥", :StartingAt = 3), [ "♥♥♥", [8, 10] ] ), TRUE)
	Then("the first from 5",
		ListEq( o1.FindFirstSZZ("♥♥♥", :StartingAt = 5), [ "♥♥♥", [8, 10] ] ), TRUE)
	Then("the last from 6",
		ListEq( o1.FindLastSZZ("♥♥♥", :StartingAt = 6), [ "♥♥♥", [13, 15] ] ), TRUE)
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
