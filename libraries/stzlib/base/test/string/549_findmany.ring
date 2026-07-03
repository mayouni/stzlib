load "../../stzBase.ring"
load "../_narrated.ring"

# FindMany returns the FLAT sorted positions (the original monolith:
# flatten + sort); Split drops edge empties; the IB forms give the
# include-bounds starts/spans of the star-bounded regions.
# Archive block #549.

Scenario("Three words between star runs")
	o1 = new stzString("***ONE***TWO***THREE***")
	Then("the words' positions, flat and sorted",
		ListEq( o1.FindMany([ "ONE", "TWO", "THREE"]), [ 4, 10, 16 ] ), TRUE)
	Then("splitting on the triple star",
		ListEq( o1.SplitQ(:Using = "***").Content(), [ "ONE", "TWO", "THREE" ] ), TRUE)
	Then("the include-bounds starts",
		ListEq( o1.FindAnyBoundedByIB("**"), [ 1, 7, 13 ] ), TRUE)
	Then("the include-bounds spans",
		ListEq( o1.FindAnyBoundedByIBZZ("**"),
			[ [1, 8], [7, 14], [13, 22] ] ), TRUE)
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
