load "../../stzBase.ring"
load "../_narrated.ring"

# FindTrailingChars: the positions of the trailing run; ZZ gives its
# bounds. Archive block #669.

Scenario("Where the trailing zeros sit")
	o1 = new stzString("....00000")
	Then("five positions",
		ListEq( o1.FindTrailingChars(), [ 5, 6, 7, 8, 9 ] ), TRUE)
	Then("as bounds",
		ListEq( o1.FindTrailingCharsZZ(), [ 5, 9 ] ), TRUE)
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
