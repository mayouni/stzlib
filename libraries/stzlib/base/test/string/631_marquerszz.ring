load "../../stzBase.ring"
load "../_narrated.ring"

# The full marquer round-trip: locate, fill with values, re-mark, sort,
# refill. Archive block #631.

Scenario("Three kids through the marquer pipeline")
	acMyKids = [ "Teeba", "Haneen", "Hussein" ]
	o1 = new stzString("My three kids are #1, #2 and #3!")
	Then("the sections",
		ListEq( o1.MarquersZZ(),
			[ [ "#1", [19, 20] ], [ "#2", [23, 24] ], [ "#3", [30, 31] ] ] ), TRUE)
	o1.ReplaceMarquers(:with = acMyKids)
	Then("filled in order", o1.Content(), "My three kids are Teeba, Haneen and Hussein!")
	o1.ReplaceSubStringsWithMarquers(acMyKids)
	Then("marked back", o1.Content(), "My three kids are #1, #2 and #3!")
	o1.SortMarquersInDescending()
	Then("sorted descending", o1.Content(), "My three kids are #3, #2 and #1!")
	o1.ReplaceMarquers(:With = acMyKids)
	Then("refilled in the new order",
		o1.Content(), "My three kids are Hussein, Haneen and Teeba!")
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
