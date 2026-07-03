load "../../stzBase.ring"
load "../_narrated.ring"

# First/last N occurrences, plain and from a starting position.
# Archive block #546.

Scenario("Stars in a numbered string")
	o1 = new stzString("12*45*78*c")
	Then("all stars", ListEq( o1.FindAll("*"), [3, 6, 9] ), TRUE)
	Then("the first two", ListEq( o1.NFirstOccurrences(2, :Of = "*"), [3, 6] ), TRUE)
	Then("the first two from 5",
		ListEq( o1.NFirstOccurrencesST(2, :Of = "*", :StartingAt = 5), [6, 9] ), TRUE)
	Then("the last two from 2",
		ListEq( o1.LastNOccurrencesST(2, :Of = "*", :StartingAt = 2), [6, 9] ), TRUE)
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
