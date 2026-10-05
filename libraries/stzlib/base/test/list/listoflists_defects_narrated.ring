load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfLists -- the defects the documentation waves found (doc/DEFECTS.md), one scenario per family.
# Every expectation is written from the MEANING of the method, never copied from what it answered.

Scenario("ListAt answers the list at a position")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7 ] ])
	Then("ListAt(2) is the second list", @@(o1.ListAt(2)), "[ 4, 5, 6 ]")
	Then("ListAt(3) is the last list", @@(o1.ListAt(3)), "[ 7 ]")
	Then("ListAt agrees with ListAtPosition", @@(o1.ListAt(1)), @@(o1.ListAtPosition(1)))
EndScenario()

Scenario("Finding an item inside the lists: the needle is the item, the haystack each list")
	t1 = new stzListOfLists([ [ "a", "b", "c" ], [ "b", "c" ], [ "d" ] ])
	Then("a text item is found at its position in each list", @@(t1.FindInLists("b")), "[ [ 1, 2 ], [ 2, 1 ] ]")
	Then("the position inside the list is the item's own (it said 1 for list 1)", @@(t1.FindInLists("c")), "[ [ 1, 3 ], [ 2, 2 ] ]")
	n1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 1, 2 ] ])
	Then("a number item is found too (it raised)", @@(n1.FindInLists(2)), "[ [ 1, 2 ], [ 3, 2 ] ]")
	Then("an absent item answers nothing", @@(n1.FindInLists(99)), "[ ]")
	Then("FindItemsInLists finds several items at once (it raised R24)",
		@@(t1.FindItemsInLists([ "b", "d" ])), "[ [ 1, 2 ], [ 2, 1 ], [ 3, 1 ] ]")
	Then("FindItemsInListsCS is the same with the case dial", @@(t1.FindItemsInListsCS([ "B" ], 0)), "[ [ 1, 2 ], [ 2, 1 ] ]")
	Then("FindSubListInList finds a sublist (it raised R14)", @@(n1.FindSubListInList([ 1, 2 ])), "[ [ 1, [ 1 ] ], [ 3, [ 1 ] ] ]")
	Then("FindSubListInListsCS too (it said not implemented)", @@(n1.FindSubListInListsCS([ 2, 3 ], 1)), "[ [ 1, [ 2 ] ] ]")
	Then("and agrees with FindSubList", @@(n1.FindSubListInList([ 4, 5 ])), @@(n1.FindSubList([ 4, 5 ])))
EndScenario()

Scenario("PositionsW and ListsW collect what the condition keeps")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4 ], [ 5, 6, 7 ] ])
	Then("PositionsW answers the positions of the lists with three items (it raised R24)",
		@@(o1.PositionsW("len(@list) = 3")), "[ 1, 3 ]")
	Then("none matching answers nothing", @@(o1.PositionsW("len(@list) = 9")), "[ ]")
	Then("ListsW answers the lists themselves", @@(o1.ListsW("len(@list) = 1")), "[ [ 4 ] ]")
	Then("FindListsW is PositionsW", @@(o1.FindListsW("len(@list) = 3")), "[ 1, 3 ]")
EndScenario()

Scenario("JustifyEachListWith takes the item it pads with")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4 ] ])
	o1.JustifyEachListWith(0)
	Then("the short list is padded with the item", @@(o1.Content()), "[ [ 1, 2, 3 ], [ 4, 0, 0 ] ]")
	o2 = new stzListOfLists([ [ 1, 2 ], [ 4 ] ])
	Then("the chaining form answers the object", @@(o2.JustifyEachListWithQ("z").Content()), '[ [ 1, 2 ], [ 4, "z" ] ]')
EndScenario()

