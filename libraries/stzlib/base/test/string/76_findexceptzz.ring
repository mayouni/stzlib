load "../../stzBase.ring"
load "../_narrated.ring"

# FindExceptZZ(sep) -- the sections (as [from,to] pairs) of everything that is
# NOT the separator. Archive block #76.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md, "Except family"): the companion
# Except(sep) should return the non-separator SUBSTRINGS as a list
# ([ "ring", "&", "softanza" ]) but is broken -- it returns "" (the impl replaces
# the sep with "" and returns a string, not a list). Left as an un-asserted NOTE.

Scenario("Finding the non-separator sections")
	Given('"--ring--&--softanza--"')
	o1 = new stzString("--ring--&--softanza--")
	Then("FindExceptZZ('--') gives the spans between the dashes",
		ListEq( o1.FindExceptZZ("--"), [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ] ), TRUE)
	# Should be [ "ring", "&", "softanza" ]; impl returns "":
	? "  NOTE  Except('--') -> " + @@(o1.Except("--")) + "  (should be the substrings list -- deferred)"
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
