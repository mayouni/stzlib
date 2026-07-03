load "../../stzBase.ring"
load "../_narrated.ring"

# The marquer projections: strings, positions, Z ([m, pos]) and the
# sections grouping. Archive block #608.

Scenario("Four marquers, every view")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("the strings",
		ListEq( o1.Marquers(), [ "#1", "#2", "#3", "#1" ] ), TRUE)
	Then("the positions",
		ListEq( o1.MarquersPositions(), [ 12, 26, 44, 66 ] ), TRUE)
	Then("the Z grouping",
		ListEq( o1.MarquersZ(),
			[ [ "#1", 12 ], [ "#2", 26 ], [ "#3", 44 ], [ "#1", 66 ] ] ), TRUE)
	Then("the sections grouping",
		ListEq( o1.MarquersAndSections(),
			[ [ "#1", [12, 13] ], [ "#2", [26, 27] ],
			  [ "#3", [44, 45] ], [ "#1", [66, 67] ] ] ), TRUE)
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
