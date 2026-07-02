load "../../stzBase.ring"
load "../_narrated.ring"

# All 15 substrings of "hello" (n(n+1)/2 windows, dup "l" kept).
# Archive block #399.

Scenario("All substrings of hello")
	o1 = new stzString("hello")
	Then("the count", o1.NumberOfSubStrings(), 15)
	Then("the windows",
		ListEq( o1.SubStrings(),
			[ "h", "he", "hel", "hell", "hello",
			  "e", "el", "ell", "ello",
			  "l", "ll", "llo", "l", "lo",
			  "o" ] ), TRUE)
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
