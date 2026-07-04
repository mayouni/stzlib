load "../../stzBase.ring"
load "../_narrated.ring"

# UniqueChars and ContainsNOccurrences(:Of). Archive block #854.

Scenario("The five letters underneath")
	o1 = new stzString("abcbbaccbtttx")
	Then("first-seen unique chars",
		ListEq( o1.UniqueChars(), [ "a", "b", "c", "t", "x" ] ), TRUE)
	Then("exactly two a's",
		o1.ContainsNOccurrences(2, :Of = "a"), TRUE)
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