Scenario("Extending by repeating the items of each list")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 9 ], [ 7, 8 ] ])
	Then("ExtendedToByRepeatingItems(5) repeats each list's own items in turn (it raised R14)",
		@@(o1.ExtendedToByRepeatingItems(5)), "[ [ 1, 2, 3, 1, 2 ], [ 9, 9, 9, 9, 9 ], [ 7, 8, 7, 8, 7 ] ]")
	Then("ExtendedToWithItemsRepeated is the same", @@(o1.ExtendedToWithItemsRepeated(4)), "[ [ 1, 2, 3, 1 ], [ 9, 9, 9, 9 ], [ 7, 8, 7, 8 ] ]")
	Then("ExtendedByRepeatingItems goes to the longest list (it raised R14)",
		@@(o1.ExtendedByRepeatingItems()), "[ [ 1, 2, 3 ], [ 9, 9, 9 ], [ 7, 8, 7 ] ]")
	Then("ExtendedByItemsRepeated and ExtendedWithItemsRepeated are the same",
		@@(o1.ExtendedByItemsRepeated()) + @@(o1.ExtendedWithItemsRepeated()),
		@@(o1.ExtendedByRepeatingItems()) + @@(o1.ExtendedByRepeatingItems()))
	Then("the object is left alone by the passive forms", @@(o1.Content()), "[ [ 1, 2, 3 ], [ 9 ], [ 7, 8 ] ]")
	o1.ExtendToByRepeatingItems(4)
	Then("ExtendToByRepeatingItems changes the object", @@(o1.Content()), "[ [ 1, 2, 3, 1 ], [ 9, 9, 9, 9 ], [ 7, 8, 7, 8 ] ]")
	o2 = new stzListOfLists([ [ 1 ], [ 2, 3 ] ])
	o2.ExtendToWithItemsRepeated(3)
	Then("ExtendToWithItemsRepeated changes the object", @@(o2.Content()), "[ [ 1, 1, 1 ], [ 2, 3, 2 ] ]")
	o3 = new stzListOfLists([ [ 1 ], [ 2, 3 ] ])
	o3.ExtendByRepeatingItems()
	Then("ExtendByRepeatingItems changes the object", @@(o3.Content()), "[ [ 1, 1 ], [ 2, 3 ] ]")
	o4 = new stzListOfLists([ [ 1 ], [ 2, 3 ] ])
	o4.ExtendWithItemsRepeated()
	Then("ExtendWithItemsRepeated and ExtendByItemsRepeated too", @@(o4.Content()), "[ [ 1, 1 ], [ 2, 3 ] ]")
	o5 = new stzListOfLists([ [ ], [ 2, 3 ] ])
	Then("an empty list has nothing to repeat and stays empty", @@(o5.ExtendedToByRepeatingItems(3)), "[ [ ], [ 2, 3, 2 ] ]")
EndScenario()

Scenario("Extending with the given items, taken in turn")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 9 ], [ 7, 8 ] ])
	Then("ExtendedToWithItemsIn(5, ...) pads with the items in turn (it raised R14)",
		@@(o1.ExtendedToWithItemsIn(5, [ "a", "b" ])), '[ [ 1, 2, 3, "a", "b" ], [ 9, "a", "b", "a", "b" ], [ 7, 8, "a", "b", "a" ] ]')
	Then("ExtendedToUsingItemsIn is the same", @@(o1.ExtendedToUsingItemsIn(4, [ 0 ])), "[ [ 1, 2, 3, 0 ], [ 9, 0, 0, 0 ], [ 7, 8, 0, 0 ] ]")
	Then("ExtendedWithItemsIn goes to the longest list", @@(o1.ExtendedWithItemsIn([ "x", "y" ])), '[ [ 1, 2, 3 ], [ 9, "x", "y" ], [ 7, 8, "x" ] ]')
	Then("ExtendedUsingItemsIn too", @@(o1.ExtendedUsingItemsIn([ "x", "y" ])), @@(o1.ExtendedWithItemsIn([ "x", "y" ])))
	o2 = new stzListOfLists([ [ 1 ], [ 2, 3 ] ])
	o2.ExtendToWithItemsIn(3, [ 0, 5 ])
	Then("ExtendToWithItemsIn changes the object", @@(o2.Content()), "[ [ 1, 0, 5 ], [ 2, 3, 0 ] ]")
	o3 = new stzListOfLists([ [ 1 ], [ 2, 3 ] ])
	o3.ExtendToUsingItemsIn(3, [ 0 ])
	Then("ExtendToUsingItemsIn too", @@(o3.Content()), "[ [ 1, 0, 0 ], [ 2, 3, 0 ] ]")
	o4 = new stzListOfLists([ [ 1 ], [ 2, 3 ] ])
	o4.ExtendWithItemsIn([ "q" ])
	Then("ExtendWithItemsIn changes the object", @@(o4.Content()), '[ [ 1, "q" ], [ 2, 3 ] ]')
	o5 = new stzListOfLists([ [ 1 ], [ 2, 3 ] ])
	o5.ExtendUsingItemsIn([ "q" ])
	Then("ExtendUsingItemsIn too", @@(o5.Content()), '[ [ 1, "q" ], [ 2, 3 ] ]')
	bRaised = 0
	try
		o5.ExtendToWithItemsIn(4, [ ])
	catch
		bRaised = 1
	done
	Then("no items to pad with is refused", bRaised, 1)
