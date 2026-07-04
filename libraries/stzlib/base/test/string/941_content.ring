load "../../stzBase.ring"
load "../_narrated.ring"

# List InsertAfterPositions -- no trailing insert after the final
# item. Archive block #941.

Scenario("Tildes after every second letter")
	o1 = new stzList( @Chars("SOFTANZA") )
	o1.InsertAfterPositions([ 2, 4, 6, 8 ], "~")
	Then("three tildes, none at the end",
		ListEq( o1.Content(),
			[ "S", "O", "~", "F", "T", "~", "A", "N", "~", "Z", "A" ] ), TRUE)
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
