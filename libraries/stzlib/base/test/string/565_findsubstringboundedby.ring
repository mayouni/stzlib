load "../../stzBase.ring"
load "../_narrated.ring"

# The equality contract in full: "word" matches only the region that IS
# "word" (not <<noword>> nor <<wording>>), while FindAnyBoundedBy sees
# all three regions. Archive block #565.

Scenario("Equality vs any-bounded")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<wording>>")
	Then("only the exact word region",
		ListEq( o1.FindSubStringBoundedBy("word", [ "<<", ">>" ]), [ 11 ] ), TRUE)
	Then("... and its span",
		ListEq( o1.FindSubStringBoundedByZZ("word", [ "<<", ">>" ]), [ [11, 14] ] ), TRUE)
	Then("all three regions' starts",
		ListEq( o1.FindAnyBoundedBy([ "<<",">>" ]), [ 11, 28, 43 ] ), TRUE)
	Then("... and their spans",
		ListEq( o1.FindAnyBoundedByZZ([ "<<",">>" ]),
			[ [11, 14], [28, 33], [43, 49] ] ), TRUE)
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
