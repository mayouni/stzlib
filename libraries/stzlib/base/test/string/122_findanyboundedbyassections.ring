load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedByAsSections([open, close]) -- the [from,to] spans enclosed
# between each pair of bounds. Archive block #122.

Scenario("Finding the spans enclosed by << >>")
	Given('"<<***>>**<<***>>"')
	o1 = new stzString("<<***>>**<<***>>")
	Then("the two enclosed spans are found",
		ListEq( o1.FindAnyBoundedByAsSections([ "<<", ">>" ]), [ [ 3, 5 ], [ 12, 14 ] ] ), TRUE)
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
