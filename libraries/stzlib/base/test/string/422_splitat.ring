load "../../stzBase.ring"
load "../_narrated.ring"

# stzSplitter.SplitAt([positions]): the complement spans (the positions
# themselves are dropped). Archive block #422.

Scenario("Splitting a 1..8 range at two positions")
	o1 = new stzSplitter(8)
	Then("the spans between",
		ListEq( o1.SplitAt([3, 5]), [ [1, 2], [4, 4], [6, 8] ] ), TRUE)
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
