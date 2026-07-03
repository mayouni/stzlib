load "../../stzBase.ring"
load "../_narrated.ring"

# FindXT with the :StartingAt and :InSection named filters.
# Archive block #563.

Scenario("Filtered finds")
	o1 = new stzString("my <<word>> and your <<word>>")
	Then("occurrences from position 12",
		ListEq( o1.FindXT("word", :StartingAt = 12), [ 24 ] ), TRUE)
	Then("occurrences inside [3, 10]",
		ListEq( o1.FindXT("word", :InSection = [3, 10]), [ 6 ] ), TRUE)
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
