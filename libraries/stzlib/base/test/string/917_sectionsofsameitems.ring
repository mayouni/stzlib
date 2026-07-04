load "../../stzBase.ring"
load "../_narrated.ring"

# ... and on already-adjacent items the groups read the same.
# Archive block #917.

Scenario("Two families of brackets")
	Then("grouped",
		ListEq( Q([ "[...]", "[...]", "[~~~]", "[~~~]" ]).SectionsOfSameItems(),
		[
			[ "[...]", "[...]" ],
			[ "[~~~]", "[~~~]" ]
		] ), TRUE)
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
