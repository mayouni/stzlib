load "../../stzBase.ring"
load "../_narrated.ring"

# FindFirst / FindFirstAsSection -- the first occurrence of a substring, as a
# position and as a span. Archive block #223.

Scenario("Finding the first occurrence")
	Given('"___<<<__<<<__"')
	o1 = new stzString("___<<<__<<<__")
	Then("FindFirst('<<<') is 4", o1.FindFirst("<<<"), 4)
	Then("FindFirstAsSection('<<<') is [4,6]", ListEq( o1.FindFirstAsSection("<<<"), [ 4, 6 ] ), TRUE)
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
