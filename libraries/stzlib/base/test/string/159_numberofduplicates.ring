load "../../stzBase.ring"
load "../_narrated.ring"

# NumberOfDuplicates() counts the duplicated SUBSTRINGS; Duplicates() lists them.
# Archive block #159.

Scenario("Counting and listing the duplicated substrings")
	Given('"ring php ringoria"')
	o1 = new stzString("ring php ringoria")
	Then("there are 12 duplicated substrings", o1.NumberOfDuplicates(), 12)
	Then("they are the r/ri/rin/ring... runs and the repeated single chars",
		ListEq( o1.Duplicates(),
			[ "r", "ri", "rin", "ring", "i", "in", "ing", "n", "ng", "g", " ", "p" ] ), TRUE)
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
