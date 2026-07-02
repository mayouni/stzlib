load "../../stzBase.ring"
load "../_narrated.ring"

# Sections vs AntiSections: the substrings AT the spans, and the gap
# substrings around them. (The archive's third #--> value "THREE" was a
# typo -- section [16,18] of the string reads "ONE".) Archive block #364.

Scenario("Sections and their complements")
	Given('"...ONE...TWO...ONE"')
	o1 = new stzString("...ONE...TWO...ONE")
	Then("the section substrings",
		ListEq( o1.Sections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]),
			[ "ONE", "TWO", "ONE" ] ), TRUE)
	Then("the gaps around them",
		ListEq( o1.AntiSections([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ]),
			[ "...", "...", "..." ] ), TRUE)
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
