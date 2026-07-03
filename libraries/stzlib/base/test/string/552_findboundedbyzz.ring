load "../../stzBase.ring"
load "../_narrated.ring"

# The ZZ (sections) forms of the bounded finds -- distinct bounds,
# single-char bounds, and the include-bounds spans. Archive block #552.

Scenario("Sections instead of positions")
	o1 = new stzString("txt <<ring>> txt <<php>>")
	Then("distinct bounds",
		ListEq( o1.FindBoundedByZZ([ "<<", ">>" ]), [ [7, 10], [20, 22] ] ), TRUE)
	o2 = new stzString("*2*45*78*0*")
	Then("a single-char bound",
		ListEq( o2.FindBoundedByZZ("*"),
			[ [2, 2], [4, 5], [7, 8], [10, 10] ] ), TRUE)
	Then("its include-bounds spans overlap",
		ListEq( o2.FindAnyBoundedByIBZZ("*"),
			[ [1, 3], [3, 6], [6, 9], [9, 11] ] ), TRUE)
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
