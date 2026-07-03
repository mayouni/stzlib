load "../../stzBase.ring"
load "../_narrated.ring"

# The bound runs are runs of the SAME non-space char -- around the
# "word" inside <<nonword>> they are the single "n" and the ">>" pair.
# Archive block #572.

Scenario("Bounds inside a non-word")
	o1 = new stzString("bla <<nonword>> bla")
	Then("the n run and the closer",
		ListEq( o1.FindSubStringBoundsZZ("word"), [ [9, 9], [14, 15] ] ), TRUE)
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
