load "../../stzBase.ring"
load "../_narrated.ring"

# ... and the Before twin inserts at every named position.
# Archive block #942.

Scenario("Tildes before every second letter")
	o1 = new stzList( @Chars("SOFTANZA") )
	o1.InsertBeforePositions([ 2, 4, 6, 8 ], "~")
	Then("four tildes",
		ListEq( o1.Content(),
			[ "S", "~", "O", "F", "~", "T", "A", "~", "N", "Z", "~", "A" ] ), TRUE)
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
