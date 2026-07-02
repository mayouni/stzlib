load "../../stzBase.ring"
load "../_narrated.ring"

# NumbersAfter picks every signed decimal following the anchor;
# NumberComingAfter returns the first. Archive block #481.

Scenario("Signed decimals after @i")
	o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] .... @i -12233.87  @i + 764.3322 }')
	Then("all four numbers",
		ListEq( o1.NumbersAfter("@i"), [ "-3", "3", "-12233.87", "764.3322" ] ), TRUE)
	Then("the first one", o1.NumberComingAfter("@i"), "-3")
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
