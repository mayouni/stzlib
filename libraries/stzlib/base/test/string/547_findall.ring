load "../../stzBase.ring"
load "../_narrated.ring"

# The same N-occurrences surface on substrings (abstracted in stzObject,
# so stzString and stzListOfStrings behave alike). Archive block #547.

Scenario("abc three times")
	o1 = new stzString("12abc67abc12abc")
	Then("all occurrences", ListEq( o1.FindAll("abc"), [3, 8, 13] ), TRUE)
	Then("the first two", ListEq( o1.NFirstOccurrences(2, :Of = "abc"), [3, 8] ), TRUE)
	Then("... from position 1",
		ListEq( o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 1), [3, 8] ), TRUE)
	Then("the last two", ListEq( o1.NLastOccurrences(2, :Of = "abc"), [8, 13] ), TRUE)
	Then("... from position 1",
		ListEq( o1.NLastOccurrencesST(2, "abc", :StartingAt = 1), [8, 13] ), TRUE)
	Then("the first two from 5",
		ListEq( o1.NFirstOccurrencesST(2, :Of = "abc", :StartingAt = 5), [8, 13] ), TRUE)
	Then("the last two from 3",
		ListEq( o1.LastNOccurrencesST(2, :Of = "abc", :StartingAt = 3), [8, 13] ), TRUE)
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
