load "../../stzBase.ring"
load "../_narrated.ring"

# Numbers() extracts the numeric literals; NumbersAfter(anchor) keeps the
# ones following the anchor. Archive block #404.

Scenario("Numbers in a W-ish expression")
	Given('"@item = This[ @i+1 ]"')
	o1 = new stzString("@item = This[ @i+1 ]")
	Then("the numbers", ListEq( o1.Numbers(), [ "1" ] ), TRUE)
	Then("the numbers after @i", ListEq( o1.NumbersAfter("@i"), [ "1" ] ), TRUE)
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
