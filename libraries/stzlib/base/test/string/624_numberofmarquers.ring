load "../../stzBase.ring"
load "../_narrated.ring"

# Counting and locating shuffled marquers. Archive block #624.

Scenario("Three shuffled candidates")
	CheckParamsOff()
	o1 = new stzString("The first candidate is #3, the second is #1, while the third is #2!")
	Then("three marquers", o1.NumberOfMarquers(), 3)
	Then("their positions",
		ListEq( o1.MarquersPositions(), [ 24, 42, 65 ] ), TRUE)
	Then("the 2nd after 14", o1.FindNextNthMarquer(2, 14), 42)
	Then("positions sorted ascending",
		ListEq( o1.MarquersPositionsSortedInAscending(), [ 24, 42, 65 ] ), TRUE)
	CheckParamsOn()
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
