load "stzlib.ring"

/*-------

pron()

o1 = new stzListOfPairs([ [1.0, 2.0], [16.0, 17.34], [23.0, 25], [8.20, 10.0] ])

? @@( o1.SortedInAscending() ) + NL
#--> [ [ 1, 2 ], [ 8.20, 10 ], [ 16, 17.34 ], [ 23, 25 ] ]

? @@( o1.SortedInDescending() )
#--> [ [ 23, 25 ], [ 16, 17.34 ], [ 8.20, 10 ], [ 1, 2 ] ]

proff()

/*-----

pron()

o1 = new stzListOfPairs([ [1,2], [8, 10], [16, 17], [23, 25] ])

? @@( o1.SortedInAscending() )
#--> [ [ 1, 2 ], [ 8, 10 ], [ 16, 17 ], [ 23, 25 ] ]

? @@( o1.SortedInDescending() )
#--> [ [ 23, 25 ], [ 16, 17 ], [ 8, 10 ], [ 1, 2 ] ]

proff()
# Executed in 0.20 second(s)

/*------------
*/
pron()

o1 = new stzListOfPairs([ ["01","02"], ["16", "17"], ["23", "25"], ["08", "10"] ])

? @@( o1.SortedInAscending() ) + NL
#--> [ [ "01", "02" ], [ "08", "10" ], [ "16", "17" ], [ "23", "25" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "23", "25" ], [ "16", "17" ], [ "08", "10" ], [ "01", "02" ] ]

proff()
# Executed in 0.03 second(s)

/*-----------

pron()

o1 = new stzList([
	'[ 6, 1 ]', '[ 6, 3 ]', '[ 6, 9 ]', '[ 5, 3 ]'
])

? o1.Sorted()

proff()

/*-----------

pron()

o1 = new stzListOfPairs([
	[ 6, 1 ], [ 6, 3 ], [ 6, 9 ], [ 5, 3 ]
])

? @@( o1.Sorted() )
#--> [ [ 5, 3 ], [ 6, 1 ], [ 6, 3 ], [ 6, 9 ] ]

proff()
# Executed in 0.04 second(s)

/*-----------

pron()

o1 = new stzListOfPairs([
	[ 6, 1 ], [ 3, 7 ], [ 2, 5 ], [ 4, 1 ]
])

? @@( o1.Sorted() )
#--> [ [ 2, 5 ], [ 3, 7 ], [ 4, 1 ], [ 6, 1 ] ]

proff()
# Executed in 0.05 second(s)

/*-----------
*/
pron()

o1 = new stzListOfPairs([
	[ 2, 1 ], [ 2, 3 ], [ 2, 5 ], [ 4, 1 ], [ 2, 4 ]
])

? @@( o1.SortedInDescending() )
#--> [ [ 4, 1 ], [ 2, 5 ], [ 2, 4 ], [ 2, 3 ], [ 2, 1 ] ]

proff()
# Executed in 0.05 second(s)

