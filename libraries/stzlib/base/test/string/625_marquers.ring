load "../../stzBase.ring"
load "../_narrated.ring"

# The marquer views keep TEXT order for shuffled numbers.
# Archive block #625.

Scenario("Shuffled marquer views")
	o1 = new stzString("The first candidate is #3, the second is #1, while the third is #2!")
	Then("the strings, as written",
		ListEq( o1.Marquers(), [ "#3", "#1", "#2" ] ), TRUE)
	Then("the Z grouping",
		ListEq( o1.MarquersZ(),
			[ [ "#3", 24 ], [ "#1", 42 ], [ "#2", 65 ] ] ), TRUE)
	Then("the ZZ grouping",
		ListEq( o1.MarquersZZ(),
			[ [ "#3", [24, 25] ], [ "#1", [42, 43] ], [ "#2", [65, 66] ] ] ), TRUE)
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
