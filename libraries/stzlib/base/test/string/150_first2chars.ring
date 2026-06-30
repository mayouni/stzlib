load "../../stzBase.ring"
load "../_narrated.ring"

# First2Chars / Last3Chars / Next3Chars and their AsString twins. Archive #150.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the plural ...Chars() forms return
# a STRING ("ab", "CDE") instead of a LIST ([ "a","b" ], [ "C","D","E" ]) -- same
# family as LeadingChars (block 33). Also Next3Chars(:StartingAt=2) starts AT
# position 2 ("bCD") whereas the archive expected the run after it ("CDE"). The
# AsString forms (which SHOULD be strings) are asserted; the rest are NOTEs.

Scenario("First / last / next chars as strings")
	Given('"abCDE"')
	o1 = new stzString("abCDE")
	Then("First2CharsAsString() is 'ab'", o1.First2CharsAsString(), "ab")
	Then("Last3CharsAsString() is 'CDE'", o1.Last3CharsAsString(), "CDE")
	# Should be lists, but return strings:
	Then("First2Chars() is a LIST", ListEq( o1.First2Chars(), [ "a", "b" ] ), TRUE)
	Then("Last3Chars() is a LIST", ListEq( o1.Last3Chars(), [ "C", "D", "E" ] ), TRUE)
	Then("Next3CharsAsString(:StartingAt=2) is the run after pos 2", o1.Next3CharsAsString(:StartingAt = 2), "CDE")
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
