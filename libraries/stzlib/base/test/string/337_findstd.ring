load "../../stzBase.ring"
load "../_narrated.ring"

# FindSTD family: :StartingAt + direction, listing ALL candidates. Going
# :Backward the candidates are the occurrences ENDING at or before the
# start position, nearest first. NOTE: the archive #--> of this block's
# first two lines pasted FORWARD values into the backward calls ([8,13]
# from position 6 going backward is impossible -- only [3,5] ends by 6);
# asserted at the coherent rule pinned by sibling blocks #325-#328, whose
# from-12 values the block's own last two lines agree with.
# Archive block #337.

Scenario("Directional starting-at list finders")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("backward from 6 only the first occurrence fits",
		ListEq( o1.FindSTD( "♥♥♥", :StartingAt = 6, :Backward ), [ 3 ] ), TRUE)
	Then("FindSTDZ groups the sub with those positions",
		ListEq( o1.FindSTDZ( "♥♥♥", :StartingAt = 6, :Backward ), [ "♥♥♥", [ 3 ] ] ), TRUE)
	Then("backward from 12, the sections nearest first",
		ListEq( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 12, :Backward),
			[ [8, 10], [3, 5] ] ), TRUE)
	Then("FindSTDZZ is the same span list",
		ListEq( o1.FindSTDZZ( "♥♥♥", :StartingAt = 12, :Backward ),
			[ [8, 10], [3, 5] ] ), TRUE)
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
