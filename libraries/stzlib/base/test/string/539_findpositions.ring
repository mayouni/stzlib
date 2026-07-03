load "../../stzBase.ring"
load "../_narrated.ring"

# FindPositions / FindAsSections with the :Of spelling, then the
# bounded-substrings finders with the inline :and bound shape.
# Archive block #539.

Scenario("Finding many everywhere")
	o1 = new stzString("How many words in <<many many words>>? So many!")
	Then("the positions",
		ListEq( o1.FindPositions(:Of = "many"), [ 5, 21, 26, 43 ] ), TRUE)
	Then("the sections",
		ListEq( o1.FindAsSections(:Of = "many"),
			[ [5, 8], [21, 24], [26, 29], [43, 46] ] ), TRUE)
EndScenario()

Scenario("Bounded words three ways")
	o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
	Then("the bounded substrings",
		ListEq( o1.AnySubstringsBoundedBy([ "<<", :and = ">>" ]),
			[ "word", "noword", "word" ] ), TRUE)
	Then("their content starts",
		ListEq( o1.FindSubStringsBoundedBy([ "<<", :and = ">>" ]),
			[ 11, 28, 43 ] ), TRUE)
	Then("their content sections",
		ListEq( o1.FindAnyBoundedByAsSections([ "<<",">>" ]),
			[ [11, 14], [28, 33], [43, 46] ] ), TRUE)
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
