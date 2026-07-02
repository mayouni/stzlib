load "../../stzBase.ring"
load "../_narrated.ring"

# Repeated(n): a string duplicates into a string, a list into a list of
# copies. Archive block #484.

Scenario("Repeating by type")
	Then("a string repeats into a string", Q("Ring").Repeated(3), "RingRingRing")
	Then("a list repeats into a list of copies",
		ListEq( Q([1,2]).Repeated(3), [ [1,2], [1,2], [1,2] ] ), TRUE)
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
