load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringBounds lists the bound-run substrings; the IB removal drops
# the bounded occurrences WITH their bounds (bare words survive).
# Archive block #570.

Scenario("The bounds, then the full removal")
	o1 = new stzString("bla word bla <<word>> bla bla <<word>> bla <<word>> word")
	Then("the bound runs",
		ListEq( o1.SubStringBounds("word"),
			[ "<<", ">>", "<<", ">>", "<<", ">>" ] ), TRUE)
	o1.RemoveBoundedSubStringIB("word")
	Then("bounded blocks gone, bare words kept",
		o1.Content(), "bla word bla  bla bla  bla  word")
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
