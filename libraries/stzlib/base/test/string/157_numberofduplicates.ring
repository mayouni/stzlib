load "../../stzBase.ring"
load "../_narrated.ring"

# NumberOfDuplicates() / Duplicates() -- the characters that occur more than once.
# Archive block #157.

Scenario("Counting and listing duplicated characters")
	Given('"*4*34"')
	o1 = new stzString("*4*34")
	Then("there are 2 duplicated chars", o1.NumberOfDuplicates(), 2)
	Then("they are '*' and '4'", ListEq( o1.Duplicates(), [ "*", "4" ] ), TRUE)
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
