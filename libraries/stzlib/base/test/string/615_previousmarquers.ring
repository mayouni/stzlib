load "../../stzBase.ring"
load "../_narrated.ring"

# The directional marquer lists. Archive block #615.

Scenario("Marquers before and after")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("before position 50",
		ListEq( o1.PreviousMarquers(:StartingAt = 50 ), [ "#1", "#2", "#3" ] ), TRUE)
	Then("after position 15",
		ListEq( o1.NextMarquers(:StartingAt = 15), [ "#2", "#3", "#1" ] ), TRUE)
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
