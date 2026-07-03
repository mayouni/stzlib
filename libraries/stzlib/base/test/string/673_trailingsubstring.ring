load "../../stzBase.ring"
load "../_narrated.ring"

# TrailingSubString and its ZZ twin (run zipped with its section).
# Archive block #673.

Scenario("The trailing run, with its whereabouts")
	o1 = new stzString("12.4560000")
	Then("the run", o1.TrailingSubString(), "0000")
	Then("zipped with its section",
		ListEq( o1.TrailingSubStringZZ(), [ "0000", [ 7, 10 ] ] ), TRUE)
	o1.RemoveTrailingSubString()
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
