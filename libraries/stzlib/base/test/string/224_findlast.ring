load "../../stzBase.ring"
load "../_narrated.ring"

# FindLast / FindLastAsSection -- the last occurrence of a substring, as a
# position and as a span. Archive block #224.

Scenario("Finding the last occurrence")
	Given('"___<<<__<<<__"')
	o1 = new stzString("___<<<__<<<__")
	Then("FindLast('<<<') is 9", o1.FindLast("<<<"), 9)
	Then("FindLastAsSection('<<<') is [9,11]", ListEq( o1.FindLastAsSection("<<<"), [ 9, 11 ] ), TRUE)
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
