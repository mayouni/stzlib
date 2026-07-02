load "../../stzBase.ring"
load "../_narrated.ring"

# FindMany on a stzList, and TheseCharsZ on both a stzString and a stzList:
# each char grouped with ALL its positions. Archive block #396.

Scenario("Finding many chars, string and list alike")
	o1 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
	Then("the list finds both chars' positions",
		ListEq( o1.FindMany([ "♥", "★" ]), [ 2, 4, 6 ] ), TRUE)
	o2 = new stzString("_♥_★_♥_")
	Then("the string groups each char with its positions",
		ListEq( o2.TheseCharsZ([ "♥", "★" ]),
			[ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ] ), TRUE)
	o3 = new stzList([ "_", "♥", "_", "★", "_", "♥" ])
	Then("the list groups the same way",
		ListEq( o3.TheseCharsZ([ "♥", "★" ]),
			[ [ "♥", [ 2, 6 ] ], [ "★", [ 4 ] ] ] ), TRUE)
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
