load "../../stzBase.ring"
load "../_narrated.ring"

# FindFirst / FindAsSection / AntiFind. Archive block #203.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): AntiFindAsSections("ring") returns
# the SUBSTRINGS [ "...", "..." ] instead of the position sections
# [ [1,3], [8,10] ] -- same as blocks 204/205. The other three forms work.

Scenario("First position, section, and complement of a substring")
	Given('"...ring..."')
	o1 = new stzString("...ring...")
	Then("FindFirst('ring') is 4", o1.FindFirst("ring"), 4)
	Then("FindAsSection('ring') is [4,7]", ListEq( o1.FindAsSection("ring"), [ 4, 7 ] ), TRUE)
	Then("AntiFind('ring') is the complement positions",
		ListEq( o1.AntiFind("ring"), [ 1, 2, 3, 8, 9, 10 ] ), TRUE)
	Then("AntiFindAsSections('ring') gives the complement spans",
		ListEq( o1.AntiFindAsSections("ring"), [ [1,3], [8,10] ] ), TRUE)
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
