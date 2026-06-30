load "../../stzBase.ring"
load "../_narrated.ring"

# FindBetween / FindBetweenAsSections again, with multi-char content between the
# markers. Archive block #180.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the near-natural FindXT(sub,
# :Between=["<<", :And=">>"]) / FindAsSectionsXT forms return [] (the :Between
# named param, even with the :And spelling, is not parsed). The plain forms work.

Scenario("Finding a substring between markers (multi-char gaps)")
	Given('"...<<--hi!-->>...<<-->>...<<hi!>>..."')
	o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
	Then("FindBetween gives the two bounded positions",
		ListEq( o1.FindBetween("hi!", "<<", ">>"), [ 8, 29 ] ), TRUE)
	Then("FindBetweenAsSections gives their spans",
		ListEq( o1.FindBetweenAsSections("hi!", "<<", ">>"), [ [ 8, 10 ], [ 29, 31 ] ] ), TRUE)
	Then("FindXT(..., :Between=['<<',:And='>>']) gives the two positions",
		ListEq( o1.FindXT("hi!", :Between = ["<<", :And = ">>"]), [ 8, 29 ] ), TRUE)
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
