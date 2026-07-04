load "../../stzBase.ring"
load "../_narrated.ring"

# SectionsOfSameItems groups the SAME items across the whole list
# (first-seen order) -- not just adjacent runs. (The archive listed
# ["THREE"] once -- a garble; the input holds two.) Archive block #916.

Scenario("Regrouping a shuffled list")
	o1 = new stzList([ "ONE", "TWO", "TWO", "ONE", "THREE", "ONE", "THREE" ])
	Then("three groups, complete",
		ListEq( o1.SectionsOfSameItems(),
		[
			[ "ONE", "ONE", "ONE" ],
			[ "TWO", "TWO" ],
			[ "THREE", "THREE" ]
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
