load "../../stzBase.ring"
load "../_narrated.ring"

# FindAsSections vs FindAsAntiSections: the occurrences' spans and the
# complement spans around them. Archive block #357.

Scenario("Sections and anti-sections")
	Given('"hello ring what a nice ring!"')
	o1 = new stzString("hello ring what a nice ring!")
	Then("the occurrence spans",
		ListEq( o1.FindAsSections( "ring" ), [ [7, 10], [24, 27] ] ), TRUE)
	Then("the complement spans",
		ListEq( o1.FindAsAntiSections("ring"), [ [1, 6], [11, 23], [28, 28] ] ), TRUE)
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
