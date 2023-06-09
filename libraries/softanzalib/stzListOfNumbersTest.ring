load "stzlib.ring"

/*===============

pron()

o1 = new stzListOfNumbers([ 2, 7, 18, 18, 10, 25, 4 ])

? @@( o1.Neighbors(10) )
#--> [ 7, 18 ]

? @@( o1.Neighbors(25) )
#--> [18, NULL ]

? @@( o1.Neighbors(2) )
#--> [ NULL, 4 ]

? @@( o1.Neighbors(88) )
#--> [ 25, NULL ]

? @@( o1.FarthestNighbors(10) ) # Misspelled form of FarthestNeighbors()
				# You can use the short form FNeighbors()
#--> [ 2, 25 ]

proff()
# Executed in 0.15 second(s)

/*-------------

pron()

o1 = new stzListOfNumbers([ 2, 7, 18, 18, 10, 12, 25, 4 ])

? o1.Nearest(88)
#--> 25

? o1.Nearst(17) # NOTE this is a misspelled form of Nearest()
#--> 18

? o1.NearestTo(10)
#--> 12

? o1.Nearest( :To = 12 )
#--> 10

? o1.Nearest(2)
#--> 4

? o1.Nearest(1)
#--> 2

proff()
# Executed in 0.18 second(s)

/*-------------

pron()

o1 = new stzListOfNumbers([ 4, 8, 10, 16, 18 ])

? o1.Farthest(88)
#--> 4

? o1.Farthest(17) 
#--> 4

? o1.FarthestTo(10)
#--> 18

? o1.Farthest( :To = 12 )
#--> 4

? o1.Farthest(2)
#--> 18

? o1.Farthest(1)
#--> 18

proff()
# Executed in 0.13 second(s)

/*-----------------

pron()

o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])

? @@( o1.NeighborsOf(5) )
#--> [ NULL, NULL ]

? @@( o1.Neighbors(11) )
#--> [ 6, 18 ]

? @@( o1.Neighbors(1) )
#--> [ NULL, 4 ]

? @@( o1.Neighbors(22) )
#--> [ 18, NULL ]

proff()
# Executed in 0.10 second(s)

/*-----------------

pron()

o1 = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])

? @@( o1.FarthestNeighborsOf(5) ) # or FNeighborsOf(5)
#--> [ NULL, NULL ]

? @@( o1.FNeighbors(11) )
#--> [ 1, 18 ]

? @@( o1.FNeighbors(1) )
#--> [ NULL, 18 ]

? @@( o1.FNeighbors(18) )
#--> [ 1, NULL ]

proff()
# Executed in 0.10 second(s)

/*-------------

pron()

o1 = new stzListOfNumbers([ 2, 4, 7, 10, 12, 15, 18, 25 ])

? o1.FarthestToXT(12, :Coming = :BeforeIt)
#--> 2

? @@( o1.FarthestToXT(12, :Coming = :AfterIt) )
#--> 25

? @@( o1.FarthestXT( :To = 2, :Before) )
#--> NULL

? @@( o1.FarthestToXT(17, :ComingAfterIt) )
#--> NULL

? @@( o1.FarthestToXT(25, :ComingAfterIt) )
#--> NULL

proff()
# Executed in 0.30 second(s)

/*-------------

pron()

o1 = new stzListOfNumbers([ 2, 4, 7, 10, 12, 15, 18, 25 ])

? o1.NearestToXT(12, :Coming = :BeforeIt)
#--> 2

? @@( o1.NearestToXT(12, :Coming = :AfterIt) )
#--> 25

? @@( o1.NearestXT( :To = 2, :Before) )
#--> NULL

? @@( o1.NearestToXT(17, :ComingAfterIt) )
#--> NULL

? @@( o1.NearestToXT(25, :ComingAfterIt) )
#--> NULL

proff()
# Executed in 0.30 second(s)

/*===========

pron()

? Min([1, 10])
#--> 1

? Max([1, 10])
#--> 10

proff()
# Executed in 0.04 second(s)

/*===============

? Sum([ 2, 3, 2 ])
#--> 7

? Product([2, 3, 2])
#--> 12

/*============

StartProfiler()

o1 = new stzListOfNumbers([ 1, 2, 999, 4, 5, 999, 7, 8, 999 ])

? @@( o1.FindAll(999) )
#--> [3, 6, 9]

# Note: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? @@( o1.NFirstOccurrences(2, :Of = 999) )
#--> [3, 6]

? @@( o1.NFirstOccurrencesXT(2, :Of = 999, :StartingAt = 1) )
#--> [3, 6]

? @@( o1.NLastOccurrences(2, :Of = 999) )
#--> [6, 9]

? @@( o1.NLastOccurrencesXT(2, 999, :StartingAt = 1) )
#--> [6, 9]

? @@( o1.NFirstOccurrencesXT(2, :Of = 999, :StartingAt = 6) )
#--> [6, 9]

? @@( o1.LastNOccurrencesXT(1, :Of = 999, :StartingAt = 9) )
# ERROR : Array Access (Index out of range) ! In method section() in tzList.ring
#--> [ 9 ]

StopProfiler()
# Executed in 0.44 second(s)

/*===============

pron()

? StzListOfNumbersQ( 12:22 ).SortingOrder()
#--> :Ascending

? StzListOfNumbersQ( 17:8 ).SortingOrder()
#--> :Descending

proff()
# Executed in 0.15 second(s)

/*==============

pron()

? StzListOfNumbersQ( 12:22 ).IsContiguous()
#--> TRUE

? StzListOfNumbersQ( 17:8 ).IsContiguous()
#--> TRUE

? StzListOfNumbersQ([10, 12, 18]).IsContiguous()
#--> FALSE

? StzListOfNumbersQ([10, 11, 10]).IsContiguous()
#--> FALSE

proff()
# Executed in 0.03 second(s)

/*========

pron()

o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ])

o1.Cumulate()

? @@( o1.Content() )
#--> [ 1, 2, 5, 9, 14, 20, 27, 35, 44 ]

proff()
# Executed in 0.03 second(s)

/*========

pron()

? StzListOfNumbersQ( 1:5 ).Reversed()
#--> 5:1

proff()
# Executed in 0.03 second(s)

/*========
*/
pron()

