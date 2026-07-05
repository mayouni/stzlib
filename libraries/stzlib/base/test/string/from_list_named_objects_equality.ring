load "../../stzBase.ring"
load "../_narrated.ring"

# Named objects can be compared: AreEqual reads their NAMES, so two
# objects sharing a name are equal regardless of their values.
# Extracted from stzlisttest.ring, block #605.

Scenario("Named objects equality")
	obj1 = new stzString(:first  = "Ring")
	obj2 = new stzString(:second = "Python")
	obj3 = new stzString(:first  = "basic")
	Then("all are named", AreNamedObjects([ obj1, obj2, obj3 ]), TRUE)
	Then("their names",
		ListEq( ObjectsNames([ obj1, obj2, obj3 ]),
			[ :first, :second, :first ] ), TRUE)
	Then("different names, not equal", AreEqual([ obj1, obj2 ]), FALSE)
	Then("same name, equal", AreEqual([ obj1, obj3 ]), TRUE)
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
