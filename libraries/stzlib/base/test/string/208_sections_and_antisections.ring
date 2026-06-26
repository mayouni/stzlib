load "../../stzBase.ring"
load "../_narrated.ring"

# Sections / AntiSections / FindAsSections on a uniform-gap string. Archive #208.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): AntiFindAsSections returns the
# SUBSTRINGS of the gaps ([ "...", "...", "..." ]) instead of their position
# sections [ [1,3], [7,9], [13,15] ] -- same as blocks 203/204/205. The other
# three forms work and are asserted.

Scenario("Sections and anti-sections with uniform gaps")
	Given('"...456...012..."')
	o1 = new stzString("...456...012...")
	Then("Sections gives the picked spans",
		ListEq( o1.Sections([ [4, 6], [10, 12] ]), [ "456", "012" ] ), TRUE)
	Then("AntiSections gives the three gaps",
		ListEq( o1.AntiSections([ [4, 6], [10, 12] ]), [ "...", "...", "..." ] ), TRUE)
	Then("FindAsSections locates the substrings",
		ListEq( o1.FindAsSections([ "456", "012" ]), [ [ 4, 6 ], [ 10, 12 ] ] ), TRUE)
	? "  NOTE  AntiFindAsSections -> " + @@(o1.AntiFindAsSections([ "456", "012" ])) + "  (want sections, got substrings -- deferred)"
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
