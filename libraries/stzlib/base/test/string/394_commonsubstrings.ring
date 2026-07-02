load "../../stzBase.ring"
load "../_narrated.ring"

# CommonSubStrings between two sentences sharing the word "Ring".
# Archive block #394.

Scenario("Common substrings of two sentences")
	Given('"Ring is nice" vs "I love Ring"')
	o1 = new stzString("Ring is nice")
	Then("the shared substrings",
		ListEq( o1.CommonSubStrings(:With = "I love Ring"),
			[ "R", "Ri", "Rin", "Ring", "i", "in", "ing", "n", "ng", "g", " ", "e" ] ), TRUE)
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
