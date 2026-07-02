load "../../stzBase.ring"
load "../_narrated.ring"

# The Bounds() global normalises a [open, :And = close] pair to a plain
# [open, close] list. Archive block #345.

Scenario("Normalising a bounds pair")
	Then('Bounds([ "67", :And = "12" ])',
		ListEq( Bounds([ "67", :And = "12" ]), [ "67", "12" ] ), TRUE)
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
