load "../../stzBase.ring"
load "../_narrated.ring"

# The list twins of block #516. NOTE: the archive's #--> for the swap
# showed the list UNCHANGED ([ "A", "B", "C" ]) -- a copy-paste error;
# swapping positions 2 and 3 of [A, B, C] gives [A, C, B], exactly as
# the string version (block #516) does. Archive block #517.

Scenario("Moving and swapping items")
	o1 = new stzList([ "A", "C", "B" ])
	o1.Move( :ItemFromPosition = 3, :To = 2 )
	Then("B moved before C", ListEq( o1.Content(), [ "A", "B", "C" ] ), TRUE)
	o1.Swap( :Positions = 2, :And = 3 )
	Then("swapping 2 and 3 gives ACB", ListEq( o1.Content(), [ "A", "C", "B" ] ), TRUE)
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
