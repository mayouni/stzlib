load "../../stzBase.ring"
load "../_narrated.ring"

# The case-insensitive substring count folds the duplicate "l" of "hello"
# -- 14 unique remain. Archive block #400.

Scenario("Case-insensitive substrings of hello")
	o1 = new stzString("hello")
	Then("the folded count", o1.NumberOfSubStringsCS(FALSE), 14)
	Then("the folded list",
		ListEq( o1.SubStringsCS(FALSE),
			[ "h", "he", "hel", "hell", "hello",
			  "e", "el", "ell", "ello",
			  "l", "ll", "llo", "lo",
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
