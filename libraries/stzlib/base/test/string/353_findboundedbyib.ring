load "../../stzBase.ring"
load "../_narrated.ring"

# The IB (include-bounds) family: FindBoundedByIB anchors at the openers;
# BoundedByIBZ/IBZZ group each bound-inclusive substring with its position
# / span. Archive block #353.

Scenario("Bound-inclusive positions and groupings")
	Given('"The range is between {min} and {max}"')
	o1 = new stzString("The range is between {min} and {max}")
	Then("the opener positions",
		ListEq( o1.FindBoundedByIB([ "{", "}" ]), [ 22, 32 ] ), TRUE)
	Then("the IBZ grouping",
		ListEq( o1.BoundedByIBZ([ "{", "}" ]),
			[ [ "{min}", 22 ], [ "{max}", 32 ] ] ), TRUE)
	Then("the IBZZ grouping",
		ListEq( o1.BoundedByIBZZ([ "{", "}" ]),
			[ [ "{min}", [22, 26] ], [ "{max}", [32, 36] ] ] ), TRUE)
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
