load "../../stzBase.ring"
load "../_narrated.ring"

# FindSSZ / FindSSZZ on an empty string with a degenerate section -- a graceful
# empty result (no crash). SS = "the Start and end of a Section". Archive #93.

Scenario("Finding in a section of an empty string")
	Given("an empty stzString")
	o1 = new stzString("")
	Then("FindSSZ('', -1, 0) is empty", ListEq( o1.FindSSZ("", -1, 0), [] ), TRUE)
	Then("FindSSZZ('', -1, 0) is empty", ListEq( o1.FindSSZZ("", -1, 0), [] ), TRUE)
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
