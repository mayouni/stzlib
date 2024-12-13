load "../max/stzmax.ring"

/*====

profon

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.Randomize()
? @@( o1.Content() )
#--> [ 1, "A", 4, 3, "D", "C", "B", 2 ]
#--> [ 1, "B", 2, "A", "C", 4, "D", 3 ]
#--> [ "B", "D", 2, 3, 4, 1, "A", "C" ]

proff()

/*====

profon

o1 = new stzList([ "A", "B", 30, 40, 50, 60, "A", "B", "C" ])
o1.RandomizeNumbers()
? @@( o1.Content() )
#--> [ "A", "B", 30, 50, 40, 60, "A", "B", "C" ]
#--> [ "A", "B", 30, 40, 60, 50, "A", "B", "C" ]
#--> [ "A", "B", 30, 50, 60, 40, "A", "B", "C" ]

proff()

#--

profon

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeStrings()
? o1.Content()
#--> [ 1, 2, 3, 4, "B", "C", "D", "A" ]

proff()
#--> Executed in 0.03 second(s)

#--

profon

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])

o1.RandomizeSection(1, 4)
? @@( o1.Content() )
#--> [ 1, 4, 2, 3, "A", "B", "C", "D" ]
#--> [ 2, 1, 3, 4, "A", "B", "C", "D" ]
#--> [ 4, 3, 1, 2, "A", "B", "C", "D" ]

proff()
#--> Executed in 0.04 second(s)

/*--

profon

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeSection(5, 8)
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, "A", "C", "D", "B" ]
#--> [ 1, 2, 3, 4, "C", "A", "D", "B" ]
#--> [ 1, 2, 3, 4, "B", "A", "C", "D" ]

proff()
# Executed in 0.04 second(s)

/*--

profon

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", 8, 9, 10, "D" ])

o1.RandomizeSections([ [1,4], [8,10] ])
? @@( o1.Content() )
#--> [ 1, 2, 4, 3, "A", "B", "C", 10, 8, 9, "D" ]
#--> [ 2, 1, 3, 4, "A", "B", "C", 9, 8, 10, "D" ]
#--> [ 2, 3, 4, 1, "A", "B", "C", 9, 8, 10, "D" ]

proff()
# Executed in 0.03 second(s)

/*--

profon

o1 = new stzList([ 1, 2, "A", "B", "C", 6, 7, "D", "E", "F", "G" ])

o1.RandomizeStrings()
? @@( o1.Content() )
#--> [ 1, 2, "C", "A", "B", 6, 7, "D", "F", "G", "E" ]
#--> [ 1, 2, "A", "B", "C", 6, 7, "D", "E", "G", "F" ]
#--> [ 1, 2, "B", "A", "C", 6, 7, "F", "G", "E", "D" ]

proff()
# Executed in 0.03 second(s)

/*--

profon

o1 = new stzList([ "A", "B", 1:3, 4:5, 6:8, "C", 9:10, 11:12 ])
o1.RandomiseLists() # Or ShuffleLists()
? @@( o1.Content() )
#--> [ "A", "B", [ 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ], "C", [11, 12 ], [ 9, 10 ] ]
#--> [ "A", "B", [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ], "C", [ 9, 10 ], [ 11, 12 ] ]
#--> [ "A", "B", [ 4, 5 ], [ 6, 7, 8 ], [ 1, 2, 3 ], "C", [ 9, 10 ], [ 11, 12 ] ]

proff()
# Executed in 0.03 second(s)

/*----
profon

Q("123456789") {

	? @@( ARandomSection() ) + NL # Or ASection() or ASubString etc.
	#--> "234"

	? @@( ARandomSectionZ() ) + NL
	#--> [ "678", [ 6, 8 ] ]

	? @@( SomeRandomSections() ) + NL
	#--> [ "345678", "4567" ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [ [ "3456", 3 ], [ "45", 4 ] ]

	? @@( SomeRandomSectionsZZ() )
	#--> [
	# 	[ "23456", [ 2, 6 ] ],
	# 	[ "12", [ 1, 2 ] ],
	# 	[ "78", [ 7, 8 ] ],
	# 	[ "34", [ 3, 4 ] ],
	# 	[ "89", [ 8, 9 ] ],
	# 	[ "4567", [ 4, 7 ] ],
	# 	[ "56", [ 5, 6 ] ]
	# ]
}

proff()
# Executed in 7.76 second(s)

/*---

profon

Q([ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]) {

	? @@( ARandomSection() ) + NL
	#--> [ "7", "8" ]

	? @@( ARandomSectionZ() ) + NL
	#--> [ [ "3", "4", "5", "6", "7", "8" ], 3 ]

	? @@( ARandomSectionZZ() ) + NL
	#--> [ [ "1", "2", "3", "4", "5", "6" ], [ 1, 6 ] ]


	? @@( SomeRandomSections() ) + NL
	#--> [
	# 	[ "1", "2", "3", "4", "5", "6" ],
	# 	[ "5", "6", "7", "8", "9" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8", "9" ],
	# 	[ "8", "9" ], [ "4", "5", "6" ]
	# ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [
	# 	[ [ "5", "6", "7", "8" ], 5 ],
	# 	[ [ "1", "2", "3", "4", "5", "6", "7" ], 1 ]
	# ]

	? @@( SomeRandomSectionsZZ() ) + NL
	#--> [
	# 	[ [ "6", "7", "8" ], [ 6, 8 ] ],
	# 	[ [ "7", "8" ], [ 7, 8 ] ]
	# ]

	? @@( NRandomSections(2) ) + NL
	#--> [ [ "1", "2", "3", "4", "5" ], [ "4", "5", "6" ] ]

	? @@( NRandomSectionsZ(2) ) + NL
	#--> [ [ [ "3", "4", "5", "6" ], 3 ], [ [ "8", "9" ], 8 ] ]

	? @@( NRandomSectionsZZ(2) )
	#--> [
	# 	[ [ "4", "5" ], [ 4, 5 ] ],
	# 	[ [ "1", "2", "3", "4" ], [ 1, 4 ] ]
	# ]
}

proff()
# Executed in 0.05 second(s)

/*---

profon

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? NRandomItems(3)
	#--> [ "A", "S", "Z" ]

	? @@( NRandomItemsZ(3) )
	#--> [ [ "S", 1 ], [ "A", 8 ], [ "N", 6 ] ]
}

proff()

/*----

profon

Q("SOFTANZA") {

	? ARandomPosition()
	#--> 8

	? ARandomChar()
	#--> T

	? ARandomPositionGreaterThan(4)
	#--> 8

	? ARandomCharAfterPosition(4)
	#--> A

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomCharExcept("A")
	#--> S

	? ARandomPositionLessThan(4)
	#--> 2

	? ARandomCharBefore(4)
	#--> S

	? ARandomCharAfter("T")
	#--> N

	? ARandomCharBefore("T")
	#--> S

}

proff()
# Executed in 0.04 second(s)

/*-------

profon

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? ARandomPosition()
	#--> 3

	? ARandomItem()
	#--> S

	? ARandomPositionGreaterThan(4)
	#--> 5

	? ARandomItemAfterPosition(4)
	#--> N

	? ARandomPositionExcept(5)
	#--> 1

	? ARandomItemExcept("A")
	#--> Z

	? ARandomPositionLessThan(4)
	#--> 3

	? ARandomItemBeforePosition(4)
	#--> O

	? ARandomItemAfter("T")
	#--> A

	? ARandomItemBefore("T")
	#--> O

}

proff()
# Executed in 0.04 second(s)

/*=====

profon

? Some( NumbersIn( -5 : 5 ) )
#--> [ -1, -4, -5, 3 ]

? Few( NumbersIn( -5 : 5 ) )
#--> [ 0, -4 ]

? All( EvenNumbersIn( -5 : 5 ) )
#--> [ -4, -2, 0, 2, 4 ]

? Half( OddNumbersIn( -5 : 5 ) )
#--> [ -5, 1, 3 ]

? Most( PositiveNumbersIn( -5 : 5 ) )
#--> [ 1, 2, 4, 5 ]

proff()
# Executed in 0.03 second(s)

/*-----

profon

? SomeXT( NumbersIn( -5 : 5 ), 20/100 )
#--> [ -5, 0, 4 ]

? FewXT( NumbersIn( -5 : 5 ), 5/100 )
#--> [ 2 ]

? MostXT( PositiveNumbersIn( -5 : 5 ), 90/100 )
#--> [ 3, 4, 5, 1 ]

proff()

/*-----
*/
profon

