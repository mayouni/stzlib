load "../../stzBase.ring"
load "../_narrated.ring"

# Sit(:OnSection, :AndHarvest): sit on a section and harvest N chars on
# each side. Archive block #535.

Scenario("Harvesting around nice")
	o1 = new stzString("what a <<nice>>> day!")
	Then("2 before, 3 after",
		ListEq( o1.Sit(
			:OnSection  = [10, 13],
			:AndHarvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
		), [ "<<", ">>>" ] ), TRUE)
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
