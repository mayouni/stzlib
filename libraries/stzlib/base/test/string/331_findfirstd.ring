load "../../stzBase.ring"
load "../_narrated.ring"

# The D (direction-only) position finders: going :Backward the "first" is
# the last occurrence in the string, the "last" the first one, and FindD
# lists ALL positions nearest-first. Archive block #331.

Scenario("Direction-only position finders")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("backward-first", o1.FindFirstD("♥♥♥", :Backward), 13)
	Then("backward-last", o1.FindLastD("♥♥♥", :Backward), 3)
	Then("backward-2nd", o1.FindNthD(2, "♥♥♥", :Backward), 8)
	Then("all positions, nearest first",
		ListEq( o1.FindD("♥♥♥", :Backward), [ 13, 8, 3 ] ), TRUE)
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
