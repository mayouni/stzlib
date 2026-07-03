load "../../stzBase.ring"
load "../_narrated.ring"

# LeadingSubString and its ZZ twin. Archive block #675.

Scenario("The leading run, with its whereabouts")
	o1 = new stzString("00012.456")
	Then("the run", o1.LeadingSubString(), "000")
	Then("zipped with its section",
		ListEq( o1.LeadingSubStringZZ(), [ "000", [ 1, 3 ] ] ), TRUE)
	o1.RemoveLeadingSubString()
	Then("removed", o1.Content(), "12.456")
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
