load "../../stzBase.ring"
load "../_narrated.ring"

# SplitAroundSections on a stzSplitter (complement spans) and on a
# stzString (complement substrings); the IB forms extend each piece to
# INCLUDE the adjacent section bounds, so neighbours share the boundary
# chars ("...♥", "♥..♥", "♥.."). The splitter IB line has no archive
# #-->; asserted at the spans matching the string IB pieces.
# Archive block #360.

Scenario("Splitting a range around sections")
	Given('a stzSplitter(10) and sections [4,5] + [8,8]')
	o1 = new stzSplitter(10)
	Then("the complement spans",
		ListEq( o1.SplitAroundSections([ [4, 5], [ 8, 8] ]),
			[ [1, 3], [6, 7], [9, 10] ] ), TRUE)
	Then("the IB spans include the section bounds",
		ListEq( o1.SplitAroundSectionsIB([ [4, 5], [ 8, 8] ]),
			[ [1, 4], [5, 8], [8, 10] ] ), TRUE)
EndScenario()

Scenario("Splitting a string around sections")
	Given('"...♥♥..♥.."')
	o1 = new stzString("...♥♥..♥..")
	Then("the complement pieces",
		ListEq( o1.SplitAroundSections([ [ 4, 5], [8,8] ]), [ "...", "..", ".." ] ), TRUE)
	Then("the IB pieces share the boundary hearts",
		ListEq( o1.SplitAroundSectionsIB([ [ 4, 5], [8,8] ]),
			[ "...♥", "♥..♥", "♥.." ] ), TRUE)
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
