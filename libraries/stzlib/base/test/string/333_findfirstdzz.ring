load "../../stzBase.ring"
load "../_narrated.ring"

# The DZZ (direction + span) finders -- same order as block #331, as
# [start, end] spans. Archive block #333.

Scenario("Direction-only span finders")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("backward-first span",
		ListEq( o1.FindFirstDZZ("♥♥♥", :Backward), [ 13, 15 ] ), TRUE)
	Then("backward-last span",
		ListEq( o1.FindLastDZZ("♥♥♥", :Backward), [ 3, 5 ] ), TRUE)
	Then("backward-2nd span",
		ListEq( o1.FindNthDZZ(2, "♥♥♥", :Backward), [ 8, 10 ] ), TRUE)
	Then("all spans, nearest first",
		ListEq( o1.FindDZZ("♥♥♥", :Backward),
			[ [13, 15], [8, 10], [3, 5] ] ), TRUE)
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
