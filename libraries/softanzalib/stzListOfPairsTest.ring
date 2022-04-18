load "stzlib.ring"

/*------

o1 = new stzListOfPairs([
	[ 18, 22 ], [ 8, 12], [ 3, 5]
])



? @@( o1.Swapped() ) #--> [ [ 8, 12 ], [ 18, 22 ], [ 3, 5 ] ]

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

? @@( o1.ExpandedIfPairsOfNumbers() ) + NL
#--> [ [ 3, 4, 5 ], [ 8, 9, 10, 11, 12 ], [ 20, 21, 22, 23 ] ]

anPositions = o1.ExpandedIfPairsOfNumbersQ().MergeQ().RemoveDuplicatesQ().SortedInAscending()
? @@( anPositions ) #--> [ 3, 4, 5, 8, 9, 10, 11, 12, 20, 21, 22, 23 ]
