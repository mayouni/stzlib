load "../../stzBase.ring"
load "../_narrated.ring"

# Numbers() handles signs and decimals, ignoring surrounding noise. Archive #230.

Scenario("Extracting signed and decimal numbers")
	Given('"emm +   12  456.50 emm 11. and -   4.12_"')
	o1 = new stzString("emm +   12  456.50 emm 11. and -   4.12_")
	Then("the four numeric tokens are pulled out",
		ListEq( o1.Numbers(), [ "12", "456.50", "11.", "-4.12" ] ), TRUE)
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
