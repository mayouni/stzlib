load "../../stzBase.ring"
load "../_narrated.ring"

# Sit(:AndHarvestSections): the same harvest as spans instead of
# substrings. Archive block #537.

Scenario("Harvesting the spans around nice")
	o1 = new stzString("what a <<nice>>> day!")
	Then("the before/after spans",
		ListEq( o1.Sit(
			:OnSection  = [10, 13],
			:AndHarvestSections = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
		), [ [8, 9], [14, 16] ] ), TRUE)
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
