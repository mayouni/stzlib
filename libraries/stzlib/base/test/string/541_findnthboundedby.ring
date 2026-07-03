load "../../stzBase.ring"
load "../_narrated.ring"

# FindNthBoundedBy(n, sub, bounds): the n-th occurrence of sub that IS a
# bounded region's content; the ZZ form returns its span, and FindNthXT
# takes the :BoundedBy named spelling. Archive block #541.

Scenario("The second bounded word")
	o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")
	Then("its position", o1.FindNthBoundedBy(2, "word", [ "<<", ">>" ]), 28)
	Then("its span",
		ListEq( o1.FindNthBoundedByZZ(2, "word", [ "<<", ">>" ]), [28, 31] ), TRUE)
	Then("the XT spelling", o1.FindNthXT(2, "word", :BoundedBy = ["<<", ">>"]), 28)
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
