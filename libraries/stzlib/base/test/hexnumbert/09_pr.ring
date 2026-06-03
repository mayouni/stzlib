# Narrative
# --------
# pr()
#
# Extracted from stzhexnumbertTest.ring, block #9.

load "../../stzBase.ring"


# Problem statement (from RosettaCode)

# The Smarandache prime-digital sequence (SPDS for brevity)
# is the sequence of primes whose digits are themselves prime.
# Get the first 25 among them.

# In the feloowing Softanza solutionn, FirstNPrimes(n) returns
# the first n prime numbers.

# We will experiment with n value until we find that the 25 SDPS
# primes are contained in the list of first 340 primes.

# Get first 340 primes in a stzList object
# Transform them into strings
# Get the strings verifying this condition
# Turn the srings back to numbers

? FirstNPrimesQ(340). 
	StringifyQ(). 

	ItemsWXTQ('   
		Q(@item).DigitsQ().NumberifyQ().ToStzListOfNumbers().ArePrimes()

	').Numberified()

#--> [
#	2, 3, 5, 7, 23, 37, 53,
#	73, 223, 227, 233, 257,
#	277, 337, 353, 373, 523,
#	557, 577, 727, 733, 757,
#	773, 2237, 2273
# ]

pf()
# Executed in 3.42 second(s) in Ring 1.21
