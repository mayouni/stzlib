load "../../stzBase.ring"
load "../_narrated.ring"

# NumbersComingAfter in a W-ish index expression. Archive block #431.

Scenario("Signed offsets after @i")
	Given('" This[ @i - 1 ] = This[ @i + 3 ] "')
	o1 = new stzString( " This[ @i - 1 ] = This[ @i + 3 ] " )
	Then("both offsets are picked",
		ListEq( o1.NumbersComingAfter("@i"), [ "-1", "3" ] ), TRUE)
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
