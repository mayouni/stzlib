load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfNumbers.ToSections turns break-points into consecutive
# sections. Archive block #272.

Scenario("Four break-points, four sections")
	o1 = new stzListOfNumbers([ 3, 7, 12, 15 ])
	Then("the sections",
		ListEq( o1.ToSections(),
			[ [ 1, 3 ], [ 4, 7 ], [ 8, 12 ], [ 13, 15 ] ] ), TRUE)
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
