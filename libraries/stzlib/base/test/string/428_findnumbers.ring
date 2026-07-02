load "../../stzBase.ring"
load "../_narrated.ring"

# The numbers family is sign- and decimal-aware end to end: FindNumbers
# gives the number STARTS, FindNumbersZZ their sections, Numbers the
# strings, NumbersZZ each unique number grouped with its sections (the
# archive displayed the single-occurrence groups flattened -- asserted at
# the coherent [num, [sections]] shape block #429 pins). LeadingNumber
# keeps the sign. Archive block #428.

Scenario("Signed decimals in a sentence")
	Given('"-132114.45 euros and 246 cents"')
	o1 = new stzString("-132114.45 euros and 246 cents")
	Then("the number starts", ListEq( o1.FindNumbers(), [ 1, 22 ] ), TRUE)
	Then("their sections",
		ListEq( o1.FindNumbersZZ(), [ [1, 10], [22, 24] ] ), TRUE)
	Then("the number strings",
		ListEq( o1.Numbers(), [ "-132114.45", "246" ] ), TRUE)
	Then("each grouped with its sections",
		ListEq( o1.NumbersZZ(),
			[ [ "-132114.45", [ [1, 10] ] ], [ "246", [ [22, 24] ] ] ] ), TRUE)
	Then("it starts with a number", o1.StartsWithANumber(), TRUE)
	Then("... with -132", o1.StartsWithThisNumber("-132"), TRUE)
	Then("... and with the whole of it", o1.StartsWithThisNumber("-132114.45"), TRUE)
	Then("the leading number", o1.LeadingNumber(), "-132114.45")
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
