load "stzlib.ring"

/*--------------
*/
o1 = new stzListOfNumbers([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
o1.Cumulate()
? @@( o1.Content() ) #--> [ 1, 2, 5, 9, 14, 20, 27, 35, 44 ]

/*--------------

? StzListOfNumbersQ( 12:22 ).IsContinuous()	#--> TRUE

/*--------------

? StzListOfNumbersQ( 1:5 ).Reversed() # --> 5:1

/*--------------

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

/*==================

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
