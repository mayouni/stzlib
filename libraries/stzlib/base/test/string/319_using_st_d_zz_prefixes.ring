load "../../stzBase.ring"
load "../_narrated.ring"

# The STDZZ forms: :StartingAt + direction + the bare [start, end] span.
# Backward candidates END at or before :StartingAt; the "first" backward is
# the nearest, the "last" the farthest (here all three roads lead to the
# occurrence at [3,5]). Archive block #319.

Scenario("Backward STDZZ spans")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the 2nd backward from 10",
		ListEq( o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 10, :Backward), [ 3, 5 ] ), TRUE)
	Then("the first backward from 5",
		ListEq( o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 5, :Backward), [ 3, 5 ] ), TRUE)
	Then("the last backward from the last char",
		ListEq( o1.FindLastSTDZZ("♥♥♥", :StartingAt = :LastChar, :Backward), [ 3, 5 ] ), TRUE)
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
