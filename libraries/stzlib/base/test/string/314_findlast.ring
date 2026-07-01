load "../../stzBase.ring"
load "../_narrated.ring"

# FindLast + its AsSection / Z / ZZ companions -- including the deliberately
# misspelled FindLasteAsSection alias, which Softanza accepts.
# Archive block #314.

Scenario("Last-occurrence finders and groupings")
	Given('"bla {♥♥♥} blaba bla {♥♥♥} blabla"')
	o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")
	Then("FindLast gives the position", o1.FindLast("♥♥♥"), 22)
	Then("the misspelled FindLasteAsSection still answers",
		ListEq( o1.FindLasteAsSection("♥♥♥"), [22, 24] ), TRUE)
	Then("FindLastZ groups [sub, position]",
		ListEq( o1.FindLastZ("♥♥♥"), [ "♥♥♥", 22 ] ), TRUE)
	Then("FindLastZZ groups [sub, span]",
		ListEq( o1.FindLastZZ("♥♥♥"), [ "♥♥♥", [22, 24] ] ), TRUE)
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
