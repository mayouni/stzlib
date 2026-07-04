load "../../stzBase.ring"
load "../_narrated.ring"

# FindMany on a list. Archive block #908.

Scenario("Each letter at its own place")
	o1 = new stzList([ "R", "I", "N", "G" ])
	Then("1 through 4",
		ListEq( o1.FindMany([ "R", "I", "N", "G" ]), [ 1, 2, 3, 4 ] ), TRUE)
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
