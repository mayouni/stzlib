load "../../stzBase.ring"
load "../_narrated.ring"

# SHALLOW vs DEEP bounded-by. FindBoundedByZZ / BoundedBy pair each "[" with
# the next "]" (non-nesting), giving the 3 top-level regions. The Deep*
# forms do a proper nested match: each "[" with its matching "]", so the
# outer span [5,17] and the inner [7,9] are both reported -- ordered leaves
# first, then parents. Extracted from stzlisttest.ring, block #315.

Scenario("Shallow bounded-by pairs each open with the next close")
	Given('"---[ [===]---[=] ]--[=]--"')
	o1 = new stzString("---[ [===]---[=] ]--[=]--")
	Then("the 3 shallow regions",
		ListEq( o1.FindBoundedByZZ([ "[", "]" ]), [ [5,9], [15,15], [22,22] ] ), TRUE)
	Then("their substrings",
		ListEq( o1.BoundedBy([ "[", "]" ]), [ " [===", "=", "=" ] ), TRUE)
EndScenario()

Scenario("Deep bounded-by matches the nesting")
	Given('the same string')
	o1 = new stzString("---[ [===]---[=] ]--[=]--")
	Then("leaves first, then the outer span",
		ListEq( o1.DeepFindBoundedByZZ([ "[", "]" ]), [ [7,9], [15,15], [22,22], [5,17] ] ), TRUE)
	Then("their substrings",
		ListEq( o1.DeepBoundedBy([ "[", "]" ]), [ "===", "=", "=", " [===]---[=] " ] ), TRUE)
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
