load "stzlib.ring"

/*===

pron()

? Intersection([
	[ "A", "A", "X", "B", "C" ],
	[ "B", "A", "C", "B", "A", "X" ],
	[ "C", "X", "Z", "A" ]
])
#--> [ "A", "X", "C" ]

proff()
# Executed in 0.04 second(s)

/*-----

pron()

? Intersection([ "A":"C", "A":"C", "A":"C" ])
#--> [ "A", "B", "C" ]

? Intersection([ "A":"C", "A":"B", "A":"C" ])
#--> [ "A", "C" ]

proff()

/*=====
*/
pron()

o1 = new stzListOfLists([ 1:3, 1:3, 1:3 ])
? o1.IsMadeOfSameList()
#--> TRUE

? StzListOfListsQ([ 1:3, 1:2, 1:3 ]).AllListsAreEqual()

#TODO : Add to stzList
#	AllNumbersAreEqual()
#	AllStringsAreEqual()
#	AllListsAreEqual()
#	AllObjectsAreEqual()

proff()
# Executed in 0.04 second(s)

/*=========

pron()

o1 = new stzListOfLists([ ["01","02"], ["16", "17"], ["23", "25"], ["08", "10"] ])

? @@( o1.SortedInAscending() )
#--> [ [ "01", "02" ], [ "08", "10" ], [ "16", "17" ], [ "23", "25" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "23", "25" ], [ "16", "17" ], [ "08", "10" ], [ "01", "02" ] ]

proff()
# Executed in 0.04 second(s)

/*=========

pron()

? @@( Association([ :of = [ :one, :two, :three ], :with = [1, 2, 3] ]) )
#--> [ [ "one", 1 ], [ "two", 2 ], [ "three", 3 ] ]

proff()
# Executed in 0.05 second(s)

/*-------------

pron()

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "I", "♥" ],
	[ "G", "H", "R" ],
	[ "J", "K", "I", "N", "G" ]
])

? @@(o1.FindExtraItems()) + NL
#--> [
#	[ 1, [ ] ],
#	[ 2, [ 3, 4 ] ],
#	[ 3, [ 3 ] ],
#	[ 4, [ 3, 4, 5, 6 ] ]
# ]

? @@( o1.ExtraItems() )
#--> [ [ ], [ "I", "♥" ], [ "R" ], [ "I", "N", "G" ] ]

proff()

/*=============

pron()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//o1.Flatten()
#--> Error message:
# Can't flatten the list of lists!
# Instead you can return a flattend copy of it using Flattened()

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in 0.04 second(s)

/*---------------

pron()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//o1.Merge()
#--> Error message:
# Can't merge the list of lists!
# Instead you can return a merged copy of it using Merged()

? @@( o1.Merged() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in 0.03 second(s)

#NOTE: You will understand the difference between Flatten() and Merge()
# by reading the fellowing two ewxamples...

/*---------------

pron()

o1 = new stzList([
	[1, 2],
	[3, [4, 5:7 ] ],
	8,
	[ [ 9, [10] ] ]
])

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

o1 = new stzList([ [1, 2], [3, [4]], 5 ])

? @@( o1.Merged() )
#--> [ 1, 2, 3, [ 4 ], 5 ]

proff()
# Executed in 0.03 second(s)

/*---------------

pron()

? @@( ListsMerge([ [3, 5], [7, [8]] ]) )
#--> [ 3, 5, 7, [ 8 ] ]

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

aMyLists = [
	[ "a", "ab", "b", "b" ],
	[ "a", "a", "ab", "abc", "b", "bc", "c" ],
	[ "ab", "xt", "b", "xt" ]
]

? @@( Intersection(aMyLists) ) # Same as CommonItems()
#--> [ "ab", "b" ]

proff()
# Executed in 0.07 second(s)

/*===============

pron()

o1 = new stzListOfLists([
	[ "Ring", "Ruby", "Python" ],
	[ "Julia", "Ring", "Go", "Python" ],
	[ "C#", "PHP", "Python", "Ring" ]
])

? o1.CommonItems() # Same as Intersection()
#--> [ "Ring", "Pyhton" ]

proff()
# Executed in 0.11 second(s)

/*-------------

pron()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3, "c" ])
? @@( o1.ToSet() )
#--> [ "a", "ab", "b", [ 1, 2, 3 ], "abc", "bc", "c" ]

proff()
# Executed in 0.17 second(s)

/*-------------

pron()

? Q([ "a", "ab", "b", [ 1, 2, 3 ] ]).ToSet()
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]

proff()
#--> Executed in 0.06 second(s)

/*=============== EXTENDING A LIST

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendTo(5)

? @@( o1.content() )
#--> [ "A", "B", "C", "", "" ]

proff()
# Executed in 0.03 second(s)

/*-------------

pron()

o1 = new stzList([ "A", "B", "C" ])
o1.ExtendXT( :ToPosition = 5, :Using = AHeart() )

? @@( o1.content() )
#--> [ "A", "B", "C", "♥", "♥" ]

proff()
# Executed in 0.04 second(s)

/*=============== EXTENDING THE LISTS OF A LIST OF LISTS

pron()

o1 = new stzListOfLists([ # or stzLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])
 
? o1.IsHomolog() # or o1.IsHomologuous() or o1.ListsHaveSameSize()
#--> FALSE

? o1.SizeOfLargestList()
#--> 4

o1.Extend()

? @@( o1.Content() )
#--> [
#	[ "A", "B",  "",  "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I",  "",  "",  "" ]
# ]

? o1.IsHomolog()
#--> TRUE

proff()
# Executed in 0.07 second(s)

/*---------------

pron()

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendXT(:Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥", "♥" ]
# ]

proff()
# Executed in 0.08 second(s)

/*---------------

pron()

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT( :Position = 6, :ByRepeatingItems ) # or :Using = :RepeatedItems

? @@( o1.Content() )
#--> [
#	[ "A", "B", "A", "B", "A", "B" ],
#	[ "C", "D", "E", "F", "C", "D" ],
#	[ "I", "I", "I", "I", "I", "I" ]
# ]

proff()
#--> Executed in 0.07 second(s)

/*---------------

pron()

o1 = new stzLists([ # or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT( :Position = 6, :Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥", "♥", "♥" ],
#	[ "C", "D", "E", "F", "♥", "♥" ],
#	[ "I", "♥", "♥", "♥", "♥", "♥" ]
# ]

proff()
# Executed in 0.10 second(s)

/*================= SHRINKING A LIST

pron()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
o1.ShrinkTo(3)

? o1.Content()
#--> [ "A", "B", "C" ]

proff()
# Executed in 0.03 second(s)

/*================= SHRINKING A LIST OF LISTS

pron()

o1 = new stzLists([
	[ "A", "B", "C" ],
	[ "D", "E", "F", "G" ],
	[ "H", "I" ]
])

o1.Shrink()

? @@( o1.Content() )
#--> [ [ "A", "B" ], [ "D", "E" ], [ "H", "I" ] ]

proff()
# Executed in 0.09 second(s)

/*-----------------

pron()

o1 = new stzLists([
	[ "A", "B", "C" ],
	[ "D", "E", "F", "G" ],
	[ "H", "I" ]
])

o1.ShrinkTo(1)

? @@( o1.Content() )
#--> [ [ "A" ], [ "D" ], [ "H" ] ]

proff()
# Executed in 0.12 second(s)

/*-----------------
*/
pron()

