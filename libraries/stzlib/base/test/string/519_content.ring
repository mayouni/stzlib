load "../../stzBase.ring"
load "../_narrated.ring"

# Swapping two ITEMS by value on a list. Archive block #519.

Scenario("Putting ONE before TWO in a list")
	o1 = new stzList([ "TWO", "ONE", "THREE" ])
	o1.Swap("TWO", :And = "ONE")
	Then("the items traded places",
		ListEq( o1.Content(), [ "ONE", "TWO", "THREE" ] ), TRUE)
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
