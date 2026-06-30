load "../../stzBase.ring"
load "../_narrated.ring"

# FindAsSection / AntiFindAsSection -- the [from,to] span of a substring, and of
# the complement. Archive block #200.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): AntiFindAsSection("ring") on
# "ring..." returns [] instead of the complement span [5,7]. (Part of the broken
# Anti*AsSection(s) family -- blocks 203/204/205.) FindAsSection is asserted.

Scenario("The section of a substring vs its complement")
	Given('"ring..."')
	o1 = new stzString("ring...")
	Then("FindAsSection('ring') is [1,4]", ListEq( o1.FindAsSection("ring"), [ 1, 4 ] ), TRUE)
	Then("AntiFindAsSection('ring') is the complement span [5,7]",
		ListEq( o1.AntiFindAsSection("ring"), [ 5, 7 ] ), TRUE)
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
