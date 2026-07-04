load "../../stzBase.ring"
load "../_narrated.ring"

# The whole leading-run toolkit, with and without the case dial.
# Archive block #782.

Scenario("Oooo, read both ways")
	o1 = new stzString("Oooo Tunisia---")
	Then("no case-sensitive run", o1.HasLeadingChars(), FALSE)
	Then("... so no leading char", o1.LeadingChar(), "")
	Then("case-blind: there is one", o1.HasLeadingCharsCS(FALSE), TRUE)
	Then("its char", o1.LeadingCharCS(:CS = FALSE), "O")
	Then("empty CS list", len( o1.LeadingChars() ), 0)
	Then("the CI list",
		ListEq( o1.LeadingCharsCS(:CS = FALSE), [ "O", "o", "o", "o" ] ), TRUE)
	Then("the CI run string", o1.LeadingSubStringCS(FALSE), "Oooo")
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
