load "../../stzBase.ring"
load "../_narrated.ring"

# stzText.Words. Archive block #660.

Scenario("Words of a Proust title")
	o1 = new stzText("in search of lost time")
	Then("five words",
		ListEq( o1.Words(), [ "in", "search", "of", "lost", "time" ] ), TRUE)
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
