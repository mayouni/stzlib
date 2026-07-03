load "../../stzBase.ring"
load "../_narrated.ring"

# The sectional projections: flat sections, the ZZ grouping, and the
# unique UZZ grouping. Archive block #618.

Scenario("Marquer sections, three ways")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("the flat sections",
		ListEq( o1.FindMarquersAsSections(),
			[ [12, 13], [26, 27], [44, 45], [66, 67] ] ), TRUE)
	Then("the ZZ grouping",
		ListEq( o1.MarquersZZ(),
			[ [ "#1", [12, 13] ], [ "#2", [26, 27] ],
			  [ "#3", [44, 45] ], [ "#1", [66, 67] ] ] ), TRUE)
	Then("the unique UZZ grouping",
		ListEq( o1.MarquersUZZ(),
			[ [ "#1", [ [12, 13], [66, 67] ] ],
			  [ "#2", [ [26, 27] ] ],
			  [ "#3", [ [44, 45] ] ] ] ), TRUE)
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
