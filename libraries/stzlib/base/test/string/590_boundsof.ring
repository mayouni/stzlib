load "../../stzBase.ring"
load "../_narrated.ring"

# Occurrences at the string edges (one side empty) do not count -- only
# the fully bounded middle one does. Archive block #590.

Scenario("Edge occurrences have no bounds")
	o1 = new stzString("Ring>>, the nice ---Ring---, the beautiful ((Ring")
	Then("only the dashed one counts",
		ListEq( o1.BoundsOf("Ring"), [ "---", "---" ] ), TRUE)
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
