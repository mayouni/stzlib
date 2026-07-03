load "../../stzBase.ring"
load "../_narrated.ring"

# CountInSections / FindInSections restrict the search to the given
# sections -- same semantics on strings and lists. Archive block #661.

Scenario("Counting N inside sections of a string")
	o1 = new stzString("...ONE...NONE...SONY...")
	Then("four N's in the three words",
		o1.CountInSections("N", [ [3, 5], [9, 12], [16, 19] ]), 4)
	Then("... at these positions",
		ListEq( o1.FindInSections("N", [ [3, 5], [9, 12], [16, 19] ]),
			[ 5, 10, 12, 19 ] ), TRUE)
EndScenario()

Scenario("The same on the char list")
	o2 = new stzList([
		".", ".", ".", "O", "N", "E", ".", ".", ".",
		"N", "O", "N", "E", ".", ".", ".",
		"S", "O", "N", "Y", ".", ".", "."
	])
	Then("same count",
		o2.CountInSections("N", [ [3, 5], [9, 12], [16, 19] ]), 4)
	Then("same positions",
		ListEq( o2.FindInSections("N", [ [3, 5], [9, 12], [16, 19] ]),
			[ 5, 10, 12, 19 ] ), TRUE)
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