StzListOfNumbersQ([ 2, 10, 7, 4, 19, 7, 19 ]) {

	# Let's play with max numbers in the list

	? Max() + NL 	# --> 19
	? FindMax() 	# --> [ 5, 7 ]

	? MaxNumbers(3) # --> [ 19, 10, 7 ]
	# You can alos say: ? Top(3)


	? FindMaxNumbers(3) # --> [ 2, 3, 5, 6, 7 ]
	# You can also say: ? FindTop(3)

	? MaxNumbersAndTheirPositions(3)
	# --> [ "19" = [ 5, 7 ], "10" = [ 2 ], "7" = [ 3, 6 ] ]
	# You can also say: ? TopNumbersAndTheirPositions(3)

	# Let's do the same with the min numbers

	? Min() + NL	# --> 2
	? FindMin()	# --> [ 1 ]

	? MinNumbers(3)     # --> [ 2, 4, 7 ]
	? FindMinNumbers(3) # --> [ 1, 3, 4, 6 ]

}

proff()

/*==================

? StzListOfNumbersQ([ 1, 2, 3 ]).AddedToEach(5)
#--> [6, 7, 8]

/*-----------------

# Adding a number to each number in the list of numbers

StzListOfNumbersQ([ 1, 2, 3 ]) {
	? @@( Content() ) # --> [ 1, 2, 3 ]
 
	AddToEach(3)
	? @@( Content() ) # --> [ 4, 5, 6 ]

	MultiplyEachBy(3)
	? @@( Content() ) # --> [ 12, 15, 18 ]

	DivideEachBy(3)
	? @@( Content() ) # --> [ 4, 5, 6 ]
}

/*-------------------

# Adding many numbers, one by one, to the list of numbers

StzListOfNumbers([ 2, 4, 8 , 10 , 12 ]) {

	AddManyOneByOne([ 8, 6, 2, 0, -2 ])
	? @@( Content() )	#--> [ 10, 10, 10 , 10 , 10 ]

	SubstractManyOneByOne([ 5, 5, 5, 5, 5 ])
	? @@( Content() ) # --> [ 5, 5, 5, 5, 5 ]

	MultiplyByManyOneByOne([ 1, 2, 3, 4, 5 ])
	? @@( Content() ) # --> [ 5, 10, 15, 20, 25 ]

	DivideByManyOneByOne([ 5, 5, 5, 5, 5 ])
	? @@( Content() ) # --> [ 1, 2, 3, 4, 5 ])

}

/*-------------------

# Adding a number to each number verifying a given condition

o1 = new stzListOfNumbers([ 4, 7, 36, 9, 20 ])
o1.AddToEachW( 1, :Where = '{ Q(@number).IsDividableBy(4) and @number <= 20 }' )
? @@(o1.Content()) # --> [ 5, 7, 36, 9, 21 ]

/*-------------------

o1 = new stzListOfNumbers([ 4, 14, 24, 34 ])
o1.SubstractFromEachW( 10, :Where = '{ @number > 20 }' )
? @@(o1.Content()) # --> [ 4, 14, 14, 24 ]

/*-------------------

o1 = new stzListOfNumbers([ 5, 15, 25, 35 ])
o1.DivideEachByW( 5, :Where = '{ @number > 20 }' )
? @@(o1.Content()) # --> [ 5, 15, 5, 7 ]

/*======

?  MultiplicationsYieldingN(9) # --> [ [ 1, 9 ], [ 3, 3 ], [ 9, 1 ] ]
?  MultiplicationsYieldingN_WithoutCommutation(9) # --> [ [ 1, 9 ], [ 3, 3 ] ]

/*--------------

o1 = new stzListOfNumbers([ 12, 10, 98, 23, 98, 7 ])
? o1.Max()
? o1.FindMax()

? StzListQ([ 12, 10, 98, 23, 98, 7 ]).SortedInAscending()


/*--------------

o1 = new stzListOfNumbers(1:8)
o1.AddToEveryNumber(2)
? ListToCode( o1.Content() ) # --> [ 3, 4, 5, 6, 7, 8, 9, 10 ]

/*--------------

o1 = new stzListOfNumbers(1:8)
o1.SubstractFromEveryItem(2)
? ListToCode( o1.Content() ) # --> [ -1, 0, 1, 2, 3, 4, 5, 6 ]

/*---------------
o1 = new stzListOfNumbers(1:8)

? o1.sum() // --> 36

? o1.Product() // --> 40320

? o1.Max() // --> 8

? o1.Mean() // --> 4.5

? o1.ContainsADividableNumberBy(2) --> TRUE

? o1.DividableNumbersBy(2) # --> [ 2, 4, 6, 8 ]

? o1.Clip(3,5) // --> [ 3, 3, 3, 4, 5, 5, 5, 5 ]

? o1.UpdateSectionWith(3, 5, 2) // --> [ 1, 2, 2, 2, 2, 6, 7, 8 ]
