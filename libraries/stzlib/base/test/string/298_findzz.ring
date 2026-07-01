load "../../stzBase.ring"
load "../_narrated.ring"

# FindZZ with a LIST of substrings returns their sections, and
# RemoveSpacesInSections cleans the spaces only inside those spans.
# Archive block #298.

Scenario("Finding many substrings and unspacing their sections")
	Given('"Softanza is an acc  elera tive library f   or Ring."')
	o1 = new stzString("Softanza is an acc  elera tive library f   or Ring.")
	Then("both spaced substrings are located",
		ListEq( o1.FindZZ([ "acc  elera tive", "f   or" ]), [ [16,30], [40,45] ] ), TRUE)
	o1.RemoveSpacesInSections([ [ 16, 30 ], [ 40, 45 ] ])
	Then("the spaces inside those sections vanish",
		o1.Content(), "Softanza is an accelerative library for Ring.")
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
