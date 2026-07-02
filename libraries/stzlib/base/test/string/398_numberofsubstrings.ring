load "../../stzBase.ring"
load "../_narrated.ring"

# Substring counting with case control: the case-sensitive walk sees 10
# windows on "abAb"; case-insensitively "A"/"Ab" fold into "a"/"ab" and 7
# unique remain. Archive block #398.

Scenario("Counting substrings, case on and off")
	Given('"abAb"')
	o1 = new stzString("abAb")
	Then("all windows", o1.NumberOfSubStrings(), 10)
	Then("their list",
		ListEq( o1.SubStrings(),
			[ "a", "ab", "abA", "abAb", "b", "bA", "bAb", "A", "Ab", "b" ] ), TRUE)
	Then("case-insensitive count", o1.NumberOfSubStringsCS(FALSE), 7)
	Then("the folded list",
		ListEq( o1.SubStringsCS(FALSE),
			[ "a", "ab", "abA", "abAb", "b", "bA", "bAb" ] ), TRUE)
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
