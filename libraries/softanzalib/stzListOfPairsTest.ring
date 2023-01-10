load "stzlib.ring"

/*-----------------

o1 = new stzListOfPairs([ [ 9, 10 ], [ 1, 2 ], [ 6, 6 ] ])
o1.SortInAscending()
? @@S( o1.Content() )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

/*-----------------

StartProfiler()

? Q([ [ 18, 22 ], [ 8, 12], [ 3, 5] ]).IsListOfPairs()

StopProfiler()
# Executed in 0.01 second(s)

/*-----------------
*/
StartProfiler()

o1 = new stzListOfPairs([ [ 18, 22 ], [ 8, 12], [ 3, 5] ])
? @@S( o1.Sorted() )
#--> [ [ 3, 5 ], [ 8, 12 ], [ 18, 22 ] ]

StopProfiler()

/*-----------------

o1 = new stzListOfPairs([
	1:2, 1:2, [9,9], 1:2, 1:2, [9,9], 1:2, 1:2, [9,9]
])


? o1.FindAll([9,9])
#--> [3, 6, 9]

# Note: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = [9,9]) 
#--> [3, 6]

? o1.NFirstOccurrencesXT(2, :Of = [9,9], :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = [9,9])
#--> [6, 9]

? o1.NLastOccurrencesXT(2, [9,9], :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesXT(2, :Of = [9,9], :StartingAt = 6)
#--> [6, 9]

? o1.LastNOccurrencesXT(2, :Of = [9,9], :StartingAt = 10)
#--> [6, 9]

/*------

o1 = new stzListOfPairs([ ["A", "B"], ["C", "♥"], ["E", "F"] ])
? o1.ContainsInAnyPair("♥") # TRUE

/*------

o1 = new stzListOfPairs([
	[ 18, 22 ], [ 8, 12], [ 3, 5]
])

? @@S( o1.Swapped() ) #--> [ [ 22, 18 ], [ 12, 8 ], [ 5, 3 ] ]

/*------

o1 = new stzListOfPairs([
	[ 3, 5], [ 8, 12], [ 18, 22 ]
])

? o1.IsListOfSections() 		 #--> TRUE
? o1.IsSortedListOfSections() 		 #--> TRUE
? o1.IsListOfSectionsSortedInAscending() #--> TRUE

/*------

o1 = new stzListOfPairs([
	[ 18, 22 ], [ 8, 12], [ 3, 5]
])

? o1.IsListOfSections() 		  #--> TRUE
? o1.IsSortedListOfSections() 		  #--> TRUE
? o1.IsListOfSectionsSortedInDescending() #--> TRUE

/*------------

o1 = new stzListOfPairs([
	[ 3, 5], [8, 12], [20, 23]
])

? @@S( o1.ExpandedIfPairsOfNumbers() ) + NL
#--> [ [ 3, 4, 5 ], [ 8, 9, 10, 11, 12 ], [ 20, 21, 22, 23 ] ]

anPositions = o1.ExpandedIfPairsOfNumbersQ().MergeQ().RemoveDuplicatesQ().SortedInAscending()
? @@S( anPositions ) #--> [ 3, 4, 5, 8, 9, 10, 11, 12, 20, 21, 22, 23 ]
