load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedBy vs Between. Archive block #226 (the source is a #TODO exploring the
# intended distinction).
#
# SEMANTICS TO CONFIRM (deferred -- see _AUDIT_DEFECTS.md): the archive expected
# Between("<<<", ">>>") to return the GREEDY span between the first open and the
# last close as one string ("ring>>>___<<<softanza"), but the impl returns the
# same enclosed-substring LIST as BoundedBy. Decide whether positional Between is
# meant to be the greedy single span. BoundedBy is asserted.

Scenario("Substrings bounded by <<< >>>")
	Given('"___<<<ring>>>___<<<softanza>>>___"')
	o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
	Then("BoundedBy gives the two enclosed substrings",
		ListEq( o1.BoundedBy([ "<<<", ">>>" ]), [ "ring", "softanza" ] ), TRUE)
	# Between currently returns the same list, not the greedy span:
	? "  NOTE  Between('<<<','>>>') -> " + @@(o1.Between("<<<", ">>>")) + "  (archive wanted the greedy span string -- deferred)"
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
