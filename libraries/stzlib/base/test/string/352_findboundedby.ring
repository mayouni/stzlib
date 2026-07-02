load "../../stzBase.ring"
load "../_narrated.ring"

# FindBoundedBy returns the content START positions of the bounded regions;
# the ZZ form carries their [start, end] spans. Archive block #352.

Scenario("Positions and spans of bounded regions")
	Given('"The range is between {min} and {max}"')
	o1 = new stzString("The range is between {min} and {max}")
	Then("the content start positions",
		ListEq( o1.FindBoundedBy([ "{", "}" ]), [ 23, 33 ] ), TRUE)
	Then("the content spans",
		ListEq( o1.FindBoundedByZZ([ "{", "}" ]), [ [23, 25], [33, 35] ] ), TRUE)
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
