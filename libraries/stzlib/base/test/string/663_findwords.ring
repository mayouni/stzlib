load "../../stzBase.ring"
load "../_narrated.ring"

# FindWords: the start position of every word. Archive block #663.

Scenario("Word positions in a Proust echo")
	o1 = new stzString("in search of lost time, all the time")
	Then("eight word starts",
		ListEq( o1.FindWords(), [ 1, 4, 11, 14, 19, 25, 29, 33 ] ), TRUE)
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
