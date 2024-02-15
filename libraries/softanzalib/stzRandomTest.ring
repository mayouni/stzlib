load "stzlib.ring"

pron()

? Some( NumbersIn( -5 : 5 ) )
#--> [ -2, -1, 2, 4 ]

? Few( NumbersIn( -5 : 5 ) )
#--> [ -5, -1 ]

? All( EvenNumbersIn( -5 : 5 ) )
#--> [ -4, -2, 0, 2, 4 ]

? Half( OddNumbersIn( -5 : 5 ) )
#--> [ -5, 1, 3 ]

? Most( PositiveNumbersIn( -5 : 5 ) )
#--> [ 1, 2, 4, 5 ]

? No( NumbersIn( -5 : 5 ] )
#--> [ ]

proff()

/*=====

pron()

? ARandomItemIn("A":"E")
#--> B

? NRandomItemsIn(3, "A":"E")
#--> [ "B", "B", "E" ]

? NRandomItemsInU(3, "A":"E")
#--> [ "B", "E", "A" ]

proff()
# Executed in 0.03 second(s)

/*=====

pron()

? NRandomNumbersIn(3, 1:10)
#--> [ 1, 1, 1 ]

? NRandomNumbersInU(3, 1:10)
#--> [ 5, 1, 10 ]

proff()
# Executed in 0.03 second(s)

/*=====

pron()

? 9_999_999_999 + 1
#--> 10_000_000_000

? 9_999_999_999 * 2
#--> 19_999_999_998

? sin(9_999_999_999)
#--> -1.00

proff()
# Executed in 0.03 second(s)

/*=====

/*---- @Narration: In this narration; I will show how Sofanza compliments
# Ring in some corner areas, by taking as an example the generation of
# random numbers. I Hope you will find it interesting...

pron()

# If you write this to ask Ring to generate a random number (version 1.19)

? @@( random(9_999_999_999) )
#--> NULL
# The result will be a NULL string.

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

pron()

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

pron()

? -5:1
#--> [ -5, -4, -3, -2, -1, 0, 1 ]

proff()
# Executed in 0.03 second(s)

/*---
*/
pron()

? random(-10) # Standard Ring function returning NULL
#--> ""

? StzRandom(-10) + NL
#--> -9

? SomeRandomNumbersBetween(-10, -1)
#--> [ -10, -10, -10 ]

? SomeRandomNumbersBetweenU(-10, -1)
#--> [ -10, -6, -3, -2 ]

proff()
# Executed in 0.01 second(s)

/*---

pron()

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

pron()

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
*/
pron()

//? 2.5 : 5.8

? L('2.5 : 5.8')

proff()

/*---

pron()

? ARandomNumberBetween(1, 2)
#--> 1.34

? ARandomNumberBetween(-3, -2)
#--> -2.45

proff()
