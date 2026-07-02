load "../../stzBase.ring"
load "../_narrated.ring"

# FindFirstAsSection and its ST (starting-at) twin. Archive block #329.

Scenario("First occurrence as a section")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the very first section",
		ListEq( o1.FindFirstAsSection("♥♥♥"), [3, 5] ), TRUE)
	Then("the first section from position 5",
		ListEq( o1.FindFirstAsSectionST("♥♥♥", :StartingAt = 5), [8, 10] ), TRUE)
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
