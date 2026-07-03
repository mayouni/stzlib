load "../../stzBase.ring"
load "../_narrated.ring"

# Ranges take [start, COUNT] pairs (the sections' sibling).
# Archive block #543.

Scenario("Star runs by ranges")
	o1 = new stzString("**word1***word2**word3***")
	Then("the star ranges",
		ListEq( o1.Ranges([ [1,2], [8, 3], [16, 2], [23, 3] ]),
			[ "**", "***", "**", "***" ] ), TRUE)
	o1.RemoveRanges([ [1,2], [8, 3], [16, 2], [23, 3] ])
	Then("removing them joins the words", o1.Content(), "word1word2word3")
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
