load "../../stzBase.ring"
load "../_narrated.ring"

# FindBetween(sub, open, close) / ...AsSections -- find `sub` only where it sits
# between the open/close markers; only the bounded occurrences match (the bare
# "<<-->>" with no "hi!" is skipped). Archive block #161.

Scenario("Finding a substring only between markers")
	Given('"...<<--hi!-->>...<<-->>...<<hi!>>..."')
	o1 = new stzString("...<<--hi!-->>...<<-->>...<<hi!>>...")
	Then("FindBetweenAsSections gives the two bounded spans",
		ListEq( o1.FindBetweenAsSections( "hi!", "<<", ">>" ), [ [ 8, 10 ], [ 29, 31 ] ] ), TRUE)
	Then("FindBetween gives their start positions",
		ListEq( o1.FindBetween( "hi!", "<<", ">>" ), [ 8, 29 ] ), TRUE)
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
