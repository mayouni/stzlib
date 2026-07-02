load "../../stzBase.ring"
load "../_narrated.ring"

# UniqueChars keeps each char once, in first-appearance order.
# Archive block #452.

Scenario("Unique chars of a stuttering string")
	Then("Riiiiinngg dedups to R i n g",
		ListEq( Q("Riiiiinngg").UniqueChars(), [ "R", "i", "n", "g" ] ), TRUE)
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
