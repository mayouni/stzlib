load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedBy with the same "aa" marker as both bounds: the
# overlapping rule finds all three enclosed regions (content start
# positions + their sections). Archive block #343.

Scenario("Any-bounded-by with a repeated marker")
	Given('"*aa***aa**aa***aa*"')
	o1 = new stzString("*aa***aa**aa***aa*")
	Then("the content start positions",
		ListEq( o1.FindAnyBoundedBy([ "aa", "aa" ]), [ 4, 9, 13 ] ), TRUE)
	Then("the content sections",
		ListEq( o1.FindAnyBoundedByAsSections([ "aa", "aa" ]),
			[ [4, 6], [9, 10], [13, 15] ] ), TRUE)
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
