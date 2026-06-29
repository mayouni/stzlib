load "../../stzBase.ring"
load "../_narrated.ring"

# TheseBoundsRemoved strips known bounds; Bounds() auto-detects them (the
# leading/trailing run of the same bound char) so BoundsRemoved() can strip
# them for you -- without swallowing trailing content like "!". Archive #45.

Scenario("Removing bounds, known and auto-detected")
	Given('"<<Go!>>"')
	o1 = new stzString("<<Go!>>")
	Then("TheseBoundsRemoved strips the given bounds", o1.TheseBoundsRemoved("<<", ">>"), "Go!")
	Then("Bounds auto-detects << and >> (the ! stays content)",
		ListEq( o1.Bounds(), [ "<<", ">>" ] ), TRUE)
	Then("BoundsRemoved strips the auto-detected bounds", o1.BoundsRemoved(), "Go!")
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
