load "../../stzBase.ring"
load "../_narrated.ring"

# Case-sensitive vs case-insensitive substring enumeration of "BEbe". With
# TRUE (case-sensitive) the four distinct letters give 10 substrings; with FALSE
# (case-insensitive) "B"/"b" and "E"/"e" collapse, giving 7. Archive block #127.
#
# NOTE: under FALSE the impl keeps each substring's ORIGINAL case (first
# occurrence) -- e.g. "B", "BE", "BEb" -- whereas the archive showed them
# lowercased. The count (7) and the set are the same; only the case display
# differs (impl preserves source case, which is asserted here).

Scenario("Case sensitivity in substring enumeration")
	Given('"BEbe"')
	o1 = new stzString("BEbe")
	Then("case-sensitive gives 10 substrings", o1.NumberOfSubStringsCS(TRUE), 10)
	Then("case-insensitive collapses to 7", o1.NumberOfSubStringsCS(FALSE), 7)
	Then("the case-sensitive list is all 10",
		ListEq( o1.SubStringsCS(TRUE), [ "B", "BE", "BEb", "BEbe", "E", "Eb", "Ebe", "b", "be", "e" ] ), TRUE)
	Then("the case-insensitive list keeps source case",
		ListEq( o1.SubStringsCS(FALSE), [ "B", "BE", "BEb", "BEbe", "E", "Eb", "Ebe" ] ), TRUE)
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
