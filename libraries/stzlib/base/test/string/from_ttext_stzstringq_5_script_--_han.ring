load "../../stzBase.ring"
load "../_narrated.ring"

# Han with trailing digits stays Han; mix in Latin words and it turns
# Hybrid. Extracted from stzTtexttest.ring, block #6.

Scenario("Han, alone and mixed")
	Then("Han with digits is Han",
		StzStringQ("和平 210").Script(), :Han)
	Then("... its scripts",
		ListEq( StzStringQ("和平 210").Scripts(), [ :Han, :Common ] ), TRUE)
	Then("Han plus English is Hybrid",
		StzStringQ("和平 is 'peace' in chineese!").Script(), :Hybrid)
	Then("... its scripts",
		ListEq( StzStringQ("和平 is 'peace' in chineese!").Scripts(),
			[ :Han, :Common, :Latin ] ), TRUE)
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
