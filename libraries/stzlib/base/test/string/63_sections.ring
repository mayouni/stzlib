load "../../stzBase.ring"
load "../_narrated.ring"

# Sections(listOfPairs) returns the substrings spanning each [from,to] pair;
# RemoveManySections(listOfPairs) deletes all those spans in one call. Here the
# pairs pick out the runs of "*" fences around three words. Archive block #63.

Scenario("Reading and removing many sections at once")
	Given('"**word1***word2**word3***"')
	o1 = new stzString("**word1***word2**word3***")
	Then("Sections() returns each fenced span",
		ListEq( o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ]), [ "**", "***", "**", "***" ] ), TRUE)

	Given('a fresh "**word1***word2**word3***"')
	o2 = new stzString("**word1***word2**word3***")
	o2.RemoveManySections([ [1,2], [8, 10], [16, 17], [23, 25] ])
	Then("RemoveManySections() strips all the fences", o2.Content(), "word1word2word3")
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
