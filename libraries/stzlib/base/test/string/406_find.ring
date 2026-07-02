load "../../stzBase.ring"
load "../_narrated.ring"

# Find gives the positions, FindZZ the [start, end] spans.
# Archive block #406.

Scenario("Finding dots")
	Given('"... ____ ... ____"')
	o1 = new stzString("... ____ ... ____")
	Then("the positions", ListEq( o1.Find("..."), [ 1, 10 ] ), TRUE)
	Then("the spans", ListEq( o1.FindZZ("..."), [ [1, 3], [10, 12] ] ), TRUE)
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
