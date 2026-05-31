# Narrative
# --------
# /*---- #narration: In this narration; I will show how Sofanza compliments
#
# Extracted from stzrandomtest.ring, block #30.

load "../../../stzBase.ring"

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