o1 = new stzLists([ # or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.AdjustXT(:To = 3, :Using = AHeart())

o1.Show()
#--> [
#	[ "A", "B", "♥" ],
#	[ "C", "D", "E" ],
#	[ "I", "♥", "♥" ]
# 

proff()
# Executed in 0.06 second(s)

/*=================

pron()

o1 = new stz2DList([	# Or stzListOfLists()
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? @@( o1.Shrinked() ) + NL
#--> [ [ "A" ], [ "C" ], [ "I" ] ]

? @@( o1.Extended() )
#--> [
#	[ "A", "B", "", "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "", "", "" ]
# ]

proff()
# Executed in 0.07 second(s)

/*=================

pron()

# You can extend a list of lists to any number of items like this:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> FALSE

o1.ExtendTo(4)
# By default, the items are extended using the NULL char
# Use ExtendToXT(n, char) to specify your own (next example)

? @@( o1.Content() )
#--> [
#	[ "A", "B",  "",  "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I",  "",  "",  "" ]
# ]

? o1.IsHomolog()
#--> TRUE

proff()
#--> Executed in 0.05 second(s)

/*---------------

pron()

# You can even extend to n items and specify
# the value of the item to extend them with, like this:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT(4, :Using = AHeart())

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*---------------

pron()

# If the lists are to be extended to a number
# smaller then the largest size in the list,
# then only the smaller lists extended:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> FALSE

o1.ExtendToXT(3, :Using = AHeart())
# Only the 1st and 3d lists are extended

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> FALSE

proff()
# Executed in 0.06 second(s)

/*---------------

pron()

# If the lists are to be extended to a number
# larger then the largest size in the list,
# then all the lists are extended:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> FALSE

o1.ExtendToXT(5, :Using = AHeart())
# Only the 1st and 3d lists are extended

? @@( o1.Content() )
#--> [
#	[ "A", "B", "♥", "♥", "♥" ],
#	[ "C", "D", "E", "F", "♥" ],
#	[ "I", "♥", "♥", "♥", "♥" ]
# ]

? o1.IsHomolog()
#--> TRUE

proff()
# Executed in 0.06 second(s)

/*==================

pron()

o1 = new stzLists([ 1:3, 1:5, 1:2 ])

? o1.Smallest()
#--> [1, 2]

? o1.SmallestSize()
#--> 2

? o1.FindSmallest()
#--> 3

? "--"

? o1.Largest()
#--> [1,2, 3, 4, 5]

? o1.LargestSize()
#--> 5

? o1.FindLargest()
#--> 2

proff()
#--> Executed in 0.03 second(s)

/*-------------------

pron()

o1 = new stzLists([ 1:2, 1:5, 1:3, 1:5 ])

? @@( o1.FindLargestLists() ) + NL
#--> [2, 4]

? @@( o1.LargestLists() ) + NL
#--> [ [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ] ]

? @@( o1.LargestListsZ() )
# [ [ [ 1, 2, 3, 4, 5 ], 2 ], [ [ 1, 2, 3, 4, 5 ], 4 ] ]

proff()
# Executed in 0.07 second(s)

/*-------------------

pron()

o1 = new stzLists([ 1:2, 1:5, 1:3, 1:2 ])

? @@( o1.FindSmallestLists() ) + NL
#--> [1, 4]

? @@( o1.SmallestLists() ) + NL
#--> [ [1, 2], [1, 2] ]

? @@( o1.SmallestListsZ() )
#--> [ [ [ 1, 2 ], 1 ], [ [ 1, 2 ], 4 ] ]

proff()
# Executed in 0.07 second(s)

/*==================

pron()

o1 = new stzLists([ "A":"C", 1:3 ])
? @@( o1.Associated() )
#--> [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

proff()
# Executed in 0.03 second(s)

/*------------------

pron()

? @@( Association([ :Of = ["A", "B", "C"], :And = [1, 2, 3] ]) )
#--> [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ]

proff()
# Executed in 0.03 second(s)

/*==================

pron()

o1 = new stzList([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])

? o1.EachItemIsA(:ListOfNumbers)
#--> TRUE

o1 = new stzList([ "A":"C", "E":"D", "G": "Y" ])
? o1.EachItemIs(:ListOfStrings)
#--> TRUE

? o1.EachItemIs(:ListOfChars)
#--> TRUE

proff()
# Executed in 0.37 second(s)

/*==================

pron()

o1 = new stzList([ "A", 1:3, "B", 4:7, 8:10 ])
? @@( o1.MergeQ().Content() )
#--> [ "A", 1, 2, 3, "B", 4, 5, 6, 7, 8, 9, 10 ]

o1 = new stzList([ "A", 1:3, "B", 4:7, [ "C", 99:100, "D" ], 8:10 ])
? @@( o1.MergeQ().Content() )
#--> [ "A", 1, 2, 3, "B", 4, 5, 6, 7, "C", [ 99, 100 ], "D", 8, 9, 10 ]

o1 = new stzList([ "A", 1:3, "B", 4:7, [ "C", 99:100, "D" ], 8:10 ])
? @@( o1.FlattenQ().Content() )
#--> [ "A", 1, 2, 3, "B", 4, 5, 6, 7, "C", 99, 100, "D", 8, 9, 10 ]

proff()
# Executed in 0.04 second(s)

/*-----------------

pron()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10 ])

//? @@( o1.MergeQ().Content() )
#--> Error: Can't merge the list of lists! Instead
# you can return a merged copy of it using Merged()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10, [ "A", 0:1, "B" ] ])
? @@( o1.Merged() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "A", [ 0, 1 ], "B" ]

//? @@( o1.FlattenQ().Content() )
#--> Error: Can't flatten the list of lists! Instead
# you can return a flattened copy of it using Merged()

o1 = new stzListOfLists([ 1:3, 4:7, 8:10, [ "A", 0:1, "B" ] ])
? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "A", 0, 1, "B" ]

proff()
# Executed in 0.06 second(s)

/*==================

pron()

o1 = new stzListOfLists([
	1:2, 1:3, [9,9,9], 1:4, 1:5, [9,9,9], 1:7, 1:8, [9,9,9]
])


? o1.FindAll([9,9,9])
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = [9,9,9]) 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = [9,9,9], :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = [9,9,9])
#--> [6, 9]

? o1.NLastOccurrencesXT(2, [9,9,9], :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesXT(2, :Of = [9,9,9], :StartingAt = 6)
#--> [6, 9]

? @@(o1.LastNOccurrencesXT(1, :Of = [9,9,9], :StartingAt = 9))
#--> [9]

proff()
# Executed in 0.15 second(s)

/*-----------
*/
pron()

o1 = new stzString("[4, 5, 6, 7, 8]")
/*
? @@(o1.RepeatedLeadingChars())
#--> ""

? o1.ContainsLeadingAndTrailingChars()
#--> FALSE

? o1.FirstAndLastChars()
#--> [ "[", "]" ]

? o1.Bounds()
#--> [ "[", "]" ]
*/

//? @@( o1.FindTheseBoundsAsSections("[[", "]") )
#--> [ [ ], [ 1, 1 ] ]

? o1.FindTheseBoundsAsSections("[", "]")
#--> [ [ ], [ 1, 1 ] ]

//o1.RemoveTheseBounds("[","]")
? o1.Content()

proff()


/*-----------

*/

pron()

? @@( StzListQ( 4:8 ).ToListInAString() )
#--> "[ 4, 5, 6, 7, 8 ]"

? @@( StzListQ( 4:8 ).ToListInAStringInShortForm() )
#--> '4:8'

proff()
# Executed in 0.50 second(s)

/*-----------

o1 = new stzListOfLists([ 1:3, 4:5, 6:7 ])
? @@( o1.ToListInString() )
#--> "[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7 ] ]"

? @@( o1.ToListInStringInShortForm() )
#--> [ "1:3", "4:5", "6:7" ]

/*----------

o1 = new stzListOfLists([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])

//StartTimer()

? o1.NthList(4) 			#--> [3, 5]

? @@( o1.ItemsAtPositionN(2) ) 	#--> [ 2, 5, 0, 5, 6 ]

? @@( o1.ListsOfSize(2) )		#--> [ [9,0], [3,5] ]
? o1.PositionsOfListsOfSize(2)		#--> [     3,    4  ]

? @@( o1.Sizes() )			#--> [ 3, 5, 2, 2, 3 ]
? o1.SmallestSize()			#--> 2
? o1.BiggestSize()			#--> 5
? @@( o1.SmallestLists() )		#--> [ [9,0], [3,5] ]

? o1.PositionsOfSmallestLists()		#--> [ 3, 4 ]

? @@( o1.ListsW('Q(@list).Size() <= 3') )
#--> [ [ 1, 2, 3 ], [ 9, 0 ], [ 3, 5 ], [ 5, 6, 7 ] ]

? @@( o1.Yield('{ len(@list) }') ) 	#--> [ 3, 5, 2, 2, 3 ]

//? ElapsedTime()

/*----------

// Merging many lists in one list
o1 = new stzListOfLists([ 1:3, 4:7, 8:9, [10, 11:13] ])

? @@( o1.Flattened() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ]

/*================

StartTimer()

o1 = new stzListOfLists([
	[ 1, 2, 3 ],
	[ 4, 5, 6, 7, 8 ],
	[ 9, 0 ],
	[ 3, 5 ],
	[ 5, 6, 7 ]
])

? @@( o1.ListsOfSizeN(2) )
#--> [ [ 9, 0 ], [ 3, 5 ] ]

? ElapsedTime()
#--> 0.03 seconds

/*===============

// in this example, we are going to index those three lists:

a1 = [ "A", "B", "A" ]
a2 = [ "A", "B", "C" ]
a3 = [ "C", "D", "A" ]

o1 = new stzListOfLists([ a1, a2, a3 ])

# First, we index them on the positions occuppied by each item
# in each list

aIndex = o1.IndexBy(:Position)
? @@( aIndex ) + NL
#--> [
#	[ "A", [ [1,1], [1,3], [2,1], [3,3] ] ],
#	[ "B", [ [1,2], [2,2] ] ],
#	[ "C", [ [2,3], [3,1] ] ],
#	[ "D", [ [3,2] ] ]
# ]	

? @@( aIndex["A"] ) + NL # Showing just the index of "A"
#--> [ [1,1], [1,3], [2,1], [3,3] ]

// And then, we index them by number of occurrence of each
# character in each list:

aIndex = o1.IndexBy(:NumberOfOccurrence)
? @@( aIndex ) + NL
#--> [
#	[ "A", [2, 1, 1] ],
#	[ "B", [1, 1, 0] ],
#	[ "C", [0, 1, 1] ],
#	[ "D", [0, 0, 1] ]
# ]	

? @@( aIndex["C"] ) # howing just the index of "C"
#--> [0, 0, 1]

