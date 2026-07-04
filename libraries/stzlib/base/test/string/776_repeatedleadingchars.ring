load "../../stzBase.ring"
load "../_narrated.ring"

# A two-char run is still a run. Archive block #776.

Scenario("bb leads the way")
	o1 = new stzString("bbxeTuniseee")
	Then("the chars",
		ListEq( o1.RepeatedLeadingChars(), [ "b", "b" ] ), TRUE)
	Then("the string", o1.LeadingSubString(), "bb")
	Then("it counts as repeated", o1.HasRepeatedLeadingChars(), TRUE)
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
