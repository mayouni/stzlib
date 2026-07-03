load "../../stzBase.ring"
load "../_narrated.ring"

# Sections accepts Ring range literals (1:2) as spans.
# Archive block #557.

Scenario("Sections from ranges")
	o1 = new stzString("12*A*33*A*")
	Then("both number runs",
		ListEq( o1.Sections([ 1:2, 6:7 ]), [ "12", "33" ] ), TRUE)
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
