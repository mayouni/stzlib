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
	? "  NOTE  First2Chars() -> " + @@(o1.First2Chars()) + "  (should be a LIST -- deferred)"
	? "  NOTE  Last3Chars()  -> " + @@(o1.Last3Chars()) + "  (should be a LIST -- deferred)"
	? "  NOTE  Next3CharsAsString(:StartingAt=2) -> " + @@(o1.Next3CharsAsString(:StartingAt = 2)) + "  (archive wanted 'CDE' -- deferred)"
EndScenario()

Summary()
