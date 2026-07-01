load "../../stzBase.ring"
load "../_narrated.ring"

# The STZ forms combine :StartingAt with the Z grouping: each returns
# [sub, position] for the nth / first / last occurrence at or after the
# starting position. Archive block #318.

Scenario("Starting-at Z groupings")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the 2nd from 3, grouped",
		ListEq( o1.NthSTZ(2, "♥♥♥", :StartingAt = 3), [ "♥♥♥", 8 ] ), TRUE)
	Then("the first from 5, grouped",
		ListEq( o1.FirstSTZ("♥♥♥", :StartingAt = 5), [ "♥♥♥", 8 ] ), TRUE)
	Then("the last from 6, grouped",
		ListEq( o1.LastSTZ("♥♥♥", :StartingAt = 6), [ "♥♥♥", 13 ] ), TRUE)
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
