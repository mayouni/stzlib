load "../../stzBase.ring"
load "../_narrated.ring"

# The Z / ZZ half forms pair each half-substring with its start position (Z) or
# its [from,to] span (ZZ). Archive block #241.

Scenario("The halves of a string, grouped with positions")
	Given('"123456789"')
	o1 = new stzString("123456789")
	Then("FirstHalfZ pairs the first half with its start",
		ListEq( o1.FirstHalfZ(), [ "1234", 1 ] ), TRUE)
	Then("FirstHalfZZ pairs it with its span",
		ListEq( o1.FirstHalfZZ(), [ "1234", [1,4] ] ), TRUE)
	Then("SecondHalfZZ pairs the second half with its span",
		ListEq( o1.SecondHalfZZ(), [ "56789", [5,9] ] ), TRUE)
	Then("HalvesZ groups both with their starts",
		ListEq( o1.HalvesZ(), [ [ "1234", 1 ], [ "56789", 5 ] ] ), TRUE)
	Then("HalvesZZ groups both with their spans",
		ListEq( o1.HalvesZZ(), [ [ "1234", [1,4] ], [ "56789", [5,9] ] ] ), TRUE)
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
