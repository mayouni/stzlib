load "../../stzBase.ring"
load "../_narrated.ring"

# SUBSTRONGS & SUBSTRINKS (deliberate Softanza wordplay): on a list of
# strings, SubStrongs() are the items that CONTAIN another item of the list,
# and SubStrinks() the items CONTAINED IN another item. Here "Ring" contains
# the item "in". Archive block #305.

Scenario("Substrongs and substrinks of a word list")
	Given('[ "I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!" ]')
	o1 = new stzListOfStrings([
		"I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!"
	])
	Then("the strings containing other items", ListEq( o1.SubStrongs(), [ "Ring" ] ), TRUE)
	Then("the strings contained in other items", ListEq( o1.SubStrinks(), [ "in" ] ), TRUE)
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
