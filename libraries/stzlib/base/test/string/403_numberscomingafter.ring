load "../../stzBase.ring"
load "../_narrated.ring"

# NumbersComingAfter(anchor): the signed numbers right after each "@i"
# anchor, then fluent-chained through NumbrifyQ (also spellable
# NumberifyQ) to Smallest/Greatest. Archive block #403.

Scenario("Numbers after an anchor, numerified")
	Given("'{ This[ @i - 3 ] = This[ @i + 3 ] }'")
	o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] }')
	Then("the signed numbers after @i",
		ListEq( o1.NumbersComingAfter("@i"), [ "-3", "3" ] ), TRUE)
	Then("the smallest", o1.NumbersComingAfterQ("@i").NumbrifyQ().Smallest(), -3)
	Then("the greatest", o1.NumbersComingAfterQ("@i").NumberifyQ().Greatest(), 3)
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
