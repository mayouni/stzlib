load "../../stzBase.ring"
load "../_narrated.ring"

# Case-blind finding. Archive block #794.

Scenario("Three texts, any case")
	o1 = new stzString("this text is my text not your text, right?!")
	Then("all three found case-blind",
		ListEq( o1.FindAllCS("text", :CaseSensitive = FALSE),
			[ 6, 17, 31 ] ), TRUE)
	Then("strict Text: nothing",
		o1.FindNthOccurrence(2, "Text"), 0)
	Then("case-blind 2nd: 17",
		o1.FindNthOccurrenceCS(2, "Text", :CaseSensitive = FALSE), 17)
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
