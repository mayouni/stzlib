load "../../stzBase.ring"
load "../_narrated.ring"

# BoundsOf: the FLAT bound runs (left, right) of each occurrence that is
# bounded on both sides. Archive block #589.

Scenario("Mixed bounds around Ring")
	o1 = new stzString("Hello <<<Ring>>, the beautiful ((Ring))!")
	Then("both occurrences' runs, flat",
		ListEq( o1.BoundsOf("Ring"), [ "<<<", ">>", "((", "))" ] ), TRUE)
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
