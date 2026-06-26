load "../../stzBase.ring"
load "../_narrated.ring"

# Finding a substring within a bounded section, returned as [from,to] spans.
# FindSSZZ / FindInSectionZZ / FindBetweenZZ are three names for the same op.
# Archive block #94.

Scenario("Finding a substring inside a section")
	Given('"123♥♥678♥♥123♥♥678" searched in section 7..17')
	o1 = new stzString("123♥♥678♥♥123♥♥678")
	Then("FindSSZZ finds the heart pairs in the section",
		ListEq( o1.FindSSZZ("♥♥", 7, 17), [ [ 9, 10 ], [ 14, 15 ] ] ), TRUE)
	Then("FindInSectionZZ is the same", ListEq( o1.FindInSectionZZ("♥♥", 7, 17), [ [ 9, 10 ], [ 14, 15 ] ] ), TRUE)
	Then("FindBetweenZZ is the same", ListEq( o1.FindBetweenZZ("♥♥", 7, 17), [ [ 9, 10 ], [ 14, 15 ] ] ), TRUE)
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
