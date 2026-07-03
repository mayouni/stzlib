load "../../stzBase.ring"
load "../_narrated.ring"

# The unique-sorted views keep each marquer's OWN positions/sections,
# ordered by marquer number. Archive block #628.

Scenario("Unique sorted views")
	o1 = new stzString("My name is #1, my age is #3, and my job is #2. Again: my name is #1!")
	Then("UZ",
		ListEq( o1.MarquersSortedUZ(),
			[ [ "#1", [ 12, 66 ] ], [ "#2", [ 44 ] ], [ "#3", [ 26 ] ] ] ), TRUE)
	Then("UZZ",
		ListEq( o1.MarquersSortedUZZ(),
			[ [ "#1", [ [12, 13], [66, 67] ] ],
			  [ "#2", [ [44, 45] ] ],
			  [ "#3", [ [26, 27] ] ] ] ), TRUE)
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
