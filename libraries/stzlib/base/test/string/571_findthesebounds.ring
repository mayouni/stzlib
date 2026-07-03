load "../../stzBase.ring"
load "../_narrated.ring"

# FindTheseBounds: every open/close token's position (flat), its ZZ the
# spans; RemoveTheseBounds strips them all. Archive block #571.

Scenario("Stripping the angle bounds")
	o1 = new stzString("The <<Ring>> programming <<language>> is <<Waooo!>>")
	Then("the token positions",
		ListEq( o1.FindTheseBounds("<<", ">>"), [ 5, 11, 26, 36, 42, 50 ] ), TRUE)
	Then("their spans",
		ListEq( o1.FindTheseBoundsZZ("<<", ">>"),
			[ [5, 6], [11, 12], [26, 27], [36, 37], [42, 43], [50, 51] ] ), TRUE)
	o1.RemoveTheseBounds("<<", ">>")
	Then("the text reads clean", o1.Content(), "The Ring programming language is Waooo!")
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
