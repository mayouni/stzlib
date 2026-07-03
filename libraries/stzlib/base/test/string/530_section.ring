load "../../stzBase.ring"
load "../_narrated.ring"

# Section for one span, Sections for many. Archive block #530.

Scenario("The bounds around nice")
	o1 = new stzString("what a <<nice>>> day!")
	Then("the opener", o1.Section(8, 9), "<<")
	Then("the closer", o1.Section(14, 16), ">>>")
	Then("both at once",
		ListEq( o1.Sections([ [8, 9], [14, 16] ]), [ "<<", ">>>" ] ), TRUE)
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
