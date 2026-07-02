load "../../stzBase.ring"
load "../_narrated.ring"

# RepeatedXT(:InA = ..., :OfSize = ...): the value repeats into the named
# container -- keeping its own type in :List (a stzString "5" stays the
# string "5"), coercing in :ListOfNumbers / :ListOfStrings, pairing in
# :ListOfPairs, nesting in :ListOfLists, and filling :Grid / :Table
# shapes. (The final .Show() of the archive is visual and not asserted.)
# Archive block #487.

Scenario("Repeating into containers")
	Then("a string keeps its type in a list",
		ListEq( Q("5").RepeatedXT(:InA = :List, :OfSize = 2), [ "5", "5" ] ), TRUE)
	Then("RepeatedInAPair pairs it",
		ListEq( Q("A").RepeatedInAPair(), [ "A", "A" ] ), TRUE)
	Then("a string coerces in a list of numbers",
		ListEq( Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3), [ 5, 5, 5 ] ), TRUE)
	Then("a number concatenates in a string",
		Q(5).RepeatedXT(:InA = :String, :OfSize = 3), "555")
	Then("a number stringifies in a list of strings",
		ListEq( Q(5).RepeatedXT(:InA = :ListOfStrings, :OfSize = 3), [ "5", "5", "5" ] ), TRUE)
	Then("pairs",
		ListEq( Q("A").RepeatedXT(:InA = :ListOfPairs, :OfSize = 3),
			[ [ "A", "A" ], [ "A", "A" ], [ "A", "A" ] ] ), TRUE)
	Then("lists",
		ListEq( Q("A").RepeatedXT(:InA = :ListOfLists, :OfSize = 3),
			[ [ "A" ], [ "A" ], [ "A" ] ] ), TRUE)
EndScenario()

Scenario("Nesting and 2D shapes")
	Then("a repeated list repeats again",
		ListEq( Q("A").
			RepeatXTQ(:InA = :List, :OfSize = 3).
			RepeatedXT(:InA = :List, :OfSize = 3),
			[ [ "A", "A", "A" ], [ "A", "A", "A" ], [ "A", "A", "A" ] ] ), TRUE)
	Then("a 3x3 grid",
		ListEq( Q("A").RepeatedXT(:InA = :Grid, :OfSize = [3, 3]),
			[ [ "A", "A", "A" ], [ "A", "A", "A" ], [ "A", "A", "A" ] ] ), TRUE)
	Then("a 3x3 table",
		ListEq( Q("A").RepeatedXT(:InA = :Table, :OfSize = [3, 3]),
			[ [ "COL1", [ "A", "A", "A" ] ],
			  [ "COL2", [ "A", "A", "A" ] ],
			  [ "COL3", [ "A", "A", "A" ] ] ] ), TRUE)
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
