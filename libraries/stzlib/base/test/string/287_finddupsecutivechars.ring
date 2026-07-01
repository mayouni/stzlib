load "../../stzBase.ring"
load "../_narrated.ring"

# FindDupSecutiveChars gives the positions where a char repeats the previous one;
# the ZZ form GROUPS those into [first,last] runs. Archive block #287.

Scenario("Finding runs of duplicated consecutive chars")
	Given('"ABBBBbbbbCCcFFFaABCC"')
	o1 = new stzString("ABBBBbbbbCCcFFFaABCC")
	Then("the dup-consecutive positions",
		ListEq( o1.FindDupSecutiveChars(), [ 3, 4, 5, 7, 8, 9, 11, 14, 15, 20 ] ), TRUE)
	Then("the ZZ form groups them into runs",
		ListEq( o1.FindDupSecutiveCharsZZ(), [ [3,5], [7,9], [11,11], [14,15], [20,20] ] ), TRUE)
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
