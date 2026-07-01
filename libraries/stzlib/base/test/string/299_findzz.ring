load "../../stzBase.ring"
load "../_narrated.ring"

# Same pipeline as #298 with three spaced substrings, including one at the
# very start and one running to the end of the string. Archive block #299.

Scenario("Unspacing three found sections")
	Given('"Sof tan za is an acc  elera tive library for Rin g ."')
	o1 = new stzString("Sof tan za is an acc  elera tive library for Rin g .")
	Then("the three spaced substrings are located",
		ListEq( o1.FindZZ([ "Sof tan za", "acc  elera tive", "Rin g ." ]),
			[ [1,10], [18,32], [46,52] ] ), TRUE)
	o1.RemoveSpacesInSections([ [ 1, 10 ], [ 18, 32 ], [ 46, 52 ] ])
	Then("all three sections are unspaced",
		o1.Content(), "Softanza is an accelerative library for Ring.")
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
