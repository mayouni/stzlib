load "../../stzBase.ring"
load "../_narrated.ring"

# Single-char bounds overlap: every gap between stars is a region --
# content starts, include-bounds starts, the substrings, and the
# [substring, span] grouping. Archive block #551.

Scenario("Gaps between single stars")
	o1 = new stzString("*2*45*78*0*")
	Then("the content starts",
		ListEq( o1.FindAnyBoundedBy([ "*","*" ]), [ 2, 4, 7, 10 ] ), TRUE)
	Then("the include-bounds starts",
		ListEq( o1.FindAnyBoundedByIB("*"), [ 1, 3, 6, 9 ] ), TRUE)
	Then("the substrings",
		ListEq( o1.AnyBoundedBy("*"), [ "2", "45", "78", "0" ] ), TRUE)
	Then("the ZZ grouping",
		ListEq( o1.AnyBoundedByZZ("*"),
			[ [ "2", [2, 2] ], [ "45", [4, 5] ],
			  [ "78", [7, 8] ], [ "0", [10, 10] ] ] ), TRUE)
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
