load "../../stzBase.ring"
load "../_narrated.ring"

# The directional occurrence selectors: candidates come from the
# backward-ordered FindD / FindStD lists (nearest first), then the indices
# pick. The archive's ":Bakcward" misspelling is tolerated, in the Softanza
# typo-friendly tradition. Archive block #350.

Scenario("Directional occurrence selectors")
	Given('"12♥♥♥67♥♥♥12♥♥♥67" (hearts at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")
	Then("all backward positions",
		ListEq( o1.FindD( :Of = "♥♥♥", :Backward ), [ 13, 8, 3 ] ), TRUE)
	Then("the 1st and 2nd backward",
		ListEq( o1.FindTheseOccurrencesD([ 1, 2], :Of = "♥♥♥", :Backward), [ 13, 8 ] ), TRUE)
	Then("... as sections",
		ListEq( o1.FindTheseOccurrencesAsSectionsD([ 1, 2], :Of = "♥♥♥", :Backward),
			[ [13, 15], [8, 10] ] ), TRUE)
	Then("backward from 12 (misspelled :Bakcward accepted)",
		ListEq( o1.FindTheseOccurrencesSD([ 1, 2], :Of = "♥♥♥", :StartingAt = 12, :Bakcward),
			[ 8, 3 ] ), TRUE)
	Then("... as sections",
		ListEq( o1.FindTheseOccurrencesAsSectionsSTD([ 1, 2], :Of = "♥♥♥", :StartingAt = 12, :Backward),
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
