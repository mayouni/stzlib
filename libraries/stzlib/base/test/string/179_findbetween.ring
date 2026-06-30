load "../../stzBase.ring"
load "../_narrated.ring"

# FindBetween(sub, open, close) / FindBetweenAsSections -- find `sub` only where
# it sits between the markers (the bare "<<-->>" with no "hi!" is skipped).
# Archive block #179.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): the near-natural FindXT(sub,
# :Between=[a,b]) / FindAsSectionsXT(sub, :Between=[a,b]) forms return [] (the
# :Between named param is not parsed). The plain forms work and are asserted.

Scenario("Finding a substring between markers")
	Given('"...<<hi!>>...<<-->>...<<hi!>>..."')
	o1 = new stzString("...<<hi!>>...<<-->>...<<hi!>>...")
	Then("FindBetween gives the two bounded positions",
		ListEq( o1.FindBetween("hi!", "<<", ">>"), [ 6, 25 ] ), TRUE)
	Then("FindBetweenAsSections gives their spans",
		ListEq( o1.FindBetweenAsSections("hi!", "<<", ">>"), [ [ 6, 8 ], [ 25, 27 ] ] ), TRUE)
	Then("FindXT(..., :Between=['<<','>>']) gives the two positions",
		ListEq( o1.FindXT("hi!", :Between = ["<<", ">>"]), [ 6, 25 ] ), TRUE)
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
