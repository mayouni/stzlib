load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedByIB returns the include-bounds substrings; BoundedByIBZZ pairs each
# with its [from,to] span. Both are codepoint-correct on multibyte content.
# Archive block #187.

Scenario("Include-bounds substrings and their spans")
	Given('"...<<♥♥♥>>...<<★★>>..."')
	o1 = new stzString("...<<♥♥♥>>...<<★★>>...")
	Then("BoundedByIB keeps the bounds",
		ListEq( o1.BoundedByIB([ "<<", ">>" ]), [ "<<♥♥♥>>", "<<★★>>" ] ), TRUE)
	Then("BoundedByIBZZ pairs each with its span",
		ListEq( o1.BoundedByIBZZ([ "<<", ">>" ]),
			[ [ "<<♥♥♥>>", [4,10] ], [ "<<★★>>", [14,19] ] ] ), TRUE)
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
