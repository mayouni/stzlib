load "stzlib.ring"

/*=====

pron()

? NRandomNumbersIn(3, 1:10)
#--> [ 6, 7, 7 ]

? NRandomNumbersInU(3, 1:10)
#--> [ 1, 2, 4 ]

proff-)

/*=====

pron()

? 9_999_999_999 + 1
#--> 10_000_000_000

? 9_999_999_999 * 2
#--> 19_999_999_998

? sin(9_999_999_999)
#--> -1.00

proff()

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

? StzRandom(9_999_999_999)
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

? srandom(2_999_999_999)
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

/*---
*/
pron()

? ARandomNumberLessThan(10)
#--> 7

? ARandomNumberIn(1:10)
#--> 4

? RandomNumberBetween(100, 150)
#--> 106

? @@( NRandomNumbersBetween(3, 100, 110) )
#--> [ 102, 103, 103 ]

? @@( NRandomNumbersBetweenU(3, 100, 110) )
#--> [ 101, 108, 109 ]

? @@( NRandomNumbersBetweenZ(3, 100, 110) )
#--> [ [ 103, 4 ], [ 104, 5 ], [ 105, 6 ], [ 105, 6 ] ]

? @@( NRandomNumbersBetweenUZ(3, 100, 110) )

proff()

