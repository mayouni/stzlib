load "../../stzBase.ring"
load "../_narrated.ring"

# stzList.DuplicatesRemoved: the passive dedup. Archive block #455.

Scenario("Deduplicating a list")
	Then("AAABBC dedups to ABC",
		ListEq( StzListQ([ "A", "A", "A", "B", "B", "C" ]).DuplicatesRemoved(),
			[ "A", "B", "C" ] ), TRUE)
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
