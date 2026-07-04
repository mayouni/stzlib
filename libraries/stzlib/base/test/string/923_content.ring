load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceItemsAtPositionsByMany on a list. Archive block #923.

Scenario("Hearts in a language list")
	o1 = new stzList([ "ring", "php", "ring", "ruby", "ring",
		"python", "ring", "csharp", "ring" ])
	o1.ReplaceItemsAtPositionsByMany([ 3, 5, 7 ], [ "♥", "♥♥", "♥♥♥" ])
	Then("three rings became hearts",
		ListEq( o1.Content(),
			[ "ring", "php", "♥", "ruby", "♥♥", "python", "♥♥♥",
			  "csharp", "ring" ] ), TRUE)
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
