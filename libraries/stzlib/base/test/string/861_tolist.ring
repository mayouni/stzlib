load "../../stzBase.ring"
load "../_narrated.ring"

# ToList parses a list-in-string. Archive block #861.

Scenario("A bracketed triple")
	Then("parsed back to a Ring list",
		ListEq( Q('[1, 2, 3]').ToList(), [ 1, 2, 3 ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
