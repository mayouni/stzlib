load "../../stzBase.ring"
load "../_narrated.ring"

# Section(a, b) returns the substring a..b inclusive; CharsInSection(a, b) returns
# that same span split into its individual chars. Archive block #32.

Scenario("A section as a substring and as its chars")
	Given('"---ring---"')
	Then("Section(4, 7) is the inner word", Q("---ring---").Section(4, 7), "ring")
	Then("CharsInSection(4, 7) splits it into chars",
		ListEq(Q("---ring---").CharsInSection(4, 7), [ "r", "i", "n", "g" ]), TRUE)
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
