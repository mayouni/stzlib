load "../../stzBase.ring"
load "../_narrated.ring"

# The unique view (UZ), the per-marquer finder, and position lookups.
# Archive block #614.

Scenario("Unique marquers and lookups")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3. Again: my name is #1!")
	Then("unique with all positions",
		ListEq( o1.MarquersUZ(),
			[ [ "#1", [ 12, 66 ] ], [ "#2", [ 26 ] ], [ "#3", [ 44 ] ] ] ), TRUE)
	Then("finding #1",
		ListEq( o1.FindMarquer("#1"), [ 12, 66] ), TRUE)
	Then("finding a missing one",
		ListEq( o1.FindMarquer("#7"), [ ] ), TRUE)
	Then("by position 66", o1.MarquerByPosition(66), "#1")
	Then("by position 44", o1.MarquerByPosition(44), "#3")
	Then("by both its positions",
		ListEq( o1.MarquerByPositions([ 12, 66 ]), [ "#1", "#1" ] ), TRUE)
	Then("two by their positions",
		ListEq( o1.MarquersByPositions([ 26, 44 ]), [ "#2", "#3" ] ), TRUE)
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
