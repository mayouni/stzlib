load "../../stzBase.ring"
load "../_narrated.ring"

# A same-string bound ("**") pairs OVERLAPPINGLY -- each closer is
# reused as the next opener, so no gap between stars is lost.
# Archive block #548.

Scenario("Every gap between double stars")
	o1 = new stzString("**3**67**012**56**92**")
	Then("the content starts",
		ListEq( o1.FindSubStringsBoundedBy("**"), [ 3, 6, 10, 15, 19 ] ), TRUE)
	Then("the content spans",
		ListEq( o1.FindSubStringsBoundedByZZ("**"),
			[ [3, 3], [6, 7], [10, 12], [15, 16], [19, 20] ] ), TRUE)
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
