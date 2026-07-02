load "../../stzBase.ring"
load "../_narrated.ring"

# SplitToPartsOfNChars(n) yields pieces of EXACTLY n chars (the shorter
# remainder is dropped -- the alias SplitToPartsOfExactlyNChars says so);
# the XT form keeps the remainder. Archive block #414.

Scenario("Exact pieces vs kept remainder")
	Given('"AB12CD345"')
	o1 = new stzString("AB12CD345")
	Then("the exact form drops the lone 5",
		ListEq( o1.SplitToPartsOfNChars(2), [ "AB", "12", "CD", "34" ] ), TRUE)
	Then("the XT form keeps it",
		ListEq( o1.SplitToPartsOfNCharsXT(2), [ "AB", "12", "CD", "34", "5" ] ), TRUE)
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
