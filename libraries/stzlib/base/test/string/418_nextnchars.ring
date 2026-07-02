load "../../stzBase.ring"
load "../_narrated.ring"

# The string-side twins: NextNChars / PreviousNChars around a position
# (exclusive), as char lists. Archive block #418.

Scenario("Chars around a position")
	Given('"...456..."')
	o1 = new stzString("...456...")
	Then("the 3 chars after position 3",
		ListEq( o1.NextNChars(3, :StartingAt = 3), [ "4", "5", "6" ] ), TRUE)
	Then("the 3 chars before position 7",
		ListEq( o1.PreviousNChars(3, :StartingAtPosition = 7), [ "4", "5", "6" ] ), TRUE)
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
