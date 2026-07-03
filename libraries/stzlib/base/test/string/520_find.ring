load "../../stzBase.ring"
load "../_narrated.ring"

# Three spellings of the same find -- all return ALL the positions (the
# StzFind list contract). Archive block #520.

Scenario("Finding the stars, three ways")
	o1 = new stzString("*AB*")
	Then("Find", ListEq( o1.Find("*"), [1, 4] ), TRUE)
	Then("the named-param spelling",
		ListEq( o1.Find( :SubString = "*" ), [1, 4] ), TRUE)
	Then("FindSubString",
		ListEq( o1.FindSubString( "*" ), [1, 4] ), TRUE)
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
