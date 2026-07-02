load "../../stzBase.ring"
load "../_narrated.ring"

# On a stzList, NextNItems(n, :StartingAtPosition = p) returns the n items
# strictly AFTER p, and PreviousNItems the n items strictly BEFORE p --
# matching the string-side NextNChars semantics. Archive block #417.

Scenario("Items around a position")
	Given('[ ".",".",".", 4, 5, 6,".",".","." ]')
	o1 = new stzList([ ".",".",".", 4, 5, 6,".",".","." ])
	Then("the 3 items after position 3",
		ListEq( o1.NextNItems(3, :StartingAtPosition = 3), [ 4, 5, 6 ] ), TRUE)
	Then("the 3 items before position 7",
		ListEq( o1.PreviousNItems(3, :StartingAtPosition = 7), [ 4, 5, 6 ] ), TRUE)
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
