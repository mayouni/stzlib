load "../../stzBase.ring"
load "../_narrated.ring"

# NumbersComingAfter keeps only the numbers anchored to "@i"; the plain
# Numbers() sees the unanchored "10" too. Archive block #430.

Scenario("Numbers after an anchor vs all numbers")
	Given('" This 10 : @i - 1.23 and this: @i + 378.12! "')
	o1 = new stzString( " This 10 : @i - 1.23 and this: @i + 378.12! " )
	Then("the anchored numbers",
		ListEq( o1.NumbersComingAfter("@i"), [ "-1.23", "378.12" ] ), TRUE)
	Then("the 2nd anchored number",
		o1.NthNumberComingAfter(2, "@i"), "378.12")
	Then("all numbers",
		ListEq( o1.Numbers(), [ "10", "-1.23", "378.12" ] ), TRUE)
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
