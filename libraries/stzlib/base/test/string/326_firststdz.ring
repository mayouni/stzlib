load "../../stzBase.ring"
load "../_narrated.ring"

# The STDZ forms: direction + the [sub, position] grouping (the archive's
# doubled quote in the 2nd #--> is a typo for the same shape).
# Archive block #326.

Scenario("Backward STDZ groupings")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the first backward from 12",
		ListEq( o1.FirstSTDZ("♥♥♥", :StartingAt = 12, :Backward), [ "♥♥♥", 8 ] ), TRUE)
	Then("the last backward from 12",
		ListEq( o1.LastSTDZ("♥♥♥", :StartingAt = 12, :Backward), [ "♥♥♥", 3 ] ), TRUE)
	Then("the 2nd backward from 12",
		ListEq( o1.NthSTDZ(2, "♥♥♥", :StartingAt = 12, :Backward), [ "♥♥♥", 3 ] ), TRUE)
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
