load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedByUZ / BoundedByUZZ group the UNIQUE bounded substrings with their
# positions: UZ pairs each unique substring with its START positions, UZZ with
# its full [from,to] spans. Archive block #163.

Scenario("Unique bounded substrings grouped with their positions")
	Given('"__<<teeba>>__<<rined>>__<<teeba>>"')
	o1 = new stzString("__<<teeba>>__<<rined>>__<<teeba>>")
	Then("UZ pairs each unique substring with its start positions",
		ListEq( o1.BoundedByUZ([ "<<", ">>" ]), [ [ "teeba", [5,27] ], [ "rined", [16] ] ] ), TRUE)
	Then("UZZ pairs each unique substring with its spans",
		ListEq( o1.BoundedByUZZ([ "<<", ">>" ]),
			[ [ "teeba", [ [5,9],[27,31] ] ], [ "rined", [ [16,20] ] ] ] ), TRUE)
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
