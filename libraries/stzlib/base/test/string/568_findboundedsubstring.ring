load "../../stzBase.ring"
load "../_narrated.ring"

# The IB forms span from the left bound run to the right one.
# Archive block #568.

Scenario("Include-bounds spans")
	o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>> word")
	Then("the bounded occurrences",
		ListEq( o1.FindBoundedSubString("word"), [ 11, 28, 41 ] ), TRUE)
	Then("the IB starts",
		ListEq( o1.FindBoundedSubStringIB("word"), [ 9, 26, 39 ] ), TRUE)
	Then("the IB spans",
		ListEq( o1.FindBoundedSubStringIBZZ("word"),
			[ [9, 16], [26, 33], [39, 46] ] ), TRUE)
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
