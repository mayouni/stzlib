load "../../stzBase.ring"
load "../_narrated.ring"

# Sectioned() on a list of endpoints: each number closes a section that
# starts right after the previous one. Archive block #419.

Scenario("Endpoints to sections")
	Then("the endpoints become contiguous sections",
		ListEq( QQ([ 4, 8, 10, 14, 16, 18 ]).Sectioned(),
			[ [1, 4], [5, 8], [9, 10], [11, 14], [15, 16], [17, 18] ] ), TRUE)
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
