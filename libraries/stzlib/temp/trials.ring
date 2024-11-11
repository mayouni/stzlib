load "../max/stzmax.ring"

/*---

pron()

? @@( FirstNPrimes(5) )
#--> [ 2, 3, 5, 7, 11 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*---

pron()

? @@( Q("134").Digits() )
#--> [ "1", "3", "4" ]

proff()
# Executed in 0.02 second(s) in Ring 1.21

/*---

pron()
o1 = new stzList([ "12", "25", "38" ])
o1.Numberify() # Or Numbrify()
? @@( o1.Content() )
#--> [ 12, 25, 38 ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pron()

o1 = new stzListOfNumbers([ 2, 3, 5 ])
? o1.ArePrimes()
#-->  TRUE

o1 = new stzListOfNumbers([ 2, 4, 5 ])
? o1.ArePrimes()
#-->  FALSE

proff()


/*---

pron()

? FirstNPrimes(25)

proff()

/*---

pron()

? Q(1245).Digits()
#--> [ 1, 2, 4, 5 ]

? Q(-12.45).Digits()
#--> [ 1, 2, 4, 5 ]

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pron()

? NextPrimeAfter(12)
#--> 13

? NextNthPrime(29, :After = 12)
#--> 139

? PreviousPrimeBefore(140)
#--> 139

? PreviousNthPrime(29, :Before = 140)
#--> 13

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*---
*/
pron()

? NFirstPrimesW(25, :Where = '{ 
	Q(@prime).DigitsQR(:stzListOfNumbers).ArePrimes()
}')
#--> [
#	2, 3, 5, 7, 23, 37, 53,
#	73, 223, 227, 233, 257,
#	277, 337, 353, 373, 523,
#	557, 577, 727, 733, 757,
#	773, 2237, 2273
# ]

proff()
# Executed in 1.22 second(s) in Ring 1.21

/*---

*/
pron()

# Problem statement

# The Smarandache prime-digital sequence (SPDS for brevity)
# is the sequence of primes whose digits are themselves prime.
# Get the first 25 among them.

# In the feloowing Softanza solutuon, FirstNPrimes(n) returns
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

proff()
# Executed in 3.42 second(s) in Ring 1.21

/*---

pron()

# Given the string: "abracadabra", replace programatically:
#
#	the first 'a' with 'A'
#	the second 'a' with 'B'
#	the fourth 'a' with 'C'
#	the fifth 'a' with 'D'
#	the first 'b' with 'E'
#	the second 'r' with 'F'
#
# The answer should, of course, be : "AErBcadCbFD".

Q("abracadabra") {

	ReplaceNth(5, 'a', :with = 'D')
	ReplaceNth(4, 'a', :with = 'C')
	ReplaceNth(2, 'a', :with = 'B')
	ReplaceNth(1, 'a', :with = 'A')

	ReplaceNth(1, 'b', :with = 'E')
	ReplaceNth(2, 'r', :with = 'F')

	? Content()
	#--> AErBcadCbFD
}

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pron()

Q("abracadabra") {
	ReplaceManyNthSubStrings([
		[ 1, 'a', :with = 'A' ],
		[ 2, 'a', :with = 'B' ],
		[ 4, 'a', :with = 'C' ],
		[ 5, 'a', :with = 'D' ],
	
		[ 1, 'b', :with = 'E' ],
		[ 2, 'r', :with = 'F' ]
	])

	? Content()
}

proff()

/*---

pron()

Naturally() {
	Given the string "abracadabra" replace programatically

		the first 'a' with 'A'
		the second 'a' with 'B'
		the fourth 'a' with 'C'
		the fifth 'a' with 'D'
		the first 'b' with 'E'
		the second 'r' with 'F'

	The answer should of course be "AErBcadCbFD"
}

proff()

