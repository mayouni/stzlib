load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedByAsSections with the SAME bound on both sides ("aa" .. "aa") --
# the spans enclosed between consecutive "aa" pairs. Archive block #89.

Scenario("Finding spans bounded by a repeated marker")
	Given('"**aa***aa**aa***"')
	o1 = new stzString("**aa***aa**aa***")
	Then("the spans between the aa pairs are found",
		ListEq( o1.FindAnyBoundedByAsSections([ "aa", "aa" ]), [ [ 5, 7 ], [ 10, 11 ] ] ), TRUE)
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
