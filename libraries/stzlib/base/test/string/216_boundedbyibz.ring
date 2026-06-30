load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedByIBZ / BoundedByIBZZ widen the single "&" bound and pair each include-
# bounds substring with its start / span -- overlapping, so every gap region is
# kept. (The archive's 2-element #--> was the inconsistent alternating reading;
# all the sibling forms in blocks 213/215 keep every gap.) Archive block #216.

Scenario("Include-bounds substrings grouped with positions, single & bound")
	Given('"...&^^^&...&vvv&...&..."')
	o1 = new stzString("...&^^^&...&vvv&...&...")
	Then("BoundedByIBZ pairs each IB substring with its start",
		ListEq( o1.BoundedByIBZ("&"),
			[ [ "&^^^&", 4 ], [ "&...&", 8 ], [ "&vvv&", 12 ], [ "&...&", 16 ] ] ), TRUE)
	Then("BoundedByIBZZ pairs each IB substring with its span",
		ListEq( o1.BoundedByIBZZ("&"),
			[ [ "&^^^&", [4,8] ], [ "&...&", [8,12] ], [ "&vvv&", [12,16] ], [ "&...&", [16,20] ] ] ), TRUE)
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