/*===========

pron()

? Q("--♥-♥--").ContainsXT( 2, "♥")
#--> TRUE

? Q("--♥-♥--").ContainsXT( :Exactly = 2, "♥") # Or ContainsExactly(2, "♥")
#--> TRUE

? Q("--♥-♥--").ContainsXT( :MoreThen = 1, "♥") # Or ContainsMoreThen(1, "♥")
#--> TRUE

? Q("--♥-♥--").ContainsXT( :LessThen = 3, "♥") # ContainsLessThen(3, "♥")
#--> TRUE

proff()
# Executed in 0.04 second(s)

/*------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.Sort() # Or SortInAscending()
? @@(o1.Content())
#--> [ [ 3, 1 ], [ 4, 7 ], [ 8, 9 ] ]

proff()
#--> Executed in 0.05 second(s)

/*------------

pron()

o1 = new stzListOfPairs([ [ 1, 2 ], [ 4, 3 ], [ 6, 5 ] ])
o1.SortInside()
? @@( o1.Content() )
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ]

proff()

/*------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInDescending()
? @@(o1.Content())
#--> [ [ 8, 9 ], [ 4, 7 ], [ 3, 1 ] ]

proff()
#--> Executed in 0.05 second(s)

/*------------

pron()

o1 = new stzListOfPairs([ [4, 7], [3, 1], [8, 9] ])
o1.SortInSideInDescending()
? @@(o1.Content())
#--> [ [ 7, 4 ], [ 3, 1 ], [ 9, 8 ] ]

proff()
#--> Executed in 0.06 second(s)

/*------


/*======

pron()

o1 = new stzList([ "ring", "php", "ring", "ring", "_" ])
? o1.Find("ring")
#--> [1, 3, 4]

proff()
# Executed in 0.06 second(s)

/*------------

pron()

o1 = new stzListOfPairs([
	[ "♥", "_"],
	[ "_", " "],
	[ "♥", "_"],
	[ "♥", " "],
	[ "_", "_"]
])

? o1.FindInFirstItems("♥")
#--> [1, 3, 4]

? o1.FindInSecondItems("_")
#--> [1, 3, 5]

proff()
# Executed in 0.10 second(s)

/*===================

pron()

? StzCCodeQ('[ @CurrentItem, @NextItem]').Transpiled()
#--> [  @CurrentItem, This[@i + 1] ]

proff()
# Executed in 0.96 second(s)

/*----------------- ERR

pron()

#                  1  2 3  4 5 6  7
o1 = new stzList([ 1, 3,4, 7,8,9, 12 ])
? StzCCodeQ('This[@i+2]').ExecutableSection()
#--> [1, -3]

? @@( o1.Section(1, -3) )
#--> [ 1, 3, 4, 7, 8 ]

? @@(o1.YieldXT('[ @CurrentItem, @NextItem ]'))
#--> [ [ 1, 4 ], [ 3, 7 ], [ 4, 8 ], [ 7, 9 ], [ 8, 12 ] ]

//? @@( o1.FindW('@CurrentItem = @NextItem') )

? @@( o1.YieldW('[ This[@i], This[@i+1] ]', :Where = 'This[@i] = This[@i+1]+1') )

proff()
/*-----------------

StartProfiler()

o1 = new stzListOfPairs([
	[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15]
])

? @@( o1.Yield('[ This[@i][2], This[@i+1][1] ]') )
#--> [ [ 4, 6 ], [ 8, 9 ], [ 10, 12 ], [ 13, 13 ] ]

? @@( o1.YieldW('[ This[@i][2], This[@i+1][1] ]', :Where = 'Q(@i).IsEven()') )
#--> [ [ 8, 9 ], [ 13, 13 ] ]

? @@( o1.YieldW('[ This[@i][2], This[@i+1][1] ]',
		:Where = 'This[@i][2] = This[@i+1][1]-1') )

/*
o1.MergeContiguous()
? o1.Content()
#--> [ [1, 4], [6, 10], [12, 15] ]

StopProfiler()

/*-----------------

o1 = new stzListOfPairs([ [ 9, 10 ], [ 1, 2 ], [ 6, 6 ] ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

/*-----------------

StartProfiler()

? Q([ [ 18, 22 ], [ 8, 12], [ 3, 5] ]).IsListOfPairs()

StopProfiler()
# Executed in 0.01 second(s)

/*-----------------

StartProfiler()

o1 = new stzListOfPairs([ [ 18, 22 ], [ 8, 12], [ 3, 5] ])
? @@( o1.Sorted() )
#--> [ [ 3, 5 ], [ 8, 12 ], [ 18, 22 ] ]

StopProfiler()

/*-----------------

o1 = new stzListOfPairs([
	1:2, 1:2, [9,9], 1:2, 1:2, [9,9], 1:2, 1:2, [9,9]
])


? o1.FindAll([9,9])
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString, 
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

pron()

o1 = new stzListOfPairs([
	[ 18, 22 ], [ 8, 12], [ 3, 5]
])

? @@( o1.Swapped() )
#--> [ [ 22, 18 ], [ 12, 8 ], [ 5, 3 ] ]

proff()

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

anPos = o1.ExpandedIfPairsOfNumbersQ().MergeQ().RemoveDuplicatesQ().SortedInAscending()
? @@( anPos ) #--> [ 3, 4, 5, 8, 9, 10, 11, 12, 20, 21, 22, 23 ]
