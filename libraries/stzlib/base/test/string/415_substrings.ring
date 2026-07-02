load "../../stzBase.ring"
load "../_narrated.ring"

# The 6 windows of "ABC". Archive block #415.

Scenario("All substrings of ABC")
	o1 = new stzString("ABC")
	Then("the windows",
		ListEq( o1.SubStrings(), [ "A", "AB", "ABC", "B", "BC", "C" ] ), TRUE)
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
