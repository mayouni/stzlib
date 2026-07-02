load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedBy with a SAME substring as both bounds ("aa".."aa"):
# overlapping pairing reuses each closer as the next opener, so both gaps
# are found -- content start positions, and ZZ spans. Archive block #340.

Scenario("Same-substring bounds")
	Given('"aa***aa**aa***"')
	o1 = new stzString("aa***aa**aa***")
	Then("the content start positions",
		ListEq( o1.FindAnyBoundedBy([ "aa", "aa" ]), [ 3, 8 ] ), TRUE)
	Then("the content spans",
		ListEq( o1.FindAnyBoundedByZZ([ "aa", "aa" ]), [ [3, 5], [8, 9] ] ), TRUE)
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
