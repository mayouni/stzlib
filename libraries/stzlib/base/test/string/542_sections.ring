load "../../stzBase.ring"
load "../_narrated.ring"

# Sections extracts many spans at once; RemoveSections drops them.
# Archive block #542.

Scenario("Star runs between words")
	o1 = new stzString("**word1***word2**word3***")
	Then("the star sections",
		ListEq( o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ]),
			[ "**", "***", "**", "***" ] ), TRUE)
	o1.RemoveSections([ [1,2], [8, 10], [16, 17], [23, 25] ])
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
