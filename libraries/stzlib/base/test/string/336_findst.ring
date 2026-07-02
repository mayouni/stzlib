load "../../stzBase.ring"
load "../_narrated.ring"

# FindST / FindSTZ / FindSTZZ: ALL the occurrences starting at or after
# :StartingAt, as positions or spans. Archive block #336.

Scenario("Starting-at list finders")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the positions from 6",
		ListEq( o1.FindST( "♥♥♥", :StartingAt = 6 ), [ 8, 13 ] ), TRUE)
	Then("FindSTZ is the same list",
		ListEq( o1.FindSTZ( "♥♥♥", :StartingAt = 6 ), [ 8, 13 ] ), TRUE)
	Then("FindSTZZ lists the spans",
		ListEq( o1.FindSTZZ( "♥♥♥", :StartingAt = 6 ), [ [8, 10], [13, 15] ] ), TRUE)
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
