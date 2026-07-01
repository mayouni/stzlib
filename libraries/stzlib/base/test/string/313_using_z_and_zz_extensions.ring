load "../../stzBase.ring"
load "../_narrated.ring"

# The ..Z() / ..ZZ() extensions on the single-occurrence finders: Z groups
# the substring with its POSITION, ZZ with its [start, end] SECTION.
# Archive block #313.

Scenario("First-occurrence Z and ZZ groupings")
	Given('"bla {♥♥♥} blaba bla {♥♥♥} blabla"')
	o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")
	Then("FindFirst gives the position", o1.FindFirst("♥♥♥"), 6)
	Then("FindFirstAsSection gives the span",
		ListEq( o1.FindFirstAsSection("♥♥♥"), [6, 8] ), TRUE)
	Then("FirstZ groups [sub, position]",
		ListEq( o1.FirstZ("♥♥♥"), [ "♥♥♥", 6 ] ), TRUE)
	Then("FirstZZ groups [sub, span]",
		ListEq( o1.FirstZZ("♥♥♥"), [ "♥♥♥", [6, 8] ] ), TRUE)
	Then("FindFirstZ is the same as FirstZ",
		ListEq( o1.FindFirstZ("♥♥♥"), [ "♥♥♥", 6 ] ), TRUE)
	Then("FindFirstZZ is the same as FirstZZ",
		ListEq( o1.FindFirstZZ("♥♥♥"), [ "♥♥♥", [6, 8] ] ), TRUE)
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
