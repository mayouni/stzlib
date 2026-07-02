load "../../stzBase.ring"
load "../_narrated.ring"

# stzList.Combinations() defaults to the pairwise combinations.
# Archive block #493.

Scenario("Pairs from VTMS")
	o1 = new stzList([ "V", "T", "M", "S" ])
	Then("the 6 pairs",
		ListEq( o1.Combinations(),
			[ [ "V", "T" ], [ "V", "M" ], [ "V", "S" ],
			  [ "T", "M" ], [ "T", "S" ], [ "M", "S" ] ] ), TRUE)
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
