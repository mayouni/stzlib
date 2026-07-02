load "../../stzBase.ring"
load "../_narrated.ring"

# All 15 windows of "*4*34" (dup "*" and "4" kept). Archive block #401.

Scenario("All substrings of a starred number")
	o1 = new stzString("*4*34")
	Then("the count", o1.NumberOfSubStrings(), 15)
	Then("the windows",
		ListEq( o1.SubStrings(),
			[ "*", "*4", "*4*", "*4*3", "*4*34",
			  "4", "4*", "4*3", "4*34", "*",
			  "*3", "*34", "3", "34", "4" ] ), TRUE)
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
