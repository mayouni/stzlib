load "../../stzBase.ring"
load "../_narrated.ring"

# The find quartet (All/Nth/First/Last) plus the sections form.
# Archive block #556.

Scenario("Four stars")
	o1 = new stzString("12*A*33*A*")
	Then("all", ListEq( o1.FindAll("*"), [3, 5, 8, 10] ), TRUE)
	Then("the 3rd", o1.FindNth(3, "*"), 8)
	Then("the first", o1.FindFirst("*"), 3)
	Then("the last", o1.FindLast("*"), 10)
	Then("as sections",
		ListEq( o1.FindAsSections("*"),
			[ [3, 3], [5, 5], [8, 8], [10, 10] ] ), TRUE)
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
