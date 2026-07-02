load "../../stzBase.ring"
load "../_narrated.ring"

# The occurrence-index selectors: FindOccurrences([indices], :Of = sub) and
# the FindTheseOccurrences family, incl. the ZZ span form and the ST
# starting-at form (candidates are renumbered from :StartingAt).
# NOTE: the archive #--> of the two ST lines listed ALL THREE occurrences
# for the 2-index selector [2,3] -- incoherent with the selectors above
# them; asserted at the coherent renumber-then-pick reading ([8,13]).
# Archive block #349.

Scenario("Selecting occurrences by index")
	Given('"12♥♥♥67♥♥♥12♥♥♥67" (hearts at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥67")
	Then("occurrences 2 and 3",
		ListEq( o1.FindOccurrences( [ 2, 3 ], :Of = "♥♥♥" ), [ 8, 13 ] ), TRUE)
	Then("FindTheseOccurrences agrees",
		ListEq( o1.FindTheseOccurrences([ 2, 3], :Of = "♥♥♥"), [ 8, 13 ] ), TRUE)
	Then("the ZZ form gives their spans",
		ListEq( o1.FindTheseOccurrencesZZ([ 2, 3], :Of = "♥♥♥"),
			[ [8, 10], [13, 15] ] ), TRUE)
	Then("the ST form renumbers from :StartingAt then picks",
		ListEq( o1.FindTheseOccurrencesST([ 2, 3], :Of = "♥♥♥", :StartingAt = 2),
			[ 8, 13 ] ), TRUE)
	Then("... and its ZZ twin",
		ListEq( o1.FindTheseOccurrencesSTZZ([ 2, 3], :Of = "♥♥♥", :StartingAt = 2),
			[ [8, 10], [13, 15] ] ), TRUE)
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
