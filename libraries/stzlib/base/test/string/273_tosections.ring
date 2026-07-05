load "../../stzBase.ring"
load "../_narrated.ring"

# ... a leading 1 makes the first section a singleton run into the
# next -- same four sections. Archive block #273.

Scenario("A leading break-point")
	o1 = new stzListOfNumbers([ 1, 3, 7, 12, 15 ])
	Then("still four sections",
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
