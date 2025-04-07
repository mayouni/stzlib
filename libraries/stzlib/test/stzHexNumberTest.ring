load "../max/stzmax.ring"

/*---

pr()

? @@( FirstNPrimes(5) )
#--> [ 2, 3, 5, 7, 11 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21

/*---
*/
pr()

? pat(:digits)

? @@( Q("1@an3 xy4b12").Digits() )
#--> [ "1", "3", "4", "1", "2" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()
o1 = new stzList([ "12", "25", "38" ])
o1.Numberify() # Or Numbrify()
? @@( o1.Content() )
#--> [ 12, 25, 38 ]

pf()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pr()

o1 = new stzListOfNumbers([ 2, 3, 5 ])
? o1.ArePrimes()
#-->  TRUE

o1 = new stzListOfNumbers([ 2, 4, 5 ])
? o1.ArePrimes()
#-->  FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.21

/*---

pr()

? @@(FirstNPrimes(25))
#--> [
#	2, 3, 5, 7, 11, 13, 17, 19, 23,
#	29, 31, 37, 41, 43, 47, 53, 59,
#	61, 67, 71, 73, 79, 83, 89, 97
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.21

/*---

pr()

? Q(1245).Digits()
#--> [ 1, 2, 4, 5 ]

? Q(-12.45).Digits()
#--> [ 1, 2, 4, 5 ]

pf()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pr()

? NextPrimeAfter(12)
#--> 13

? NextNthPrime(29, :After = 12)
#--> 139

? PreviousPrimeBefore(140)
#--> 139

? PreviousNthPrime(29, :Before = 140)
#--> 13

pf()
# Executed in almost 0 second(s) in Ring 1.21

/*=========

#NOTE This is an update of the next narration of the solution
# or the SPDS problem statement form RosettaCode. Here we
# rpovide a cleaner and more efficient solution:

pr()

? NFirstPrimesW(25, :Where = '{ 
	Q(@prime).DigitsQRT(:stzListOfNumbers).ArePrimes()
}')
#--> [
#	2, 3, 5, 7, 23, 37, 53,
#	73, 223, 227, 233, 257,
#	277, 337, 353, 373, 523,
#	557, 577, 727, 733, 757,
#	773, 2237, 2273
# ]

pf()
# Executed in 1.19 second(s) in Ring 1.21

/*---

pr()

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

/*------


pr()

? HexPrefixes()
#--> [ "x", "0x", "U+" ]

? StzStringQ("x167A").RepresentsNumberInHexForm()
#--> TRUE

? HexToDecimal("x167A")
#--> 5754

pf()
# Executed in 0.02 second(s).

/*-------
*/
pr()

StzHexNumberQ("x167A") {

	? Content()	# Same as WithoutPrefix()
	#--> 167A
	
	? WithPrefix()	# same as HexNumber()
	#--> 0x167A
	
	? ToDecimal()
	#--> 5754

	? ToBinary()
	#--> 0b1011001111010

	? ToOctal()
	#--> 0o13172

	SetHexPrefix("x")
	? WithPrefix()
	#--> x167A

	SetBinaryPrefix("b")
	? ToBinary()
	#--> b1011001111010
}

pf()
# Executed in 0.06 second(s).

/*---------------------

pr()

? IsUnicodeHex("U+214B")
#--> TRUE

? StringRepresentsNumberInHexform("xE82")
#--> TRUE

o1 = new stzHexNumber("xE82")
? o1.Content()
#--> E82

pf()
# Executed in 0.02 second(s).

/*---------------------

pr()

o1 = new stzHexNumber("")

o1.FromBinary("b10011")
? o1.Content()
#--> 0x13

? o1.ToOctal() # TODO check correctness

pf()
# Executed in 0.02 second(s).
