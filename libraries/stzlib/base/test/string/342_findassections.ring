load "../../stzBase.ring"
load "../_narrated.ring"

# FindAsSections lists the occurrences' spans; FindAsAntiSections the
# COMPLEMENT spans (the gaps around them); and ContainsXT(:SubString =,
# :BoundedBy =) checks a substring occurs inside a bounded region.
# Archive block #342.

Scenario("Sections, anti-sections, and a bounded containment check")
	Given('"*aa***aa**aa***aa*"')
	o1 = new stzString("*aa***aa**aa***aa*")
	Then("the occurrence spans",
		ListEq( o1.FindAsSections("aa"),
			[ [2, 3], [7, 8], [11, 12], [16, 17] ] ), TRUE)
	Then("the complement spans",
		ListEq( o1.FindAsAntiSections("aa"),
			[ [1, 1], [4, 6], [9, 10], [13, 15], [18, 18] ] ), TRUE)
	Then("'***' occurs bounded by 'aa'",
		o1.ContainsXT( :SubString = "***", :BoundedBy = "aa"), TRUE)
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