EndScenario()

Scenario("Adjusting to the smallest list answers the copy")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8, 9 ] ])
	Then("AdjustedToSmallest answers every list cut to 2 (it answered nothing)", @@(o1.AdjustedToSmallest()), "[ [ 1, 2 ], [ 4, 5 ], [ 6, 7 ] ]")
	Then("and the five other names answer the same",
		@@(o1.AdjustedToSmallestSize()) + @@(o1.AdjustedToSmallestList()) + @@(o1.AdjustedToMin()) + @@(o1.AdjustedToMinSize()) + @@(o1.AdjustedToMinList()),
		@@(o1.AdjustedToSmallest()) + @@(o1.AdjustedToSmallest()) + @@(o1.AdjustedToSmallest()) + @@(o1.AdjustedToSmallest()) + @@(o1.AdjustedToSmallest()))
	Then("the object is left alone", @@(o1.Content()), "[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8, 9 ] ]")
EndScenario()

Scenario("ShrinkToWith makes every list exactly n items long, padding with the item")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4 ], [ 5, 6 ] ])
	Then("ShrinkedToWith(2, 0) cuts the long and pads the short", @@(o1.ShrinkedToWith(2, 0)), "[ [ 1, 2 ], [ 4, 0 ], [ 5, 6 ] ]")
	Then("n above the longest list pads every list, it no longer drops them all (it answered [ ])",
		@@(o1.ShrinkedToWith(4, "-")), '[ [ 1, 2, 3, "-" ], [ 4, "-", "-", "-" ], [ 5, 6, "-", "-" ] ]')
	Then("ShrinkedToUsing and ShrinkedToBy are the same", @@(o1.ShrinkedToUsing(2, 0)) + @@(o1.ShrinkedToBy(2, 0)), @@(o1.ShrinkedToWith(2, 0)) + @@(o1.ShrinkedToWith(2, 0)))
	o1.ShrinkToWith(2, 0)
	Then("ShrinkToWith changes the object", @@(o1.Content()), "[ [ 1, 2 ], [ 4, 0 ], [ 5, 6 ] ]")
	o2 = new stzListOfLists([ [ 1 ], [ 2, 3, 4 ] ])
	o2.ShrinkToUsing(5, 9)
	Then("ShrinkToUsing with n above the longest list keeps and pads", @@(o2.Content()), "[ [ 1, 9, 9, 9, 9 ], [ 2, 3, 4, 9, 9 ] ]")
	o3 = new stzListOfLists([ [ 1 ], [ 2, 3, 4 ] ])
	o3.ShrinkXT(2, 9)
	Then("ShrinkXT is the same", @@(o3.Content()), "[ [ 1, 9 ], [ 2, 3 ] ]")
EndScenario()

Scenario("The entry of an item, read from the index")
	t1 = new stzListOfLists([ [ "a", "b", "c" ], [ "b", "c" ], [ "c" ] ])
	Then("EntryByPosition names the lists that hold the item (it raised R14)", @@(t1.EntryByPosition("b")), "[ 1, 2 ]")
	Then("an item twice in the lists is two entries", @@(t1.EntryByPosition("c")), "[ 1, 2, 3 ]")
	Then("EntryByNumberOfOccurrence counts them", t1.EntryByNumberOfOccurrence("c"), 3)
	Then("Entry by position", @@(t1.Entry("a", :ByPosition)), "[ 1 ]")
	Then("Entry by number of occurrences", t1.Entry("b", :ByNumberOfOccurrence), 2)
	Then("NumberOfOccurrenceOfEntry, HowManyEntry and HowManyEntries agree",
		"" + t1.NumberOfOccurrenceOfEntry("b") + t1.HowManyEntry("b") + t1.HowManyEntries("b"), "222")
	Then("NthOccurrenceOfEntry(2, c) is the second list holding c", t1.NthOccurrenceOfEntry(2, "c"), 2)
	Then("FirstOccurrenceOfEntry", t1.FirstOccurrenceOfEntry("c"), 1)
	Then("LastOccurrenceOfEntry", t1.LastOccurrenceOfEntry("c"), 3)
	Then("an absent item has no entry", @@(t1.EntryByPosition("zz")), "[ ]")
	Then("and no occurrence", t1.NthOccurrenceOfEntry(1, "zz"), 0)
	Then("a number is an entry too", @@(StzListOfListsQ([ [ 1, 2 ], [ 2, 3 ] ]).EntryByPosition(2)), "[ 1, 2 ]")
	bRaised = 0
	try
		t1.Entry("a", :ByNothing)
	catch
		bRaised = 1
	done
	Then("an unknown mode is refused rather than answered with empty text", bRaised, 1)
