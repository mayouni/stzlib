load "../../stzBase.ring"
load "../_narrated.ring"

# Numbers() lists every number in the string; NumbersComingAfter(anchor) lists
# only the (signed) numbers that follow the anchor -- per the original, a leading
# "+" is dropped and unanchored trailing numbers (the "11" of "e11") are excluded.
# Archive block #229.

Scenario("Numbers, and the numbers coming after an anchor")
	Given('" @i + 10, @i- 125, e11"')
	o1 = new stzString(" @i + 10, @i- 125, e11")
	Then("Numbers() finds all three", ListEq( o1.Numbers(), [ "10", "-125", "11" ] ), TRUE)
	Then("NumbersComingAfter('@i') keeps only the two anchored ones",
		ListEq( o1.NumbersComingAfter("@i"), [ "10", "-125" ] ), TRUE)
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
