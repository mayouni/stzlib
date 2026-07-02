load "../../stzBase.ring"
load "../_narrated.ring"

# CommonSubStrings(:With = other): the substrings shared by both strings.
# Archive block #392.

Scenario("Common substrings of two short strings")
	Given('"ab" vs "abc"')
	o1 = new stzString("ab")
	Then("the shared substrings",
		ListEq( o1.CommonSubStrings(:With = "abc"), [ "a", "ab", "b" ] ), TRUE)
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
