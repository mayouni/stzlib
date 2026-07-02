load "../../stzBase.ring"
load "../_narrated.ring"

# FindSubStringsBoundedByZZ with the SAME substring as both bounds: per the
# settled overlapping rule, each closer is reused as the next opener, so
# both gaps between the three "aa" markers are found. Archive block #341.

Scenario("Same-substring bounds overlap")
	Given('"**aa***aa**aa***" (aa at 3, 8, 12)')
	o1 = new stzString("**aa***aa**aa***")
	Then("both enclosed spans are reported",
		ListEq( o1.FindSubStringsBoundedByZZ(["aa", "aa"]), [ [5, 7], [10, 11] ] ), TRUE)
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
