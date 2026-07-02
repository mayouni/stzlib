load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedBy with distinct "<<" ">>" bounds: content start positions
# and sections; the IB form returns the OPENERS' positions.
# Archive block #344.

Scenario("Any-bounded-by with distinct multi-char bounds")
	Given('"*<<***>>**<<***>>*"')
	o1 = new stzString("*<<***>>**<<***>>*")
	Then("the content start positions",
		ListEq( o1.FindAnyBoundedBy([ "<<", ">>" ]), [ 4, 13 ] ), TRUE)
	Then("the content sections",
		ListEq( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]),
			[ [4, 6], [13, 15] ] ), TRUE)
	Then("the IB positions anchor at the openers",
		ListEq( o1.FindAnyBoundedByIB([ "<<", ">>" ]), [ 2, 11 ] ), TRUE)
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
