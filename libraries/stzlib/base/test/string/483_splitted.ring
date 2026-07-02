load "../../stzBase.ring"
load "../_narrated.ring"

# The / operator with a separator keeps EMPTY-free parts of the split.
# Archive block #483.

Scenario("Splitting a dotted string")
	Then("the parts",
		ListEq( Q(".;1;.;.;." ) / ";", [ ".", "1", ".", ".", "." ] ), TRUE)
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
