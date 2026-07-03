load "../../stzBase.ring"
load "../_narrated.ring"

# Bounds() auto-detects; LeftBound/RightBound name the sides.
# Archive block #592.

Scenario("The bounds of a wrapped word")
	o1 = new stzString("<<word>>")
	Then("both bounds", ListEq( o1.Bounds(), [ "<<", ">>" ] ), TRUE)
	Then("the left one", o1.LeftBound(), "<<")
	Then("the right one", o1.RightBound(), ">>")
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
