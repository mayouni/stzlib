load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedByAsSectionsS(open, close, :StartingAt = n) -- the ...S variant
# that takes the two bounds as separate args plus a start offset. Archive #90.

Scenario("Finding bounded spans from a start offset")
	Given('"**aa***aa**aa***" scanned from position 2')
	o1 = new stzString("**aa***aa**aa***")
	Then("the bounded spans are found",
		ListEq( o1.FindAnyBoundedByAsSectionsS("aa", "aa", :StartingAt = 2), [ [ 5, 7 ], [ 10, 11 ] ] ), TRUE)
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
