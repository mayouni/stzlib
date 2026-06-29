load "../../stzBase.ring"
load "../_narrated.ring"

# ExtractNumbers() pulls the numbers OUT of the string: it reuses the decimal-
# and sign-aware Numbers() (so "17.80" stays one token), returns them as STRINGS,
# and REMOVES them from the content (Extract mutates). Archive block #231.

Scenario("Extracting the numbers out of a string")
	Given('"Math: 18, Geo: 16, :Physics: 17.80"')
	o1 = new stzString("Math: 18, Geo: 16, :Physics: 17.80")
	Then("the numbers come back as strings (decimal kept whole)",
		ListEq( o1.ExtractNumbers(), [ "18", "16", "17.80" ] ), TRUE)
	Then("and they are removed from the content", o1.Content(), "Math: , Geo: , :Physics: ")
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
