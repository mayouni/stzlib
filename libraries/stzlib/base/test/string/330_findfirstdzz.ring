load "../../stzBase.ring"
load "../_narrated.ring"

# FindFirstDZZ: the D (direction-only) form -- going :Backward with no
# :StartingAt, the "first" hit is the last occurrence in the string, as a
# plain [start, end] span. Archive block #330.

Scenario("Direction-only first occurrence")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("backward-first is the last occurrence's span",
		ListEq( o1.FindFirstDZZ("♥♥♥", :Backward), [13, 15] ), TRUE)
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
