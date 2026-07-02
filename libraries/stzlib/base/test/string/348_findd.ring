load "../../stzBase.ring"
load "../_narrated.ring"

# The D and STD list finders in both directions: forward keeps document
# order, backward lists nearest-first; the STD forms restrict to
# candidates from :StartingAt (backward = ending at/before it).
# Archive block #348.

Scenario("Directional list finders")
	Given('"12♥♥♥67♥♥♥12♥♥♥67" (hearts at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")
	Then("forward positions",
		ListEq( o1.FindD("♥♥♥", :Forward), [ 3, 8, 13 ] ), TRUE)
	Then("forward sections",
		ListEq( o1.FindAsSectionsD("♥♥♥", :Forward),
			[ [3, 5], [8, 10], [13, 15] ] ), TRUE)
	Then("backward positions",
		ListEq( o1.FindD("♥♥♥", :Backward), [ 13, 8, 3 ] ), TRUE)
	Then("backward sections",
		ListEq( o1.FindAsSectionsD("♥♥♥", :Backward),
			[ [13, 15], [8, 10], [3, 5] ] ), TRUE)
	Then("forward from 6",
		ListEq( o1.FindSTD("♥♥♥", :StartingAt = 6, :Forward), [ 8, 13 ] ), TRUE)
	Then("... and its sections",
		ListEq( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 6, :Forward),
			[ [8, 10], [13, 15] ] ), TRUE)
	Then("backward from 14",
		ListEq( o1.FindSTD("♥♥♥", :StartingAt = 14, :Backward), [ 8, 3 ] ), TRUE)
	Then("... and its sections",
		ListEq( o1.FindAsSectionsSTD("♥♥♥", :StartingAt = 14, :Backward),
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
