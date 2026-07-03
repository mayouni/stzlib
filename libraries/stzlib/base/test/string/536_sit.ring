load "../../stzBase.ring"
load "../_narrated.ring"

# Sit(:OnPosition): sit on a single char and harvest around it.
# Archive block #536.

Scenario("Harvesting around the i of nice")
	o1 = new stzString("what a <<nice>>> day!")
	Then("1 before, 2 after",
		ListEq( o1.Sit(
			:OnPosition = 11,
			:AndHarvest = [ :NCharsBefore = 1, :NCharsAfter = 2 ]
		), [ "n", "ce" ] ), TRUE)
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
