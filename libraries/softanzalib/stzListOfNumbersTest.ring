load "stzlib.ring"


/*--------------

? StzListOfNumbersQ( 1:5 ).Reversed() # --> 5:1

/*--------------
*/
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

/*--------------

StzListOfNumbersQ([ 2, 4, 6 ]) {
	AddToEach(3)
	? Content() # --> [ 5, 7, 9 ]
}

? StzListOfNumbersQ([ 2, 4, 6 ]).AddedToEach(3) # --> [ 5, 7, 9 ]

/*--------------

?  MultiplicationsYieldingN(9) # --> [ [ 1, 9 ], [ 3, 3 ], [ 9, 1 ] ]
?  MultiplicationsYieldingN_WithoutCommutation(9) # --> [ [ 1, 9 ], [ 3, 3 ] ]

/*--------------

o1 = new stzListOfNumbers([ 12, 10, 98, 23, 98, 7 ])
? o1.Max()
? o1.FindMax()

? StzListQ([ 12, 10, 98, 23, 98, 7 ]).SortedInAscending()


/*--------------

o1 = new stzListOfNumbers(1:8)
o1.AddToEveryItem(2)
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
