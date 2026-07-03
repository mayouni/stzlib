load "../../stzBase.ring"
load "../_narrated.ring"

# The leading twin of 672: the repeated chars at the string's start.
# Archive block #674.

Scenario("Working the leading part of 000012.456")
	o1 = new stzString("000012.456")
	Then("it has a leading part", o1.HasLeadingSubString(), TRUE)
	Then("four chars long", o1.HowManyLeadingChar(), 4)
	Then("as a string", o1.LeadingSubString(), "0000")
	Then("as a list of chars",
		ListEq( o1.LeadingChars(), [ "0", "0", "0", "0" ] ), TRUE)
	o1.RemoveLeadingChars()
	Then("and removed", o1.Content(), "12.456")
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
