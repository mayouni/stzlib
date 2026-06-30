load "../../stzBase.ring"
load "../_narrated.ring"

# HowManySubStrings + the SubStringsOccurring* counters, and the active (mutating
# RemoveBounds) vs passive (BoundsRemoved) function forms. Archive block #40.
# (The archive's Some(...) line samples RANDOMLY, so it is non-deterministic and
# is not asserted here.)

Scenario("Counting substrings by occurrence")
	Given('"ALLAH"')
	o1 = new stzString("ALLAH")
	Then("HowManySubStrings is 15", o1.HowManySubStrings(), 15)
	Then("the substrings occurring only once",
		ListEq( o1.SubStringsOccurringOnlyNTimes(1),
			[ "AL", "ALL", "ALLA", "ALLAH", "LL", "LLA", "LLAH", "LA", "LAH", "AH", "H" ] ), TRUE)
	Then("the substrings occurring twice are A and L",
		ListEq( o1.SubStringsOccurringNTimes(2), [ "A", "L" ] ), TRUE)
	Then("none occur 7 times (HwoMany misspelled alias)", HwoMany( o1.SubStringsOccurringNTimes(7) ), 0)
	Then("13 substrings occur fewer than 3 times", HowMany( o1.SubStringsOccurringLessThanNTimes(3) ), 13)
EndScenario()

Scenario("Active (mutating) vs passive (non-mutating) function forms")
	Given('"<<Go!>>"')
	o2 = new stzString("<<Go!>>")
	o2.RemoveBounds()
	Then("RemoveBounds() mutates -> 'Go!'", o2.Content(), "Go!")

	o3 = new stzString("<<Go!>>")
	Then("BoundsRemoved() returns the result without mutating", o3.BoundsRemoved(), "Go!")
	Then("...and the object is unchanged", o3.Content(), "<<Go!>>")
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
