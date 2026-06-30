load "../../stzBase.ring"
load "../_narrated.ring"

# HowManySubStrings + the occurrence-count families. Per the original:
# SubStringsOccurringNTimes(n) = ">= n" (alias ...NTimesOrMore); ...ExactlyNTimes
# = "= n"; ...NoMoreThanNTimes = ...LessThanNTimes = "< n". Archive block #39.
# (The archive's SomeXT(.., 1/100) line samples RANDOMLY -> not asserted.)

Scenario("Counting and classifying the substrings by occurrence")
	Given('"one two one three two one four five"')
	o1 = new stzString("one two one three two one four five")
	Then("HowManySubStrings is 630", o1.HowManySubStrings(), 630)
	Then("SubStringsOccuringNTimes(3) is the >=3 set",
		ListEq( o1.SubStringsOccuringNTimes(3),
			[ "o", "on", "one", "one ", "n", "ne", "ne ", "e", "e ", "e t", " ", " t", "t" ] ), TRUE)
	Then("SubStringsOccurringExactlyNTimes(3) is the =3 set",
		ListEq( o1.SubStringsOccurringExactlyNTimes(3),
			[ "on", "one", "one ", "n", "ne", "ne ", "e t", " t", "t" ] ), TRUE)
	Then("SubStringsOccurringNoMoreThanNTimes(1) is empty (< 1)",
		ListEq( o1.SubStringsOccurringNoMoreThanNTimes(1), [ ] ), TRUE)
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
