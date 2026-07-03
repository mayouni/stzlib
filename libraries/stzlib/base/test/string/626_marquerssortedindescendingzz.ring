load "../../stzBase.ring"
load "../_narrated.ring"

# MarquersSortedInDescendingZZ zips the DESCENDING-sorted marquers onto
# the text-order slots -- the ZZ view of the would-be sorted string.
# (The archive's section ends were off by one; the 2-char marquers span
# [12,13] / [27,28] / [45,46].) Archive block #626.

Scenario("Descending zip")
	o1 = new stzString("My name is #2, may age is #1, and my job is #3.")
	Then("sorted marquers on the text slots",
		ListEq( o1.MarquersSortedInDescendingZZ(),
			[ [ "#3", [12, 13] ], [ "#2", [27, 28] ], [ "#1", [45, 46] ] ] ), TRUE)
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
