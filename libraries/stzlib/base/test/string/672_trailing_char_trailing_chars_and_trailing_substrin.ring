load "../../stzBase.ring"
load "../_narrated.ring"

# The trailing part of a string is the repeated chars at its end.
# You can check it, count it, read it as a string or as chars, and
# remove it -- with SubString and Chars spellings for each.
# Archive block #672.

Scenario("Working the trailing part of 12.4560000")
	o1 = new stzString("12.4560000")
	Then("it has a trailing part", o1.HasTrailingSubString(), TRUE)
	Then("(same as HasTrailingChars)", o1.HasTrailingChars(), TRUE)
	Then("four chars long", o1.HowManyTrailingChar(), 4)
	Then("as a string", o1.TrailingSubString(), "0000")
	Then("(same as TrailingCharsXT)", o1.TrailingCharsXT(), "0000")
	Then("as a list of chars",
		ListEq( o1.TrailingChars(), [ "0", "0", "0", "0" ] ), TRUE)
	o1.RemoveTrailingChars()
	Then("and removed", o1.Content(), "12.456")
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
