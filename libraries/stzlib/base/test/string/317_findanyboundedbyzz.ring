load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedByZZ + SubStringsBoundedByZZ give the 3 SHALLOW top-level
# regions (each "[" paired with the next "]"); the Deep* :BoundedBy forms
# report the proper nested match -- inner [7,9] and the outer span [5,17] --
# each substring paired with its [start, end].
# Extracted from stzlisttest.ring, block #317.

Scenario("Shallow any-bounded-by")
	Given('"---[ [===]---[=] ]--[=]--"')
	o1 = new stzString("---[ [===]---[=] ]--[=]--")
	Then("the 3 shallow spans",
		ListEq( o1.FindAnyBoundedByZZ([ "[", "]" ]), [ [5,9], [15,15], [22,22] ] ), TRUE)
	Then("each substring pairs with its span",
		ListEq( o1.SubStringsBoundedByZZ([ "[", "]" ]),
			[ [ " [===", [5,9] ], [ "=", [15,15] ], [ "=", [22,22] ] ] ), TRUE)
EndScenario()

Scenario("Deep :BoundedBy spelling")
	Given('the same string')
	o1 = new stzString("---[ [===]---[=] ]--[=]--")
	Then("the nested spans, leaves first",
		ListEq( o1.DeepFindSubStringsZZ(:BoundedBy = [ "[", "]" ]),
			[ [7,9], [15,15], [22,22], [5,17] ] ), TRUE)
	Then("each deep substring pairs with its span",
		ListEq( o1.DeepSubStringsZZ(:BoundedBy = [ "[", "]" ]),
			[ [ "===", [7,9] ], [ "=", [15,15] ], [ "=", [22,22] ],
			  [ " [===]---[=] ", [5,17] ] ] ), TRUE)
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
