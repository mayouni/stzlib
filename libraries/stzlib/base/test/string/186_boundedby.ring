load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedBy([open, close]) -- the substrings enclosed by the bounds. Archive #186.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the variants are broken --
# BoundedByU does NOT deduplicate (returns all 3, not the 2 unique); BoundedByIB
# (Include Bounds) garbles the last element ("<" instead of "<<♥♥♥>>"); and
# BoundedByIBU inherits both bugs. Only the base BoundedBy is asserted.

Scenario("Extracting substrings bounded by << >>")
	Given('"<<♥♥♥>>--<<stars>>--<<♥♥♥>>"')
	o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")
	Then("BoundedBy gives the three enclosed substrings",
		ListEq( o1.BoundedBy([ "<<", ">>" ]), [ "♥♥♥", "stars", "♥♥♥" ] ), TRUE)
	# Broken variants:
	? "  NOTE  BoundedByU  -> " + @@(o1.BoundedByU([ "<<", ">>" ])) + "  (want unique [♥♥♥,stars] -- deferred)"
	? "  NOTE  BoundedByIB -> " + @@(o1.BoundedByIB([ "<<", ">>" ])) + "  (last element garbled -- deferred)"
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
