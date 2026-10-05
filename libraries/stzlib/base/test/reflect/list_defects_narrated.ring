load "../../stzBase.ring"
load "../_narrated.ring"

# stzList defects left after the wave-0 patch (wave0_list_narrated.ring guards the patch itself):
# SplitBefore/SplitAfter on an item, the XT forms, RangesAndAntiRanges, ItemsAppearingLessThanNTimes.
# Every scenario states what the method does AFTER the fix.

Scenario("SplitBefore and SplitAfter change the list (they used to split a copy and drop it)")
	o = new stzList([ "a", "b", "c", "b", "d" ])
	o.SplitBefore("b")
	Then("SplitBefore starts a part at each occurrence", @@(o.Content()), '[ [ "a" ], [ "b", "c" ], [ "b", "d" ] ]')
	o = new stzList([ "a", "b", "c", "b", "d" ])
	o.SplitAfter("b")
	Then("SplitAfter ends a part at each occurrence", @@(o.Content()), '[ [ "a", "b" ], [ "c", "b" ], [ "d" ] ]')
	o = new stzList([ 4, 5, 4, 6 ])
	o.SplitBefore(4)
	Then("a number is an item here, not a position", @@(o.Content()), "[ [ 4, 5 ], [ 4, 6 ] ]")
	o = new stzList([ "a", "b", "c" ])
	o.SplitBefore("zz")
	Then("an item that is absent leaves the list alone", @@(o.Content()), '[ "a", "b", "c" ]')
	o = new stzList([ "a", "b", "c" ])
	o.SplitAfter("c")
	Then("an item at the very end adds no empty part", @@(o.Content()), '[ [ "a", "b", "c" ] ]')
EndScenario()

Scenario("The XT forms split with options")
	o = new stzList([ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j" ])
	Then("AfterPositions cuts after each position", @@(o.SplittedXT([ :AfterPositions, [ 3, 6 ] ])),
		'[ [ "a", "b", "c" ], [ "d", "e", "f" ], [ "g", "h", "i", "j" ] ]')
	Then("and its sections are the [first, last] of each part", @@(o.SplittedAsSectionsXT([ :AfterPositions, [ 3, 6 ] ])),
		"[ [ 1, 3 ], [ 4, 6 ], [ 7, 10 ] ]")
	Then("BeforePosition cuts before the position", @@(o.SplittedXT([ :BeforePosition, 3 ])),
		'[ [ "a", "b" ], [ "c", "d", "e", "f", "g", "h", "i", "j" ] ]')
	Then("a bare number is a position", @@(o.SplittedXT(3)),
		'[ [ "a", "b" ], [ "c", "d", "e", "f", "g", "h", "i", "j" ] ]')
	Then("an item is cut before its occurrences", @@(o.SplittedAsSectionsXT("c")), "[ [ 1, 2 ], [ 3, 10 ] ]")
	Then("ToNParts makes n parts", @@(o.SplittedAsSectionsXT([ :ToNParts, 3 ])), "[ [ 1, 4 ], [ 5, 7 ], [ 8, 10 ] ]")
	Then("ToPartsOfNItems makes parts of n items", @@(o.SplitAsSectionsXT([ :ToPartsOfNItems, 4 ])),
		"[ [ 1, 4 ], [ 5, 8 ], [ 9, 10 ] ]")
	Then("the sections point at the parts", @@(o.Sections(o.SplittedAsSectionsXT([ :AfterPositions, [ 3, 6 ] ]))),
		@@(o.SplittedXT([ :AfterPositions, [ 3, 6 ] ])))
	Then("the passive forms leave the list as it was", len(o.Content()), 10)
	o.SplitXT([ :After, 5 ])
	Then("SplitXT changes the list into its parts", @@(o.Content()),
		'[ [ "a", "b", "c", "d", "e" ], [ "f", "g", "h", "i", "j" ] ]')
EndScenario()

Scenario("RangesAndAntiRanges interleaves the ranges with the runs outside them")
	o = new stzList([ "a", "b", "c", "d", "e", "f", "g", "h" ])
	Then("ranges are [start, length]", @@(o.RangesAndAntiRanges([ [ 2, 2 ], [ 5, 2 ] ])),
		'[ [ "a" ], [ "b", "c" ], [ "d" ], [ "e", "f" ], [ "g", "h" ] ]')
	Then("AntiRanges is unchanged", @@(o.AntiRanges([ [ 2, 2 ], [ 5, 2 ] ])),
		'[ [ "a" ], [ "d" ], [ "g", "h" ] ]')
	Then("the order of the ranges does not matter", @@(o.RangesAndAntiRanges([ [ 5, 2 ], [ 2, 2 ] ])),
		'[ [ "a" ], [ "b", "c" ], [ "d" ], [ "e", "f" ], [ "g", "h" ] ]')
	Then("a range that covers the list leaves no run outside", @@(o.RangesAndAntiRanges([ [ 1, 8 ] ])),
		'[ [ "a", "b", "c", "d", "e", "f", "g", "h" ] ]')
	Then("SectionsAndAntiSections takes [start, end]", @@(o.SectionsAndAntiSections([ [ 2, 3 ] ])),
		'[ [ "a" ], [ "b", "c" ], [ "d", "e", "f", "g", "h" ] ]')
EndScenario()

Scenario("ItemsAppearing* answer items with their own type")
	o = new stzList([ 3, 1, 4, 1, 5 ])
	Then("numbers stay numbers", @@(o.ItemsAppearingLessThanNTimes(2)), "[ 3, 4, 5 ]")
	Then("and the same for more than n", @@(o.ItemsAppearingMoreThanNTimes(1)), "[ 1 ]")
	Then("and for exactly n", @@(o.ItemsAppearingNTimes(2)), "[ 1 ]")
	o = new stzList([ "a", "a", "b", 3, 3, [ 1 ], 7 ])
	Then("a mixed list keeps text, numbers and lists", @@(o.ItemsAppearingLessThanNTimes(2)), '[ "b", [ 1 ], 7 ]')
	o = new stzList([ "a", "a", "b" ])
	Then("a list of text is unchanged", @@(o.ItemsAppearingNTimes(1)), '[ "b" ]')
	o = new stzList([])
	Then("an empty list has none", @@(o.ItemsAppearingLessThanNTimes(2)), "[ ]")
EndScenario()

Summary()
