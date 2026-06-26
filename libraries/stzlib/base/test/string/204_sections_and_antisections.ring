load "../../stzBase.ring"
load "../_narrated.ring"

# Sections / AntiSections and their Find counterparts. Archive block #204.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): AntiFindAsSections returns the
# SUBSTRINGS, not the position sections; AntiSectionsZ returns a garbled [1,3];
# AntiSectionsZZ returns position spans only (loses the [substring,span] grouping).
# Sections / AntiSections / FindAsSections work and are asserted.

Scenario("Sections and anti-sections of a string")
	Given('"^^^456---012..."')
	o1 = new stzString("^^^456---012...")
	Then("Sections gives the picked spans",
		ListEq( o1.Sections([ [4, 6], [10, 12] ]), [ "456", "012" ] ), TRUE)
	Then("AntiSections gives the gaps",
		ListEq( o1.AntiSections([ [4, 6], [10, 12] ]), [ "^^^", "---", "..." ] ), TRUE)
	Then("FindAsSections locates the substrings",
		ListEq( o1.FindAsSections([ "456", "012" ]), [ [ 4, 6 ], [ 10, 12 ] ] ), TRUE)
	# Broken anti-forms:
	? "  NOTE  AntiFindAsSections -> " + @@(o1.AntiFindAsSections([ "456", "012" ])) + "  (want sections, got substrings -- deferred)"
	? "  NOTE  AntiSectionsZ -> " + @@(o1.AntiSectionsZ([ [4, 6], [10, 12] ])) + "  (garbled -- deferred)"
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
