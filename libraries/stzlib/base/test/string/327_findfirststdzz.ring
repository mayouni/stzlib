load "../../stzBase.ring"
load "../_narrated.ring"

# The FindSTDZZ forms going backward -- plain spans of the nearest /
# farthest / 2nd occurrence ending at or before position 12.
# Archive block #327.

Scenario("Backward STDZZ spans")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the first backward from 12",
		ListEq( o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 12, :Backward), [ 8, 10 ] ), TRUE)
	Then("the last backward from 12",
		ListEq( o1.FindLastSTDZZ("♥♥♥", :StartingAt = 12, :Backward), [ 3, 5 ] ), TRUE)
	Then("the 2nd backward from 12",
		ListEq( o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 12, :Backward), [ 3, 5 ] ), TRUE)
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
