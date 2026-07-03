load "../../stzBase.ring"
load "../_narrated.ring"

# The first / last N occurrences. Archive block #509.

Scenario("First and last two underscores")
	o1 = new stzString("ab_cd_ef_gh")
	Then("the first two", ListEq( o1.FindFirstNOccurrences(2, "_"), [3, 6] ), TRUE)
	Then("the last two", ListEq( o1.FindLastNOccurrences(2, "_"), [6, 9] ), TRUE)
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
