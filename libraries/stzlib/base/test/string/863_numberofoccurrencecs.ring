load "../../stzBase.ring"
load "../_narrated.ring"

# Counting and walking occurrences. FindPreviousNth counts STRICTLY
# BEFORE :StartingAt (the ORIGINAL scans Section(1, nStart - 1); this
# block's archive line said 9 for the 2nd previous from 12, which
# contradicts the original impl and block #989 -- re-ruled to 0).
# Archive block #863.

Scenario("Two ats in a constraint string")
	o1 = new stzString("MustHave@32@Chars")
	Then("two of them",
		o1.NumberOfOccurrenceCS(:Of = "@", TRUE), 2)
	Then("at 9 and 12",
		ListEq( o1.FindAll("@"), [ 9, 12 ] ), TRUE)
	Then("next from 5", o1.FindNext("@", :StartingAt = 5), 9)
	Then("2nd next from 5",
		o1.FindNextNth(2, "@", :StartingAt = 5), 12)
	Then("previous from 10",
		o1.FindPrevious("@", :StartingAt = 10), 9)
	Then("only one @ sits strictly before 12",
		o1.FindPreviousNth(2, "@", :StartingAt = 12), 0)
	Then("... the 1st previous is it",
		o1.FindPreviousNth(1, "@", :StartingAt = 12), 9)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if aA[i] != aE[i] return FALSE ok
	next
	return TRUE
