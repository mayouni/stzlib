load "../../stzBase.ring"
load "../_narrated.ring"

# FindTheseBounds / FindBoundedBy and their ZZ twins.
# Archive block #806.

Scenario("Where the bounds and the bounded sit")
	o1 = new stzString("بسم الله الرّحمن الرّحيم")
	Then("the bounds' positions",
		ListEq( o1.FindTheseBounds("بسم", "الرّحيم"), [ 1, 18 ] ), TRUE)
	Then("the bounded content starts at 4",
		ListEq( o1.FindBoundedBy([ "بسم", "الرّحيم" ]), [ 4 ] ), TRUE)
	Then("bounds as sections",
		ListEq( o1.FindTheseBoundsZZ("بسم", "الرّحيم"),
			[ [ 1, 3 ], [ 18, 24 ] ] ), TRUE)
	Then("bounded as a section",
		ListEq( o1.FindBoundedByZZ([ "بسم", "الرّحيم" ]),
			[ [ 4, 17 ] ] ), TRUE)
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
