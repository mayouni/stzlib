load "../../stzBase.ring"
load "../_narrated.ring"

# SplitAtSections removes the sections and returns what remains
# between them. Archive block #960.

Scenario("Splitting at the number islands")
	o1 = new stzString("---456----123--67---")
	Then("the same four dash runs",
		ListEq( o1.SplitAtSections([ [ 4, 6 ], [ 11, 13 ], [ 16, 17 ] ]),
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
