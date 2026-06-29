load "../../stzBase.ring"
load "../_narrated.ring"

# The long internal finder FindSubStringBoundsUpToNCharsAsSections gives the
# position spans of the n-char bounds around each occurrence; the friendly
# BoundsOfXT / BoundsOf turn those into the bound substrings, per occurrence.
# Archive block #42.

Scenario("The bounds around each occurrence of a substring")
	Given('"Hello <<<Ring>>>, the beautiful (((Ring)))!"')
	o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
	Then("the internal finder gives the 2-char bound spans",
		ListEq( o1.FindSubStringBoundsUpToNCharsAsSections("Ring", 2),
			[ [8,9], [14,15], [34,35], [40,41] ] ), TRUE)
	Then("BoundsOfXT caps each bound to 2 chars",
		ListEq( o1.BoundsOfXT("Ring", [ 2, 2 ]), [ [ "<<", ">>" ], [ "((", "))" ] ] ), TRUE)
	Then("BoundsOf returns the full bound runs",
		ListEq( o1.BoundsOf("Ring"), [ [ "<<<", ">>>" ], [ "(((", ")))" ] ] ), TRUE)
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
