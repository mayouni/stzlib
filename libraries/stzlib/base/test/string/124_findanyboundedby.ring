load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedBy / ...AsSections with a SINGLE repeated bound ("aa"). Archive
# block #124.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): FindAnyBoundedBy("aa") should return
# the POSITIONS [3, 8, 12] but returns the SUBSTRINGS [ "***", "***" ] -- wrong
# type AND it pairs the bounds non-overlappingly so the middle region is dropped
# (confirms block #17). The ...AsSections form is correct and IS asserted here.

Scenario("Finding regions bounded by a repeated marker")
	Given('"aa***aa**aa***aa"')
	o1 = new stzString("aa***aa**aa***aa")
	Then("FindAnyBoundedByAsSections('aa') finds all three spans",
		ListEq( o1.FindAnyBoundedByAsSections("aa"), [ [ 3, 5 ], [ 8, 9 ], [ 12, 14 ] ] ), TRUE)
	# Should be the positions [ 3, 8, 12 ]; impl returns substrings + drops the middle:
	? "  NOTE  FindAnyBoundedBy('aa') -> " + @@(o1.FindAnyBoundedBy("aa")) + "  (want positions [3,8,12] -- deferred)"
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
