
load "../stzbase.ring"

/*---
*/
pr()

nAnnualGain = 20500

? NPercentOf(10, nAnnualGain)
#--> 2050

# Or Better
? 10PercentOf(nAnnualGain)

# Or even more generally
? Q(10).PercentOf(nAnnualGain)

? Q(25).Percent()
#--> 0.25

pf()

/*---

pr()

nCards = 1:52
oGameDeck = new stzList(nCards)

oGameDeck.Randomize()
anPlayerHand = oGameDeck.FirstN(5)

? @@(anPlayerHand)
#--> #--> [ 48, 20, 6, 51, 35 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

# Full ranomisation of the positions of all the items

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.Randomize() # Full shuffle
? @@( o1.Content() )
#--> [ "D", 4, "A", 3, "C", 2, 1, "B" ]

# Randomising the positions of only numbers

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeNumbers()
? @@( o1.Content() )
#--> [ 4, 1, 2, 3, "A", "B", "C", "D" ]

# Randomising the positions of only items in a section

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeSection(5, 8) # Partial shuffle
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, "D", "A", "C", "B" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

cCharSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
	   "0123456789" + "#!@~_" +
	   "abcdefghijklmnopqurstuvwxyz"
	  
	  

cPassword = ""

for i = 1 to 8
    cPassword += Q(cCharSet).ARandomChar()
next

? cPassword
#--> @3Ond72H
#--> 2z47AD@Z
#--> LrmaUo7Z

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*---

pr()

? random01() # Or ARandomNumberBetween(0, 1)
#--> 0.61

? ARandomNumberBetween(-3.5, 2.8)
#--> -2.45

SetRandomRound(3)
? ARandomNumberLessThan(0.7)
#--> 0.557

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

nTestSeed = 12345
anUserIds = []

for i = 1 to 1000
    anUserIds + ARandomNumberXT(nTestSeed + i)
next

? ShowShort( anUserIds )
#--> [ 7587, 7590, 7593, "...", 10843, 10846, 10849 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

? SomeXT(NumbersIn(-5:5), 20/100)
#--> [ -5, 0, 4 ]

? MostXT(PositiveNumbersIn(-5:5), 90/100)
#--> [ 3, 4, 5, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

acTreasureChest = [ "gold", "sword", "potion", "gem", "scroll" ]

acRareItems = Few(acTreasureChest)      # 10% chance items
? @@(acRareItems)
#--> [ "gold" ]

acCommonItems = Most(acTreasureChest)   # 70% chance items
? @@(acCommonItems)
#--> [ "sword", "gem", "gold", "scroll" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*====

pr()

aNumbers = [ 12, 9, 10, 7, 25, 12, 9, 8 ]
? Some(aNumbers)
#--> [ 12, 10, 7 ]

? DefaultSome()
0.3

SetSome(0.5)
? Some(aNumbers)
#--> [ 10, 25, 7, 9 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*====

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.Randomize()
? @@( o1.Content() )
#--> [ 1, "A", 4, 3, "D", "C", "B", 2 ]
#--> [ 1, "B", 2, "A", "C", 4, "D", 3 ]
#--> [ "B", "D", 2, 3, 4, 1, "A", "C" ]

pf()

/*====

pr()

o1 = new stzList([ "A", "B", 30, 40, 50, 60, "A", "B", "C" ])
o1.RandomizeNumbers()
? @@( o1.Content() )
#--> [ "A", "B", 30, 50, 40, 60, "A", "B", "C" ]
#--> [ "A", "B", 30, 40, 60, 50, "A", "B", "C" ]
#--> [ "A", "B", 30, 50, 60, 40, "A", "B", "C" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

#--

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeStrings()
? o1.Content()
#--> [ 1, 2, 3, 4, "B", "C", "D", "A" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

#--

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])

o1.RandomizeSection(1, 4)
? @@( o1.Content() )
#--> [ 1, 4, 2, 3, "A", "B", "C", "D" ]
#--> [ 2, 1, 3, 4, "A", "B", "C", "D" ]
#--> [ 4, 3, 1, 2, "A", "B", "C", "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20

/*--

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", "D" ])
o1.RandomizeSection(5, 8)
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, "A", "C", "D", "B" ]
#--> [ 1, 2, 3, 4, "C", "A", "D", "B" ]
#--> [ 1, 2, 3, 4, "B", "A", "C", "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20

/*--

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", "C", 8, 9, 10, "D" ])

o1.RandomizeSections([ [1,4], [8,10] ])
? @@( o1.Content() )
#--> [ 1, 2, 4, 3, "A", "B", "C", 10, 8, 9, "D" ]
#--> [ 2, 1, 3, 4, "A", "B", "C", 9, 8, 10, "D" ]
#--> [ 2, 3, 4, 1, "A", "B", "C", 9, 8, 10, "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

/*--

pr()

o1 = new stzList([ 1, 2, "A", "B", "C", 6, 7, "D", "E", "F", "G" ])

o1.RandomizeStrings()
? @@( o1.Content() )
#--> [ 1, 2, "C", "A", "B", 6, 7, "D", "F", "G", "E" ]
#--> [ 1, 2, "A", "B", "C", 6, 7, "D", "E", "G", "F" ]
#--> [ 1, 2, "B", "A", "C", 6, 7, "F", "G", "E", "D" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

/*--

pr()

o1 = new stzList([ "A", "B", 1:3, 4:5, 6:8, "C", 9:10, 11:12 ])
o1.RandomiseLists() # Or ShuffleLists()
? @@( o1.Content() )
#--> [ "A", "B", [ 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ], "C", [11, 12 ], [ 9, 10 ] ]
#--> [ "A", "B", [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ], "C", [ 9, 10 ], [ 11, 12 ] ]
#--> [ "A", "B", [ 4, 5 ], [ 6, 7, 8 ], [ 1, 2, 3 ], "C", [ 9, 10 ], [ 11, 12 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

/*----

pr()

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

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 7.76 second(s) in Ring 1.19

/*---

pr()

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

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*---

pr()

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? NRandomItems(3)
	#--> [ "A", "S", "Z" ]

	? @@( NRandomItemsZ(3) )
	#--> [ [ "S", 1 ], [ "A", 8 ], [ "N", 6 ] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*----

pr()

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

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20

/*-------

pr()

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

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20

/*=====

pr()


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

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*----

pr()

Them = [ "Andy", "Bill", "Chris" ]

? AllOf(Them)
#--> [ "Andy", "Bill", "Chris" ]

? @@( NoOneOf(Them) )
#--> [ ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

MyExamNotes = [ 12, 17, 18, 16, 19 ]
Them = MyExamNotes # An alternative name for semantic convenience
Average = 10

? AllOfQQ(MyExamNotes).ArePositive()
#--> TRUE


? AllOfQQ(Them).AreGreaterThen(Average)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22

/*-----

pr()

? AllNumbersInQQX([ -2, -4, -21 ]).AreNegativeX()
#--> TRUE

? AllNumbersInQQX([ -2, 8, -4, -21 ]).AreNegativeX()
#--> FALSE

#--

? NoNumberInQQX([ -2, -4, -21 ]).IsPositiveX()
#--> TRUE

? NoNumberInQQX([  -2, -4, -21, 10800 ]).IsPositiveX()
#--> FALSE

? NoNumberInQQX([ 2, 4, 21 ]).IsNegativeX()
#--> TRUE

? NoNumberInQQX([  2, 4, 21, -10800 ]).IsNegativeX()
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*-----

pr()


? NothingInQQX([ "aee@net", "@com.com", "--?mail@org" ]).MatchesX(rxp(:eMail))
#--> TRUE

? NothingInQQX([ "aee@net", "@com.com", "--?mail@org", "info@mail.com" ]).MatchesX(rxp(:eMail))
#--> FALSE

? EveryThingInQQX([ "hello@mail.com", "info@mail.org" ]).MatchesX(rxp(:eMail))
#--> TRUE

? EveryThingInQQX([ "hello@mail.com", "info@mail.org", "~;@com" ]).MatchesX(rxp(:eMail))
#--> FALSE

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*-----

pr()

? SomeXT( NumbersIn( -5 : 5 ), 20/100 )
#--> [ -5, 0, 4 ]

? FewXT( NumbersIn( -5 : 5 ), 5/100 )
#--> [ 2 ]

? MostXT( PositiveNumbersIn( -5 : 5 ), 90/100 )
#--> [ 3, 4, 5, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*-----

pr()

nAnnualGain = 20500
? NPercentOf( 10, nAnnualGain )
#--> 2050

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*=====

pr()

? ARandomItemIn("A":"E")
#--> B

? NRandomItemsIn(3, "A":"E")
#--> [ "B", "B", "E" ]

? NRandomItemsInU(3, "A":"E")
#--> [ "B", "E", "A" ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

/*=====

pr()

? NRandomNumbersIn(3, 1:10)
#--> [ 1, 1, 1 ]

? NRandomNumbersInU(3, 1:10)
#--> [ 5, 1, 10 ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in almost 0 second(s) in Ring 1.23

/*=====

pr()

? 9_999_999_999 + 1
#--> 10_000_000_000

? 9_999_999_999 * 2
#--> 19_999_999_998

? sin(9_999_999_999)
#--> -1.00

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20

/*=====

/*---- #narration: In this narration; I will show how Sofanza compliments
# Ring in some corner areas, by taking as an example the generation of
# random numbers. I Hope you will find it interesting...

pr()

# If you write this to ask Ring to generate a random number (version 1.23)

? @@( random(9_999_999_999) )
#--> ""
# The result will be a null string.

# In Softanza, using the alternative StzRandom() function, an error
# messageis raised:

//? StzRandom(9_999_999_999)
#--> ERROR: Can't proceed. The maximum value you can provide is 999_999_999.

# It turns our that Softanza is aware of the fact that Ring random()
# function has a limit. And you get that info by calling the function :

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

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.19

/*---

pr()

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

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.20

/*--- #ring

pr()

? -5:1
#--> [ -5, -4, -3, -2, -1, 0, 1 ]

pf()
# Executed in 0.03 second(s)

/*---

pr()

? random(-10) # Standard Ring function returning _NULL_
#--> ""

? StzRandom(-10) + NL
#--> -5

? SomeRandomNumbersBetween(-10, -1)
#--> [ -10, -10, -4 ]

? SomeRandomNumbersBetweenU(-10, -1)
#--> [ -10, -7, -3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.20

/*---

pr()

? random(0)
#--> 0

? StzRandom(0) + NL
#--> 0

# Generate 0s as random numbers:

? NRandomNumbersIn(5, 0:3)
#--> [ 0, 3, 1, 1, 0 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20

/*---
*
pr()

# Softanza can generate random real numbers in the range 0 to 1

? random01() # Or StzRandom01()
#--> 0.31

? ARandomNumberLessThan01(0.7)
#--> 0.52

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

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.15 second(s) in Ring 1.20

/*---

pr()

? ARandomNumberBetween(1, 2)
#--> 1.34

? ARandomNumberBetween(-3, -2)
#--> -2.45

pf()
# Executed in 0.01 second(s) in Ring 1.23
