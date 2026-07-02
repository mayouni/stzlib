load "../../stzBase.ring"
load "../_narrated.ring"

# The SplitAround family on a string: the pieces AROUND the anchors (the
# anchors vanish); the IB twins extend each piece by one char into the
# adjacent anchor so neighbours share the boundary chars. Multi-substring
# splits merge overlapping occurrences first. Archive block #363.

Scenario("Splitting around a substring")
	Given('"...♥^♥.|.♥^♥..."')
	o1 = new stzString("...♥^♥.|.♥^♥...")
	Then("around the substring",
		ListEq( o1.SplitAround("♥^♥"), [ "...", ".|.", "..." ] ), TRUE)
	Then("... IB shares the boundary hearts",
		ListEq( o1.SplitAroundIB("♥^♥"), [ "...♥", "♥.|.♥", "♥..." ] ), TRUE)
EndScenario()

Scenario("Splitting around positions and sections")
	o1 = new stzString("...♥^♥.|.♥^♥...")
	Then("around one position",
		ListEq( o1.SplitAroundPosition(8), [ "...♥^♥.", ".♥^♥..." ] ), TRUE)
	Then("around many positions",
		ListEq( o1.SplitAroundPositions([ 5, 8, 11 ]), [ "...♥", "♥.", ".♥", "♥..." ] ), TRUE)
	Then("around a section",
		ListEq( o1.SplitAroundSection(5, 11), [ "...♥", "♥..." ] ), TRUE)
	Then("... IB keeps the section edges",
		ListEq( o1.SplitAroundSectionIB(5, 11), [ "...♥^", "^♥..." ] ), TRUE)
	Then("around found sections",
		ListEq( o1.SplitAroundSections( o1.FindZZ("♥^♥") ), [ "...", ".|.", "..." ] ), TRUE)
	Then("... IB",
		ListEq( o1.SplitAroundSectionsIB( o1.FindZZ("♥^♥") ), [ "...♥", "♥.|.♥", "♥..." ] ), TRUE)
EndScenario()

Scenario("Splitting around one or many substrings")
	o1 = new stzString("...♥^♥.|.♥^♥...")
	Then("the SubString spelling",
		ListEq( o1.SplitAroundSubString("♥^♥"), [ "...", ".|.", "..." ] ), TRUE)
	Then("... IB",
		ListEq( o1.SplitAroundSubStringIB("♥^♥"), [ "...♥", "♥.|.♥", "♥..." ] ), TRUE)
	Then("many substrings merge their overlapping occurrences",
		ListEq( o1.SplitAroundSubStrings([ "♥^♥.", ".♥^♥" ]), [ "..", "|", ".." ] ), TRUE)
	Then("... IB",
		ListEq( o1.SplitAroundSubStringsIB([ "♥^♥.", ".♥^♥" ]), [ "...", ".|.", "..." ] ), TRUE)
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
