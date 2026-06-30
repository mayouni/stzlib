load "../../stzBase.ring"
load "../_narrated.ring"

# FindAsSections([sub1, sub2]) -- the [from,to] spans of several substrings (here
# two quoted, space-preserving segments). Archive block #205.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): AntiFindAsSections returns the
# SUBSTRINGS of the gaps instead of their position sections (want [[1,19],[44,66]]).
# Same as blocks 203/204. FindAsSections is asserted.

Scenario("Locating several quoted segments")
	Given('a line with two quoted "< leave spaces >" segments')
	o1 = new stzString('this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"')
	Then("FindAsSections gives both segment spans",
		ListEq( o1.FindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]), [ [ 20, 43 ], [ 67, 84 ] ] ), TRUE)
	Then("AntiFindAsSections gives the complement spans",
		ListEq( o1.AntiFindAsSections([ '"<    leave spaces    >"', '"< leave spaces >"' ]), [ [1,19], [44,66] ] ), TRUE)
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