TheAnnualGain = 20500
? NPercentOf( 10, TheAnnualGain )
#--> 2050

proff()

/*=====

profon

? ARandomItemIn("A":"E")
#--> B

? NRandomItemsIn(3, "A":"E")
#--> [ "B", "B", "E" ]

? NRandomItemsInU(3, "A":"E")
#--> [ "B", "E", "A" ]

proff()
# Executed in 0.03 second(s)

/*=====

profon

? NRandomNumbersIn(3, 1:10)
#--> [ 1, 1, 1 ]

? NRandomNumbersInU(3, 1:10)
#--> [ 5, 1, 10 ]

proff()
# Executed in 0.03 second(s)

/*=====

profon

? 9_999_999_999 + 1
#--> 10_000_000_000

? 9_999_999_999 * 2
#--> 19_999_999_998

? sin(9_999_999_999)
#--> -1.00

proff()
# Executed in 0.03 second(s)

/*=====

/*---- #narration: In this narration; I will show how Sofanza compliments
# Ring in some corner areas, by taking as an example the generation of
# random numbers. I Hope you will find it interesting...

profon

# If you write this to ask Ring to generate a random number (version 1.19)

? @@( random(9_999_999_999) )
#--> _NULL_
# The result will be a _NULL_ string.

# In Softanza, using the alternative StzRandom() function, an error
# messageis raised:

//? StzRandom(9_999_999_999)
#--> ERROR: Can't proceed. The maximum value you can provide is 999_999_999.

# It turns our that Softanza is aware of the fact that Ring random()
# function has a limit. And you get the info it by calling the function :

? RingMaxRandom()
#--> 999_999_999

# In the same way, Softanza manages an other limit of the standard srandom()
# function. srandom(n) seeds the randomness engine with the number n, so the
# sequence of generated numbers fellwos a different path evry time the random()
# function is called.

# But, if you say:

//? srandom(2_999_999_999)
#--> RING ERROR: Bad parameters value, error in range!

# Than you will get an error.

# Actually, Softanza knows that the maximum number you can seed
# the engine with is:

? MaxRingSeed()
#--> 1_999_999_999

# So, you have the possibility to specify it in a more controlled way using
# the Softanza alternative function StzSRandom(), like this:

//? StzSRandom(2_999_999_999)
#--> ERR : Can't proceeed. n must be less than 1_999_999_999.

# In practice, when you ask Softanza for a random number, you can get it
# by using this function :

? ARandomNumber()
#--> 133_322_384

# And when you want to specify the seed, you can do it directly, as a second
# parameter of the eXtended form of the function:

? ARandomNumberXT(77)
#--> 32_438_4546

proff()
# Executed in 0.03 second(s)

/*---

profon

? ARandomNumberLessThan(10)
#--> 2

? ARandomNumberIn(1:10) 
#--> 1

? @@( ARandomNumberInZ(1:10) ) + NL
#--> [ 2, 2 ]

? RandomNumberBetween(100, 150) + NL
#--> 149

? @@( NRandomNumbersBetween(3, 100, 110) ) + NL
#--> [ 101, 101, 101 ]

? @@( NRandomNumbersBetweenU(3, 100, 110) ) + NL
#--> [ 102, 109, 105 ]

? @@( NRandomNumbersBetweenZ(3, 100, 110) ) + NL
#--> [ [ 105, 6 ], [ 108, 9 ], [ 105, 6 ] ]

? @@( NRandomNumbersBetweenUZ(3, 100, 110) )
#--> [ [ 102, 3 ], [ 106, 7 ], [ 103, 4 ] ]

proff()
# Executed in 0.05 second(s)

/*---

profon

? -5:1
#--> [ -5, -4, -3, -2, -1, 0, 1 ]

proff()
# Executed in 0.03 second(s)

/*---

profon

? random(-10) # Standard Ring function returning _NULL_
#--> ""

? StzRandom(-10) + NL
#--> -5

? SomeRandomNumbersBetween(-10, -1)
#--> [ -10, -10, -4 ]

? SomeRandomNumbersBetweenU(-10, -1)
#--> [ -10, -7, -3 ]

proff()
# Executed in 0.01 second(s)

/*---

profon

# Ring random() can't deal with 0 as a paramter:

? random(0)
#--> ""

# But Softanza can:

? StzRandom(0) + NL
#--> 0

# And can even generate 0s as random numbers:

? NRandomNumbersIn(5, 0:3)
#--> [ 0, 1, 1, 2, 3 ]

proff()
# Executed in 0.04 second(s)

/*---

profon

# Softanza can generate random real numbers in the range 0 to 1

? random01() # Or StzRandom01()
#--> 0.61

? ARandomNumberLessThan01(0.7)
#--> 0.08

? RandomRound()
#--> 3

	decimals(3)
	
	? random01() # Or StzRandom01()
	#--> 0.949
	
	? ARandomNumberLessThan01(0.7)
	#--> 0.557

SetRandomRound(5)
? RandomRound()
#--> 5

	decimals(5)
	
	? random01() # Or StzRandom01()
	#--> 0.91723
	
	? ARandomNumberLessThan01(0.5)
	#--> 0.26434

proff()
# Executed in 0.15 second(s)

/*---

profon

? ARandomNumberBetween(1, 2)
#--> 1.34

? ARandomNumberBetween(-3, -2)
#--> -2.45

proff()