EndScenario()

Scenario("Sorting the nth list in descending order")
	o1 = new stzListOfLists([ [ 3, 1, 2 ], [ 9, 8, 7 ] ])
	Then("NthListSortedDown answers the copy (it raised R13)", @@(o1.NthListSortedDown(1)), "[ [ 3, 2, 1 ], [ 9, 8, 7 ] ]")
	Then("NthListSortedInDescending too", @@(o1.NthListSortedInDescending(2)), "[ [ 3, 1, 2 ], [ 9, 8, 7 ] ]")
	Then("the object is left alone", @@(o1.Content()), "[ [ 3, 1, 2 ], [ 9, 8, 7 ] ]")
	o1.SortDownNthList(1)
	Then("SortDownNthList changes the object", @@(o1.Content()), "[ [ 3, 2, 1 ], [ 9, 8, 7 ] ]")
	o2 = new stzListOfLists([ [ 3, 1, 2 ], [ 7, 9, 8 ] ])
	o2.SortNthListInDescending(2)
	Then("SortNthListInDescending too", @@(o2.Content()), "[ [ 3, 1, 2 ], [ 9, 8, 7 ] ]")
	Then("and its chaining form sorts DOWN, not up", @@(StzListOfListsQ([ [ 1, 3, 2 ] ]).SortNthListInDescendingQ(1).Content()), "[ [ 3, 2, 1 ] ]")
	Then("a list of text sorts down too", @@(StzListOfListsQ([ [ "b", "c", "a" ] ]).NthListSortedDown(1)), '[ [ "c", "b", "a" ] ]')
EndScenario()

Scenario("Classifying groups the other items under the distinct first items")
	t1 = new stzListOfLists([ [ "a", "x", "y" ], [ "b", "z" ], [ "A", "w" ], [ "c" ] ])
	Then("Classify groups under the first item, case-folded (it raised R14)",
		@@(t1.Classify()), '[ [ "a", [ "x", "y", "w" ] ], [ "b", [ "z" ] ], [ "c", [ ] ] ]')
	t2 = new stzListOfLists([ [ "k1", "a" ], [ "k2", "a" ], [ "k1", "b" ] ])
	Then("a plain grouping", @@(t2.Classify()), '[ [ "k1", [ "a", "b" ] ], [ "k2", [ "a" ] ] ]')
	t3 = new stzListOfLists([ [ "x", "g1", 1 ], [ "y", "g2", 2 ], [ "z", "g1", 3 ] ])
	Then("ClassifyOn(2) groups under the second column (it raised R14)",
		@@(t3.ClassifyOn(2)), '[ [ "g1", [ "x", 1, "z", 3 ] ], [ "g2", [ "y", 2 ] ] ]')
	t4 = new stzListOfLists([ [ "ab", 1 ], [ "cd", 2 ], [ "ab", 3 ] ])
	Then("ClassifyBy groups by the value of an expression on the first item (it raised R14)",
		@@(t4.ClassifyBy('@item + "!"')), '[ [ "ab!", [ 1, 3 ] ], [ "cd!", [ 2 ] ] ]')
	Then("ClassifyOnBy on a column", @@(t3.ClassifyOnBy(2, '@item + "?"')), '[ [ "g1?", [ "x", 1, "z", 3 ] ], [ "g2?", [ "y", 2 ] ] ]')
	Then("a first item that is not text goes under @Undefined",
		@@(StzListOfListsQ([ [ 5, "x" ], [ "a", "y" ] ]).Classify()), '[ [ "a", [ "y" ] ], [ "@undefined", [ "x" ] ] ]')
EndScenario()

