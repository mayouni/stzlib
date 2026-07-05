load "../../stzBase.ring"
load "../_narrated.ring"

# ContigToSections groups CONTIGUOUS runs of numbers into sections.
# Archive block #286.

Scenario("Runs of consecutive numbers")
	o1 = new stzListOfNumbers([ 3, 4, 5, 7, 8, 9, 11, 14, 15, 20 ])
	Then("five contiguous runs",
		ListEq( o1.ContigToSections(),
			[ [ 3, 5 ], [ 7, 9 ], [ 11, 11 ], [ 14, 15 ], [ 20, 20 ] ] ), TRUE)
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
