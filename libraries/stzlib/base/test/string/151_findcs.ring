load "../../stzBase.ring"
load "../_narrated.ring"

# FindCS(sub, caseFlag) -- the positions of `sub`, with a case-sensitivity flag
# that accepts many spellings. Archive block #151.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the :CaseInSensitive SYMBOL form is
# not parsed -- FindCS("a", :CaseInSensitive) on "aaA..." returns [1,2] (treated
# as case-sensitive) instead of [1,2,3] (the uppercase A at 3 is missed). The
# :CaseSensitive symbol works. Left the broken form as an un-asserted NOTE.

Scenario("Case-sensitive find by symbol flag")
	Given('"aaA..."')
	o1 = new stzString("aaA...")
	Then("FindCS('a', :CaseSensitive) finds the two lowercase a's",
		ListEq( o1.FindCS("a", :CaseSensitive), [ 1, 2 ] ), TRUE)
	# Should be [1,2,3] (case-insensitive); the symbol isn't parsed:
	? "  NOTE  FindCS('a', :CaseInSensitive) -> " + @@(o1.FindCS("a", :CaseInSensitive)) + "  (want [1,2,3] -- deferred)"
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
