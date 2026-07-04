load "../../stzBase.ring"
load "../_narrated.ring"

# The full repeated-run toolkit, both ends. Archive block #768.

Scenario("Runs at both ends of TUNISIA")
	o1 = new stzString("eeeeTUNISIAiiiii")
	Then("leading run exists", o1.HasRepeatedLeadingChars(), TRUE)
	Then("of four chars", o1.NumberOfRepeatedLeadingChars(), 4)
	Then("the chars",
		ListEq( o1.RepeatedLeadingchars(), [ "e", "e", "e", "e" ] ), TRUE)
	Then("as a string", o1.LeadingSubString(), "eeee")
	Then("trailing run exists", o1.HasRepeatedTrailingChars(), TRUE)
	Then("of five chars", o1.NumberOfRepeatedTrailingChars(), 5)
	Then("the chars",
		ListEq( o1.RepeatedTrailingChars(), [ "i", "i", "i", "i", "i" ] ), TRUE)
	Then("as a string", o1.TrailingSubString(), "iiiii")
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
