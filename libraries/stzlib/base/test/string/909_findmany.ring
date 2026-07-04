load "../../stzBase.ring"
load "../_narrated.ring"

# FindMany on a string -- flat, sorted positions. Archive block #909.

Scenario("The letters between the dashes")
	o1 = new stzString("--R--I--N--G--")
	Then("3, 6, 9, 12",
		ListEq( o1.FindMany([ "R", "I", "N", "G" ]), [ 3, 6, 9, 12 ] ), TRUE)
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
