load "../../stzBase.ring"
load "../_narrated.ring"

# Section(a, b) on a stzList -- the list counterpart of block #18: the items
# spanning positions a..b inclusive, with the bounds auto-ordered the same way.
# Archive block #19. (A list test kept here for the string/list Section parallel.)

Scenario("A list section is bound-order independent")
	Given("new stzList(1:8)")
	o1 = new stzList(1:8)
	Then("Section(3, 5) spans items 3..5", ListEq(o1.Section(3, 5), [ 3, 4, 5 ]), TRUE)
	Then("Section(5, 3) auto-orders to the same span", ListEq(o1.Section(5, 3), [ 3, 4, 5 ]), TRUE)
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
