load "../../stzBase.ring"
load "../_narrated.ring"

# More SubStringBoundsXT shapes: full runs, asymmetric caps, and
# multiple occurrences flattened in order. Archive block #534.

Scenario("Capped bounds in three settings")
	o1 = new stzString("what a <<<nice>>> day!")
	Then("the full triple runs",
		ListEq( o1.SubStringBoundsXT(:Of = "nice", :UpToNChars = 3),
			[ "<<<", ">>>" ] ), TRUE)
	o2 = new stzString("what a <nice>>> day!")
	Then("asymmetric [1,3]",
		ListEq( o2.SubStringBoundsXT(:Of = "nice", :UpToNChars = [1, 3]),
			[ "<", ">>>" ] ), TRUE)
	o3 = new stzString("what a <<nice>>> day! Really <nice>>.")
	Then("two occurrences flatten in order",
		ListEq( o3.SubStringBoundsXT(:Of = "nice", :UpToNChars = [ 2, 3 ]),
			[ "<<", ">>>", "<", ">>" ] ), TRUE)
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