Scenario("Removing a column compares n with the number of columns, not the number of lists")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	Then("ColRemoved(3) removes the third column of two lists of three (it removed nothing)", @@(o1.ColRemoved(3)), "[ [ 1, 2 ], [ 4, 5 ] ]")
	Then("ColRemoved(2) is unchanged", @@(o1.ColRemoved(2)), "[ [ 1, 3 ], [ 4, 6 ] ]")
	Then("a column past the end removes nothing", @@(o1.ColRemoved(4)), "[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]")
	Then("NthColRemoved, ColumnRemoved, NthColumnRemoved and NthItemsRemoved are the same",
		@@(o1.NthColRemoved(3)) + @@(o1.ColumnRemoved(3)) + @@(o1.NthColumnRemoved(3)) + @@(o1.NthItemsRemoved(3)),
		@@(o1.ColRemoved(3)) + @@(o1.ColRemoved(3)) + @@(o1.ColRemoved(3)) + @@(o1.ColRemoved(3)))
	o2 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o2.RemoveCol(3)
	Then("RemoveCol(3) changes the object", @@(o2.Content()), "[ [ 1, 2 ], [ 4, 5 ] ]")
	o3 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o3.RemoveNthColumn(3)
	Then("RemoveNthColumn(3)", @@(o3.Content()), "[ [ 1, 2 ], [ 4, 5 ] ]")
	o4 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o4.RemoveNthItems(3)
	Then("RemoveNthItems(3)", @@(o4.Content()), "[ [ 1, 2 ], [ 4, 5 ] ]")
	o5 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5 ] ])
	o5.RemoveColumn(3)
	Then("a list too short for the column is skipped", @@(o5.Content()), "[ [ 1, 2 ], [ 4, 5 ] ]")
	o6 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o6.RemoveNthCol(3)
	Then("RemoveNthCol(3)", @@(o6.Content()), "[ [ 1, 2 ], [ 4, 5 ] ]")
EndScenario()

