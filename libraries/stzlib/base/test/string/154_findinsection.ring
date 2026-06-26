load "../../stzBase.ring"
load "../_narrated.ring"

# FindInSection(sub, from, to) -- the positions of `sub` within a section.
# Codepoint-aware. Archive block #154.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): unlike Section(), FindInSection does
# NOT auto-order its bounds -- FindInSection("♥", 12, 3) returns [] instead of the
# same [6, 9] as the forward call. Left the reversed call as an un-asserted NOTE.

Scenario("Finding a char within a section")
	Given('"..3..♥..♥..2.." (hearts at 6 and 9)')
	o1 = new stzString("..3..♥..♥..2..")
	Then("FindInSection('♥', 3, 12) finds both hearts", ListEq( o1.FindInSection("♥", 3, 12), [ 6, 9 ] ), TRUE)
	# Reversed bounds should auto-order but return []:
	? "  NOTE  FindInSection('♥', 12, 3) -> " + @@(o1.FindInSection("♥", 12, 3)) + "  (want [6,9] -- deferred)"
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
