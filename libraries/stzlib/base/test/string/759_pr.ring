load "../../stzBase.ring"
load "../_narrated.ring"

# / divides the string into N parts; % gives the remainder part (the
# last, unequal one). Archive block #759.

Scenario("Dividing seven chars by two")
	o1 = new stzString("abcdefj")
	Then("two parts",
		ListEq( o1 / 2, [ "abcd", "efj" ] ), TRUE)
	Then("the remainder part", o1 % 2, "efj")
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
