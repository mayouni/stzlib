load "../../stzBase.ring"
load "../_narrated.ring"

# A small end-to-end workflow: find a char's positions, replace at those
# positions, then find the resulting runs as sections and remove them. All
# codepoint-aware. Archive block #65.
#
# NOTE: the archive #--> for the first Find was a stale typo
# ([ 2,3,4,8,9,14,15 ]); "1♥♥456♥♥901♥♥4" has hearts at 2,3,7,8,12,13 -- which
# its own later lines confirm. Asserted at the correct positions.

Scenario("Positions -> replace -> sections -> remove")
	Given('"1♥♥456♥♥901♥♥4"')
	o1 = new stzString("1♥♥456♥♥901♥♥4")

	anPos = o1.Find("♥")
	Then("Find('♥') gives the heart positions",
		ListEq( anPos, [ 2, 3, 7, 8, 12, 13 ] ), TRUE)

	o1.ReplaceCharsAtPositions(anPos, :With = "★")
	Then("each heart becomes a star", o1.Content(), "1★★456★★901★★4")

	aSections = o1.FindAsSections("★★")
	Then("the star runs are found as sections",
		ListEq( aSections, [ [ 2, 3 ], [ 7, 8 ], [ 12, 13 ] ] ), TRUE)

	o1.RemoveSections(aSections)
	Then("removing those sections leaves the digits", o1.Content(), "14569014")
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
