load "../../stzBase.ring"
load "../_narrated.ring"

# RepeatedInAPair on a number. Archive block #488.

Scenario("A number pairs with itself")
	Then("5 pairs up", ListEq( Q(5).RepeatedInAPair(), [ 5, 5 ] ), TRUE)
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
