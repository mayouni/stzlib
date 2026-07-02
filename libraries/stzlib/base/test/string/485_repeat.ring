load "../../stzBase.ring"
load "../_narrated.ring"

# The global Repeat trio: Repeat/RepeatInList give a list, RepeatInString
# concatenates (Ring's copy() equivalent). Archive block #485.

Scenario("Repeating A three times")
	Then("Repeat gives a list", ListEq( Repeat("A", 3), [ "A", "A", "A" ] ), TRUE)
	Then("RepeatInList is its explicit spelling",
		ListEq( RepeatInList("A", 3), [ "A", "A", "A" ] ), TRUE)
	Then("RepeatInString concatenates", RepeatInString("A", 3), "AAA")
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
