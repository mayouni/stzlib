load "../../stzBase.ring"
load "../_narrated.ring"

# A find-and-split tour of one sentence. (SplitToPartsOfNChars is the
# EXACT form per block #414's own ruling; the kept-remainder variant
# asserted here is the XT form.) Archive block #762.

Scenario("Finding and splitting a tutorial sentence")
	o1 = new stzString("What a tutorial! Very instructive tutorial.")
	Then("both tutorials found",
		ListEq( o1.FindAll("tutorial"), [ 8, 35 ] ), TRUE)
	Then("counted", o1.NumberOfOccurrence("tutorial"), 2)
	Then("the next after 20",
		o1.FindNextOccurrence("tutorial", :StartingAt = 20), 35)
	Then("the previous before 20",
		o1.FindPreviousOccurrence("tutorial", :StartingAt = 20), 8)
	Then("43 chars in all", o1.NumberOfChars(), 43)
	Then("12-char pieces, remainder kept (XT)",
		ListEq( o1.SplitToPartsOfNCharsXT(12),
			[ "What a tutor", "ial! Very in", "structive tu", "torial." ] ), TRUE)
	Then("split before positions",
		ListEq( o1.SplitBeforePositions([ 17, 34 ]),
			[ "What a tutorial!", " Very instructive", " tutorial." ] ), TRUE)
	Then("split before each a",
		ListEq( o1.SplitBeforeCharsW(' @char = "a" '),
			[ "Wh", "at ", "a tutori", "al! Very instructive tutori", "al." ] ), TRUE)
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
