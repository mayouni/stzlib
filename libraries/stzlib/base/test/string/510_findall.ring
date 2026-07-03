load "../../stzBase.ring"
load "../_narrated.ring"

# FindAll: every occurrence. Archive block #510.

Scenario("All the underscores")
	o1 = new stzString("ab_cd_ef_gh")
	Then("three of them", ListEq( o1.FindAll("_"), [3, 6, 9] ), TRUE)
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
