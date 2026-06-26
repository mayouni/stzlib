load "../../stzBase.ring"
load "../_narrated.ring"

# Numbers() -- extract the numeric tokens from free text (as strings). Archive #228.

Scenario("Pulling numbers out of messy text")
	Then("'+10,' yields [10]", ListEq( Q("+10,").Numbers(), [ "10" ] ), TRUE)
	Then("'+10,  12;kdjf' yields [10, 12]", ListEq( Q("+10,  12;kdjf").Numbers(), [ "10", "12" ] ), TRUE)
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
