load "../../stzBase.ring"
load "../_narrated.ring"

# Duplicated-consecutive SUBSTRINGS: FindDupSecutiveSubString(sub) returns the
# start positions of the 2nd+ occurrence in each back-to-back run of sub; the
# ZZ form returns their [start, end] sections; DupSecutiveSubStringZ/ZZ group
# the substring with those positions/sections. The plural family derives the
# duplicated substrings themselves from the phase-tiled ConsecutiveSubStrings()
# list (per the original monolith). Archive block #288.

Scenario("Finding the consecutive duplicates of a given substring")
	Given('"phpringringringpythonrubyruby" (ring at 4, 8, 12)')
	o1 = new stzString("phpringringringpythonrubyruby")
	Then("the dup-consecutive positions of 'ring'",
		ListEq( o1.FindDupSecutiveSubString("ring"), [ 8, 12 ] ), TRUE)
	Then("the ZZ form returns their sections",
		ListEq( o1.FindDupSecutiveSubStringZZ("ring"), [ [8,11], [12,15] ] ), TRUE)
	Then("the Z grouping pairs the substring with the positions",
		ListEq( o1.DupSecutiveSubStringZ("ring"), [ "ring", [ 8, 12 ] ] ), TRUE)
	Then("the ZZ grouping pairs it with the sections",
		ListEq( o1.DupSecutiveSubStringZZ("ring"), [ "ring", [ [8,11], [12,15] ] ] ), TRUE)
EndScenario()

Scenario("Finding ALL consecutive-duplicated substrings")
	Given('"phpringringringpythonrubyruby"')
	o1 = new stzString("phpringringringpythonrubyruby")
	Then("the duplicated substrings",
		ListEq( o1.DupSecutiveSubStrings(), [ "ingr", "ngri", "ruby", "grin", "ring" ] ), TRUE)
	Then("their duplicate positions",
		ListEq( o1.FindDupSecutiveSubStrings(), [ 9, 10, 26, 11, 8, 12 ] ), TRUE)
	Then("their duplicate sections",
		ListEq( o1.FindDupSecutiveSubStringsZZ(),
			[ [9,12], [10,13], [26,29], [11,14], [8,11], [12,15] ] ), TRUE)
	Then("the Z grouping",
		ListEq( o1.DupSecutiveSubStringsZ(),
			[ [ "ingr", [9] ], [ "ngri", [10] ], [ "ruby", [26] ],
			  [ "grin", [11] ], [ "ring", [8, 12] ] ] ), TRUE)
	Then("the ZZ grouping",
		ListEq( o1.DupSecutiveSubStringsZZ(),
			[ [ "ingr", [ [9,12] ] ], [ "ngri", [ [10,13] ] ], [ "ruby", [ [26,29] ] ],
			  [ "grin", [ [11,14] ] ], [ "ring", [ [8,11], [12,15] ] ] ] ), TRUE)
	o1.RemoveDupSecutiveSubStrings()
	Then("removing them (overlapping sections merged) leaves",
		o1.Content(), "phpringpythonruby")
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
