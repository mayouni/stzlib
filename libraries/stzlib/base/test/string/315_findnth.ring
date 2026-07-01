load "../../stzBase.ring"
load "../_narrated.ring"

# FindNth + its AsSection / Z / ZZ companions on the 2nd occurrence.
# Archive block #315.

Scenario("Nth-occurrence finders and groupings")
	Given('"bla {♥♥♥} blaba bla {♥♥♥} blabla"')
	o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")
	Then("FindNth(2) gives the position", o1.FindNth(2, "♥♥♥"), 22)
	Then("FindNthAsSection gives the span",
		ListEq( o1.FindNthAsSection(2, "♥♥♥"), [22, 24] ), TRUE)
	Then("NthZ groups [sub, position]",
		ListEq( o1.NthZ(2, "♥♥♥"), [ "♥♥♥", 22 ] ), TRUE)
	Then("FindNthZZ groups [sub, span]",
		ListEq( o1.FindNthZZ(2, "♥♥♥"), [ "♥♥♥", [22, 24] ] ), TRUE)
	Then("FindNthZ / NthZZ aliases agree",
		ListEq( o1.FindNthZ(2, "♥♥♥"), [ "♥♥♥", 22 ] ) and
		ListEq( o1.NthZZ(2, "♥♥♥"), [ "♥♥♥", [22, 24] ] ), TRUE)
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
