load "../../stzBase.ring"
load "../_narrated.ring"

# SectionBounds(a, b, m, n) -- the m chars before and n chars after the section
# a..b. The Z / ZZ variants also return each bound's position / [from,to] span.
# Archive block #97.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the ...IB ("inclusive-bounds")
# variants (SectionBoundsIB / IBZ / IBZZ) are off by one -- given the inclusive
# positions (9, 14) they harvest from one char too early ([ " <", ">> " ]) instead
# of matching the plain form ([ "<<", ">>>" ]). Those are left as un-asserted NOTEs.

Scenario("The bounds around a section, plain and located")
	Given('"what a <<nice>>> day!" (nice at 10..13)')
	o1 = new stzString("what a <<nice>>> day!")
	Then("SectionBounds(10,13,2,3) is the surrounding bounds",
		ListEq( o1.SectionBounds(10, 13, 2, 3), [ "<<", ">>>" ] ), TRUE)
	Then("SectionBoundsZ adds each bound's start position",
		ListEq( o1.SectionBoundsZ(10, 13, 2, 3), [ [ "<<", 8 ], [ ">>>", 14 ] ] ), TRUE)
	Then("SectionBoundsZZ adds each bound's [from,to] span",
		ListEq( o1.SectionBoundsZZ(10, 13, 2, 3), [ [ "<<", [ 8, 9 ] ], [ ">>>", [ 14, 16 ] ] ] ), TRUE)
	Then("SectionBoundsIB(9,14,2,3) matches the plain form (inclusive bounds)",
		ListEq( o1.SectionBoundsIB(9, 14, 2, 3), [ "<<", ">>>" ] ), TRUE)
	Then("SectionBoundsIBZZ(9,14,2,3) gives the bound spans",
		ListEq( o1.SectionBoundsIBZZ(9, 14, 2, 3), [ [ "<<", [ 8, 9 ] ], [ ">>>", [ 14, 16 ] ] ] ), TRUE)
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
