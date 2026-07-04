load "../../stzBase.ring"
load "../_narrated.ring"

# / with a string divisor splits on it. Archive block #760.

Scenario("Splitting on a dash")
	o1 = new stzString("ab-ac-ad")
	Then("three parts",
		ListEq( o1 / "-", [ "ab", "ac", "ad" ] ), TRUE)
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
