load "../../stzBase.ring"
load "../_narrated.ring"

# RepeatedLeadingChar / RepeatedLeadingChars / LeadingSubString --
# the char, the list, and the string readings of the same run.
# Archive block #766.

Scenario("Three readings of a leading run")
	o1 = new stzString("eeeTUNIS")
	Then("the char", o1.RepeatedLeadingChar(), "e")
	Then("the list",
		ListEq( o1.RepeatedLeadingChars(), [ "e", "e", "e" ] ), TRUE)
	Then("the string", o1.LeadingSubString(), "eee")
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
