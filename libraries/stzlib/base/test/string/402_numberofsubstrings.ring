load "../../stzBase.ring"
load "../_narrated.ring"

# All 21 windows of "123456" (all distinct). Archive block #402.

Scenario("All substrings of 123456")
	o1 = new stzString("123456")
	Then("the count", o1.NumberOfSubStrings(), 21)
	Then("the windows",
		ListEq( o1.SubStrings(),
			[ "1", "12", "123", "1234", "12345", "123456", "2",
			  "23", "234", "2345", "23456", "3", "34", "345",
			  "3456", "4", "45", "456", "5", "56", "6" ] ), TRUE)
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
