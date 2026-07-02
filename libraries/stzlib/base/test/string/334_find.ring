load "../../stzBase.ring"
load "../_narrated.ring"

# Find / FindZ / FindZZ: all the positions of a substring (Z accepts the
# :Of = ... spelling and equals Find), and the ZZ span list.
# Archive block #334.

Scenario("Find and its Z / ZZ list forms")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("Find lists the positions",
		ListEq( o1.Find( "♥♥♥" ), [ 3, 8, 13 ] ), TRUE)
	Then("FindZ(:Of) is the same",
		ListEq( o1.FindZ( :Of = "♥♥♥"), [ 3, 8, 13 ] ), TRUE)
	Then("FindZZ(:Of) lists the spans",
		ListEq( o1.FindZZ( :Of = "♥♥♥"), [ [3, 5], [8, 10], [13, 15] ] ), TRUE)
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
