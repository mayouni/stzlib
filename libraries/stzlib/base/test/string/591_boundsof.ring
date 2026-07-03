load "../../stzBase.ring"
load "../_narrated.ring"

# BoundsOf and its First/Last projections. Archive block #591.

Scenario("Three bounded Rings")
	o1 = new stzString("Hello <<<Ring>>, the nice __Ring__ and beautiful ((Ring))!")
	Then("all runs, flat",
		ListEq( o1.BoundsOf("Ring"), [ "<<<", ">>", "__", "__", "((", "))" ] ), TRUE)
	Then("the openers", ListEq( o1.FirstBoundsOf("Ring"), [ "<<<", "__", "((" ] ), TRUE)
	Then("the closers", ListEq( o1.LastBoundsOf("Ring"), [ ">>", "__", "))" ] ), TRUE)
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
