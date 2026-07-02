load "../../stzBase.ring"
load "../_narrated.ring"

# The history feature on a LIST chain (RemoveWQ is the W spelling of the
# archive's retired RemoveWXTQ). Archive block #467.

Scenario("A list chain, then its history")
	Then("the cleaned list",
		ListEq( Q([ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ]).
			RemoveWQ('isNumber(@item)').
			RemoveSpacesQ().
			RemoveDuplicatedItemsQ().
			Content(), [ "A", "B", "C", "D" ] ), TRUE)
	Then("the captured steps",
		ListEq( QH([ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ]).
			RemoveWQ('isNumber(@item)').
			RemoveSpacesQ().
			RemoveDuplicatedItemsQ().
			History(),
			[ [ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ],
			  [ " ", " ", "A", "A", "B", "C", "C", "C", "D", "D" ],
			  [ "A", "A", "B", "C", "C", "C", "D", "D" ],
			  [ "A", "B", "C", "D" ] ] ), TRUE)
	DontKeepHistory()
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
