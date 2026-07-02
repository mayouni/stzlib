load "../../stzBase.ring"
load "../_narrated.ring"

# Spaces are not empty strings: FindEmptyStrings vs FindSpaces on a list.
# Archive block #491.

Scenario("Spaces vs empties")
	o1 = new stzList([ "H", " ", "E", " ", "L", " ", "L", " ", "O" ])
	Then("no empty strings", ListEq( o1.FindEmptyStrings(), [] ), TRUE)
	Then("the spaces sit at even positions",
		ListEq( o1.FindSpaces(), [ 2, 4, 6, 8 ] ), TRUE)
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
