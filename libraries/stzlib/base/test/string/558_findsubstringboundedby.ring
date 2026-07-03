load "../../stzBase.ring"
load "../_narrated.ring"

# FindSubStringBoundedBy with a pair bound, and its sections form.
# Archive block #558.

Scenario("The As between stars")
	o1 = new stzString("12*A*33*A*")
	Then("the bounded As",
		ListEq( o1.FindSubStringBoundedBy("A", [ "*", "*" ]), [ 4, 9 ] ), TRUE)
	Then("their sections",
		ListEq( o1.FindSubStringBoundedByAsSections("A", [ "*", "*" ]),
			[ [4, 4], [9, 9] ] ), TRUE)
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
