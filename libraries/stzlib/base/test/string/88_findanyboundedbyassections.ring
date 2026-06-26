load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedByAsSections([open, close]) -- the [from,to] spans of the text
# enclosed between each pair of bounds (the content, not the bounds themselves).
# Archive block #88.

Scenario("Finding the spans enclosed by bounds")
	Given('"..<<Hi>>..<<Ring!>>.."')
	o1 = new stzString("..<<Hi>>..<<Ring!>>..")
	Then("the two enclosed spans are found",
		ListEq( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]), [ [ 5, 6 ], [ 13, 17 ] ] ), TRUE)
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