Scenario("Removing many columns at once")
	o1 = new stzListOfLists([ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])
	Then("ColsRemoved([ 1, 3 ]) (it raised R14)", @@(o1.ColsRemoved([ 1, 3 ])), "[ [ 2, 4 ], [ 6, 8 ] ]")
	Then("the order of the positions does not matter", @@(o1.ColsRemoved([ 4, 2 ])), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("the Many/These/Columns forms are the same",
		@@(o1.TheseColsRemoved([ 1, 3 ])) + @@(o1.ManyColsRemoved([ 1, 3 ])) + @@(o1.ColumnsRemoved([ 1, 3 ])) + @@(o1.ManyColumnsRemoved([ 1, 3 ])) + @@(o1.TheseColumnsRemoved([ 1, 3 ])),
		@@(o1.ColsRemoved([ 1, 3 ])) + @@(o1.ColsRemoved([ 1, 3 ])) + @@(o1.ColsRemoved([ 1, 3 ])) + @@(o1.ColsRemoved([ 1, 3 ])) + @@(o1.ColsRemoved([ 1, 3 ])))
	Then("an :At = [ ... ] argument is read", @@(o1.ColsRemoved([ :At, [ 1, 2 ] ])), "[ [ 3, 4 ], [ 7, 8 ] ]")
	Then("the object is left alone", @@(o1.Content()), "[ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ]")
	o2 = new stzListOfLists([ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])
	o2.RemoveCols([ 1, 3 ])
	Then("RemoveCols changes the object", @@(o2.Content()), "[ [ 2, 4 ], [ 6, 8 ] ]")
	o3 = new stzListOfLists([ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])
	o3.RemoveTheseCols([ 2, 3 ])
	Then("RemoveTheseCols", @@(o3.Content()), "[ [ 1, 4 ], [ 5, 8 ] ]")
	o4 = new stzListOfLists([ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])
	o4.RemoveManyCols([ 2, 3 ])
	Then("RemoveManyCols", @@(o4.Content()), "[ [ 1, 4 ], [ 5, 8 ] ]")
	o5 = new stzListOfLists([ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])
	o5.RemoveColumns([ 2, 3 ])
	Then("RemoveColumns", @@(o5.Content()), "[ [ 1, 4 ], [ 5, 8 ] ]")
	o6 = new stzListOfLists([ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])
	o6.RemoveTheseColumns([ 2, 3 ])
	Then("RemoveTheseColumns", @@(o6.Content()), "[ [ 1, 4 ], [ 5, 8 ] ]")
	o7 = new stzListOfLists([ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ])
	o7.RemoveManyColumns([ 2, 3 ])
	Then("RemoveManyColumns", @@(o7.Content()), "[ [ 1, 4 ], [ 5, 8 ] ]")
	Then("RemoveTheseColqQ, the misspelt chaining form, answers the object",
		@@(StzListOfListsQ([ [ 1, 2, 3 ] ]).RemoveTheseColqQ([ 1 ]).Content()), "[ [ 2, 3 ] ]")
	Then("RemoveManyColqQ too", @@(StzListOfListsQ([ [ 1, 2, 3 ] ]).RemoveManyColqQ([ 3 ]).Content()), "[ [ 1, 2 ] ]")
EndScenario()

Scenario("InsertCol can append after the last column")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o1.InsertCol(4, [ "x", "y" ])
	Then("InsertCol(4, ...) on three columns appends a fourth (it did nothing)", @@(o1.Content()), '[ [ 1, 2, 3, "x" ], [ 4, 5, 6, "y" ] ]')
	o2 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o2.InsertCol(1, [ "x", "y" ])
	Then("InsertCol(1, ...) still inserts in front", @@(o2.Content()), '[ [ "x", 1, 2, 3 ], [ "y", 4, 5, 6 ] ]')
	o3 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o3.InsertCol(3, [ "x", "y" ])
	Then("InsertCol(3, ...) still inserts before the third", @@(o3.Content()), '[ [ 1, 2, "x", 3 ], [ 4, 5, "y", 6 ] ]')
	o4 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
	o4.InsertCol(5, [ "x", "y" ])
	Then("two past the end is still refused, quietly", @@(o4.Content()), "[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]")
	o5 = new stzListOfLists([ [ 1, 2 ], [ 4, 5 ] ])
	o5.InsertItems(3, [ 7, 8 ])
	Then("InsertItems is the same", @@(o5.Content()), "[ [ 1, 2, 7 ], [ 4, 5, 8 ] ]")
EndScenario()

Scenario("The conversions that raised")
	o1 = new stzListOfLists([ [ 1, 2, 3 ], [ 4, 5 ] ])
	Then("ToListInStringInShortForm writes each list in its short form (it raised R21)", @@(o1.ToListInStringInShortForm()), '[ "1:3", "4:5" ]')
	Then("a list that is not a range is written out in full", StzListOfListsQ([ [ 1, 5, 7 ], [ 2, 3 ] ]).ToListInStringInShortForm()[1], "[ 1, 5, 7 ]")
	o2 = new stzListOfLists([ [ 1, 2 ], [ 3, 4 ] ])
	Then("ToStzListOfpairsOfNumbers answers a stzListOfPairs (it raised R11)", classname(o2.ToStzListOfpairsOfNumbers()), "stzlistofpairs")
	Then("with the same pairs", @@(o2.ToStzListOfpairsOfNumbers().Content()), "[ [ 1, 2 ], [ 3, 4 ] ]")
	bRaised = 0
	try
		o1.ToStzListOfpairsOfNumbers()
	catch
		bRaised = 1
	done
	Then("lists that are not all pairs are refused", bRaised, 1)
	bRaised = 0
	try
		StzListOfListsQ([ [ "a", "b" ] ]).ToStzListOfpairsOfNumbers()
	catch
		bRaised = 1
	done
	Then("and pairs of text too", bRaised, 1)
	o3 = new stzListOfLists([ [ 10 ], [ 2, 3 ] ])
	Then("SpeedUp divides the first list's sum by the second's (it raised R21)", o3.SpeedUp(), 2)
	Then("GainFactor divides the second by the first", o3.GainFactor(), 0.5)
	Then("SpeedUpX is the same as SpeedUp", o3.SpeedUpX(), 2)
	Then("GainX is the same as GainFactor", o3.GainX(), 0.5)
	bRaised = 0
	try
		StzListOfListsQ([ [ 1 ] ]).SpeedUp()
	catch
		bRaised = 1
	done
	Then("one list has nothing to compare", bRaised, 1)
	bRaised = 0
	try
		StzListOfListsQ([ [ 1 ], [ 0 ] ]).SpeedUp()
	catch
		bRaised = 1
	done
	Then("dividing by a list that sums to zero is refused", bRaised, 1)
EndScenario()

Summary()
