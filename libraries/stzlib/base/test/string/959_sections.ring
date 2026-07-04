load "../../stzBase.ring"
load "../_narrated.ring"

# Sections reads several slices at once. Archive block #959.

Scenario("The dashes between the numbers")
	o1 = new stzString("---456----123--67---")
	Then("four dash runs",
		ListEq( o1.Sections([ [ 1, 3 ], [ 7, 10 ], [ 14, 15 ], [ 18, 20 ] ]),
			[ "---", "----", "--", "---" ] ), TRUE)
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
