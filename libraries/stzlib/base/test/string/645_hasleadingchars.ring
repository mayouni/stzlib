load "../../stzBase.ring"
load "../_narrated.ring"

# Leading/trailing chars on strings and their item twins on lists --
# the same semantics both sides (a Softanza design goal).
# Archive block #645.

Scenario("Leading and trailing chars of a string")
	o1 = new stzString( "***Ring++" )
	Then("has leading chars", o1.HasLeadingChars(), TRUE)
	Then("three of them", o1.NumberOfLeadingChars(), 3)
	Then("as a list",
		ListEq( o1.LeadingChars(), [ "*", "*", "*" ] ), TRUE)
	Then("has trailing chars", o1.HasTrailingChars(), TRUE)
	Then("two of them", o1.NumberOfTrailingChars(), 2)
	Then("as a string", o1.TrailingCharsXT(), "++")
	o1.ReplaceEachLeadingChar(:With = "+")
	Then("leading run replaced", o1.Content(), "+++Ring++")
	o1.ReplaceEachLeadingAndTrailingChar(:With = "*")
	Then("both runs replaced", o1.Content(), "***Ring**")
EndScenario()

Scenario("The same on a char list")
	o2 = new stzList([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ])
	Then("has leading items", o2.HasLeadingItems(), TRUE)
	Then("three of them", o2.NumberOfLeadingItems(), 3)
	Then("the items",
		ListEq( o2.LeadingItems(), [ "*", "*", "*" ] ), TRUE)
	Then("has trailing items", o2.HasTrailingItems(), TRUE)
	Then("two of them", o2.NumberOfTrailingItems(), 2)
	Then("the items",
		ListEq( o2.TrailingItems(), [ "+", "+" ] ), TRUE)
	o2.ReplaceLeadingItems(:With = "+")
	Then("leading replaced",
		ListEq( o2.Content(), [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ] ), TRUE)
	o2.ReplaceLeadingAndTrailingItems(:With = "*")
	Then("both replaced",
		ListEq( o2.Content(), [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ] ), TRUE)
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
