load "../stzbase.ring"

/*----
*/
pr()

? Q(10).PercentOf(nAnnualGain)

? Q(25).Percent()
#--> 0.25

pf()

/*----

pr()

? Q(120602061.1).HowMany(0)
#--> 4
#~> Bacause decimals() = 2 by default and then
#   120602061.1 is actually 120602061.10

? Q("120602061.1").HowMany("0")
#--> 3

? Q(120602061.10).HowMany(1)
#--> 3

? Q(120602061.1).HowMany(20)
#--> 2

? Q(120602061.1).HowMany("06")
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.21

/*======

pr()

? @@( Q(462).PrimeDividors() ) + NL
#--> [ 2, 3, 7, 11 ]

? @@( Q(462).Factors() )
#--> [ 1, 2, 3, 6, 7, 11, 14, 21, 22, 33, 42, 66, 77, 154, 231, 462 ]

pf()
#--> Executed in 0.03 second(s)

/*----------

pr()

? Q(169).IsPrime()
#--> FALSE

? Q(17).IsPrime()
#--> TRUE

? @@( Q(54).Divirdos() ) + NL	# Misspelled, but works!
#--> [ 1, 2, 3, 6, 9, 18, 27, 54 ]

? @@( Q(54).Factors() ) + NL
#--> [ 1, 2, 3, 6, 9, 18, 27, 54 ]

? @@( Q(54).PrimeFactors() ) + NL
#--> [ 2, 3 ]

? @@( Q(54).PrimeDividors() )
#--> [ 2, 3 ]

pf()
# Executed in 0.04 second(s)

/*------

pr()

# In number theory, a Wieferich prime is a prime number p
# such that p2 evenly divides 2(p − 1) − 1.

# Task: Find the Wieferich primes less than 5000

# In Ruby, one can find them with sutch a concise and
# expressive line of code:
'
puts Prime.each(5000).select{|p| 2.pow(p-1 ,p*p) == 1 }
'

# In Ring, with Softanza, it's even more expressive:

? PrimesUnderQ(5000).WXT(' isWeiferich(@number) ')
#--> [ 1093, 3511 ]

pf()
# Executed in 2.41 second(s) in Ring 1.21

/*--------

pr()

? PrimesUnder(19)
#--> [ 2, 3, 5, 7, 11, 13, 17 ]

? PrimesUnderIB(19)
#--> [ 2, 3, 5, 7, 11, 13, 17, 19 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21

/*------- #ring

pr()

for i = 1 to 5000
	if isWeiferich(i)
		? i
	ok
next
#--> [ 1, 4 ]

pf()
# Executed in 0.36 second(s) in Ring 1.21

/*----- #ring + softanza

pr()

anPrimes = PrimesUnder(5000)
nLen = len(anPrimes)

anResult = []
for i = 1 to nLen
	if isWeiferich(anPrimes[i])
		anResult + i
	ok
next

? anResult
# Executed in 0.36 second(s) in Ring 1.21

pf()

/*--- @ring

pr()

aHash = [ :1 = "One", :2 = "Two", :3 = "Three" ]

? @@(aHash)
#--> [ [ "1", "One" ], [ "2", "Two" ], [ "3", "Three" ] ]

? isString(aHash[1][1]) # "1"
#--> TRUE

? @@( aHash[1] )
#--> [ "1", "One" ]

? aHash[:1]
#--> "One"

pf()
# Executed in almost 0 second(s) in Ring 1.21

/*================

pr()

n1 = 6405
n2 = 10

? GCD(n1, n2) # GreatestCommonDivisor()
#--> 5

? @@( Factors(n1) ) + NL
#--> [ 1, 3, 5, 7, 15, 21, 35, 61, 105, 183, 305, 427, 915, 1281, 2135, 6405 ]

? @@( Factors(n2) )
#--> [ 1, 2, 5, 10 ]

? Max( CommonNumbers([ Factors(n1), Factors(n2) ]) )
#--> 5

pf()
# Executed in 0.04 second(s)

/*================

pr()

o1 = new stzNumber(3200)

? o1 + 3500
#--> 3600

? o1 + 300 + 500 + 200
#--> 4200

? o1 + [ 300, 500, 200 ]
 #--> 4200

pf()
# Executed in 1.03 second(s)

/*-----------------

pr()

o1 = new stzNumber(12500)

? o1 - 12000
#--> 500

? o1 - 10000 - 2000 - 250
#--> 250

? o1 - [ 10000, 2000, 250 ]
#--> 250

pf()
# Executed in 1.04 second(s)

/*-----------------

pr()

o1 = new stzNumber(12)

? o1 * 5
#--> 60

? o1 * 5 * 4 * 2
#--> 480

? o1 * [ 5, 4, 2 ]
 #--> 480

pf()
# Executed in 0.83 second(s)

/*-----------------

pr()

o1 = new stzNumber(12)

o1 * Q(5)
? o1.NumericValue()
#--> 60

#--

o1 = new stzNumber(12)
o1 * Q(5 * 4 * 2)
? o1.NumericValue()
#--> 480

#--

o1 = new stzNumber(12)
o1 * Q([ 5, 4, 2 ])
? o1.NumericValue()
 #--> 480

pf()
# Executed in 0.75 second(s) in Ring 1.17

/*-----------------

pr()

o1 = new stzNumber(3000)

? o1 / 20
#--> 150

? o1 / 20 / 15 / 2
#--> 5

? o1 / [ 20, 15, 2 ]
 #--> 5

pf()
# Executed in 0.24 second(s) in Ring 1.19

/*================

pr()

StzNamedNumberQ(:myage = 47) {

	? Name()
	#--> :myage

	? Content()
	#--> 47

	? StzType()
	#--> :stznumber

}

pf()
# Executed in 0.03 second(s)

/*=================

pr()

? RandomNumberGreaterThan(12)
#--> 999_999_999_999_995
#--> 999_999_999_999_990
#--> 999_999_999_999_988
#--> 999_999_999_999_991
#--> 999_999_999_999_992

pf()
# Executed in 0.03 second(s)

/*-----------------

pr()

? RandomNumberLessThan(12)
#--> 10
#--> 9
#--> 10
#--> 9
#--> 10

pf()
# Executed in 0.03 second(s)

/*------------------

pr()

? NRandomNumbersGreaterThan(3, 150_000)
#--> [
#	999_999_999_977_566.00,
#	999_999_999_975_123.00,
#	999_999_999_969_942.00
# ]

pf()

/*------------------

pr()

? NRandomNumbersLessThan(3, 17_000)
#--> [ 16_997, 16_998, 16_998 ]

? 5RandomNumbersLessThan(17_000)
#--> [ 16_998, 16_997, 16_999, 16_997, 16_997 ]

pf()
# Executed in 0.04 second(s) in Ring 1.19

/*------------------

pr()

? ARandomNumber( :Between = 5, :And = 10 )
#--> 5
#--> 7
#--> 9
#--> 8
#--> 7

pf()

/*-----------------

pr()

? ARandomNumber( :Between = 1, :And = 5 ) # To include bounds (1 and 5) use ...XT()
#--> 2
#--> 4
#--> 3
#--> 4
#--> 3

pf()

/*-----------------

pr()

? 3RandomNumbers( :Between = 1, :And = 5 )
#--> [ 4, 3, 3 ]

? 3RandomNumbersIB( :Between = 1, :And = 5 )
#--> [ 4, 5, 4 ]

pf()

/*-----------------

pr()

? OddOrEven(5)
#--> :Odd

? OddOrEven(120)
#--> :Even

pf()
# Executed in 0.02 second(s)

/*-----------------

pr()

? Q(12).IsZawji()	# or IsEven()
#--> TRUE

? Q(13).IsFardi()	# or IsOdd()
#--> TRUE

pf()
# Executed in 0.02 second(s)

/*===========

pr()

#TODO : Fix the point at the end of the result

o1 = new stzNumber("601793176.32")
? o1.ToHexForm()
#!--> 0x23DEA298.

pf()

/*=============

pr()

? LCM(25, 42) # or LeastCommonMultiple(:Of = 25, :And = 42)
#--> Executed in 0.03 second(s)

? GCD(250, 420) # or GreatestCommonDividor(:Of = 250, :And = 420)
#--> 10

pf()
# Executed in 0.02 second(s)

/*-------- FIX

pr()

//? StzListOfListsQ([ [ "a", "b", "c" ], [ 1, "b", 2, "c" ] ]).CommonItems()
#--> [ "b", "c" ]

? CommonItems([ :Between = [ "a", "b", "c" ], :And = [ 1, "b", 2, "c" ] ])

pf()
# Executed in 0.04 second(s) in Ring 1.19
# Executed in 0.07 second(s) in Ring 1.17

/*--------

pr()

? Q(25).MultiplesUntilQRT(1080, :stzListOfNumbers).
	LeastCommonNumber(:With = Q(42).MultiplesUntil(1080) )

#--> 1050

	# Executed in 1.48 second(s) in Ring 1.19
	# Executed in 2.51 second(s) in Ring 1.18
	# Executed in 4.45 second(s) in Ring 1.17

# Ok, but how this is found in practice, like if we make it by hand?
# First, let's see the multiples of 25 under 1080

aList1 = Q(25).Multiples(:Under = 1080) # Use ? @@( aList1 ) to show the list

#--> [
#	25, 50, 75, 100, 125,
#	150, 175, 200, 225, 250,
#	275, 300, 325, 350, 375,
#	400, 425, 450, 475, 500,
#	525, 550, 575, 600, 625,
#	650, 675, 700, 725, 750,
#	775, 800, 825, 850, 875,
#	900, 925, 950, 975,
#	1000, 1025, 1050, 1075
# ]

	# Executed in 1.00 second(s) in Ring 1.19 (64 Bits)
	# Executed in 1.62 second(s) in Ring 1.18
	# Executed in 2.84 second(s) in Ring 1.17

# Then we look to the multiples of 42 under 1080

aList2 = Q(42).Multiples(:Under = 1080) # Use ? @@( aList2 ) to show the list

#--> [
#	42, 84, 126, 168, 210,
#	252, 294, 336, 378, 420,
#	462, 504, 546, 588, 630,
#	672, 714, 756, 798, 840,
#	882, 924, 966, 1008, 1050
# ]

	# Executed in 0.65 second(s) in Ring 1.19
	# Executed in 1.64 second(s) in Ring 1.18
	# Executed in 1.70 second(s) in Ring 1.17

# We can visually recognize 1050 as the Least Common Multiplier between
# the two numbers (25 and 42) before we exceed 1080.

# We can get this instantly by saying:

? StzListOfNumbersQ(aList1).LeastCommonNumber(aList2)
#--> 1050

pf()
# Executed in 0.85 second(s) in Ring 1.19 (64 Bits)
# Executed in 1.41 second(s) in Ring 1.18
# Executed in 2.35 second(s) in Ring 1.17

/*-----------------

pr()

? @@( Q(25).MultiplesUnder(1080) ) + NL
#--> [
#	25, 50, 75, 100, 125,
#	150, 175, 200, 225, 250,
#	275, 300, 325, 350, 375,
#	400, 425, 450, 475, 500,
#	525, 550, 575, 600, 625,
#	650, 675, 700, 725, 750,
#	775, 800, 825, 850, 875,
#	900, 925, 950, 975,
#	1000, 1025, 1050, 1075
# ]

? @@( Q(42).MultiplesUnder(1080) ) + NL
#--> [
#	42, 84, 126, 168, 210,
#	252, 294, 336, 378, 420,
#	462, 504, 546, 588, 630,
#	672, 714, 756, 798, 840,
#	882, 924, 966, 1008, 1050
# ]

pf()
# Executed in 0.51 second(s)

/*----------------

pr()

# Least common multiplier between 25 and 42
? Q(25).LCM(42)
#--> 1050

? @@( Q(1050).PrimeFactorsXT() ) + NL
#--> [ [ 2, 525 ], [ 3, 350 ], [ 5, 210 ], [ 7, 150 ] ]

? @@( Q(1050).FactorsXT() )
#--> [
#	[ 1, 1050 ], [ 2, 525 ], [ 3, 350 ],
#	[ 5, 210 ], [ 6, 175 ], [ 7, 150 ],
#	[ 10, 105 ], [ 14, 75 ], [ 15, 70 ],
#	[ 21, 50 ], [ 25, 42 ], [ 30, 35 ],
#	[ 35, 30 ], [ 42, 25 ], [ 50, 21 ],
#	[ 70, 15 ], [ 75, 14 ], [ 105, 10 ],
#	[ 150, 7 ], [ 175, 6 ], [ 210, 5 ],
#	[ 350, 3 ], [ 525, 2 ], [ 1050, 1 ]
# ]

pf()
# Executed in 0.51 second(s) in Ring 1.19
# Executed in 0.68 second(s) in Ring 1.17

/*---------------

pr()

? Q(11) + [2, 3] # same as 11 + 2 + 3
#--> 16

? Q(11) - [2, 3] # same as 11 - 2 - 3
#--> 6

? Q(11) * [2, 3] # same as 11 * 2 * 3
#--> 66

? Q(24) / [ 3, 2] # same as 24 / 3 / 2
#--> 4

pf()
# Executed in 0.09 second(s) in Ring 1.19
# Executed in 0.14 second(s) in Ring 1.17

/*===================

pr()

o1 = new stzNumber(11)
o1.MultiplyBy(3)
#--> 33

#--

o1 = new stzNumber(11)
o1.MultiplyBy([ 3, 2 ])
? o1.Content()
#--> 66

pf()
# Executed in 0.16 second(s)

/*-----------------

pr()

o1 = new stzNumber(11)
? o1.RepeatedNTimes(3)
#--> [11, 11, 11]

# Don't confuse with:
? o1.Times(3)
#--> 33

? o1.Times([2, 3])
#--> 66

pf()
# Executed in 0.09 second(s) in Ring 1.19
# Executed in 0.13 second(s) in Ring 1.17

/*------------------

pr()

o1 = new stzNumber(11)
o1.MultiplyByMany([2, 3])
? o1.Value()
#--> 66

pf()
# Executed in 0.10 second(s) in Ring 1.19
# Executed in 0.12 second(s) in Ring 1.17
/*------------------

pr()

o1 = new stzNumber(5)

? @@( o1.RepeatXT(:InA = :List, :OfSize = 2) )
#--> [ 5, 5 ]

? o1.RepeatXT(:InA = :String, :OfSize = 7)
#--> "5555555"

? @@( o1.RepeatXT(:InA = :Grid, :OfSize = [3, 3]) ) + NL
#-->
# [
# 	[ 5, 5, 5 ],
# 	[ 5, 5, 5 ],
# 	[ 5, 5, 5 ]
# ]

? o1.RepeatXT(:InA = :StzTable, :OfSize = [3, 3]).Shwo() #NOTE that Shwo() is a misspelled
						         # form of Show(), recognised and fixed
#--> :COL1   :COL2   :COL3
#    ------ ------- ------
#       5       5       5
#       5       5       5
 #      5       5       5

pf()
# Executed in 0.30 second(s)

/*-----------------------

pr()

? Q(5).RepeatXT( :InAPair, @ )
#--> [5, 5]

? Q(5).RepeatedInAPair()
#--> [5, 5]

pf()
# Executed in 0.08 second(s)

/*-----------------------

pr()

o1 = new stzNumber("5")
? ring_type(o1.Number())
#--> NUMBER

pf()
# Executed in 0.05 second(s)

/*-----------------------

pr()

? Q("Ring").RepeatedInAPairQ().Types()
#--> [ "STRING", "STRING" ]

# Because this feature is implemented in stzObject, and bacause
# stzObject is the parent of all the other Softanza types, like
# stzNumber, stzList, stzString and so on, this will work the
# same way using any type:

? Q(5).RepeatedInAPair()
#--> [ 5, 5 ]

? Q([1, 2]).RepeatedInAPair()
#--> [ [1,2], [1,2] ]

pf()
# Executed in 0.06 second(s)

/*-----------------------

pr()

? @@( CircledNumbers() )
#--> [ "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⓪" ]

? StzNumberQ("⓪").Number() #--> 0 
? StzNumberQ("①").Number() #--> 1 
? StzNumberQ("②").Number() #--> 2 
? StzNumberQ("③").Number() #--> 3 
? StzNumberQ("④").Number() #--> 4 
? StzNumberQ("⑤").Number() #--> 5 
? StzNumberQ("⑥").Number() #--> 6 
? StzNumberQ("⑦").Number() #--> 7 
? StzNumberQ("⑧").Number() #--> 8 
? StzNumberQ("⑨").Number() #--> 9
# You can also use .NumericValue() or just .Value() and it works!

pf()
# Executed in 0.07 second(s)

/*-----------------------

pr()

? Q(10) ^ 3
#--> 1000

pf()
# Executed in 0.04 second(s)

/*--------------------

pr()

? type(Round(81.8))
#--> 82

pf()

/*--------------------

pr()

? Q(2).IsBetween(1, 3)
#--> TRUE

pf()
# Executed in 0.04 second(s)

/*=============== ici #TODO ERROR

pr()

? Round(81.8)
#--> 82

? Round([ "81.8", 3 ])
#--> "81.8"

? RoundXT([ "81.8", 3 ])
#--> "81.800"

pf()
# Executed in 0.11 second(s)

/*--------------------

pr()

decimals(3)
? 81.8
#--> 81.800

StzNumberQ("81.8") {

	? RoundedTo(3)
	#--> "81.8"

	? RoundedToXT(3)
	#--> "81.800"

}

pf()
# Executed in 0.05 second(s)

/*--------------------

pr()

	? DefaultRound()
	#--> 2

	? ActiveRound()
	#--> 2
	
	? 1.224
	#--> 1.22

	? 81.8
	#--> 81.80

	StzDecimals(7)

	? ActiveRound()
	#--> 7

	? 1.224
	#--> 1.2240000

	ResetRound()

	? ActiveRound()
	#--> 2

	? 1.224
	#--> 1.22

pf()
# Executed in 0.01 second(s)

/*-----------------------

pr()

? CurrentRound() # Currrent round on the program
#--> 2

o1 = new stzNumber("-12.4521")

? o1.Round() # Round of the object (infered here from the decimal part .4532)
#--> 4

? o1.Value() # Or NumericValue() ~> Sensitive to the currend round on the program (2)
#--> -12.45

? o1.StringValue() # Or Content() ~> Sensitive to the current round on the stzNumber object (4)
#--> "-12.4521"

pf()
# Executed in 0.05 second(s)

/*-----------------------

pr()

StzDecimals(3) # Change the program round and memorises it

o1 = new stzNumber([ 981.123456701, :round = 5 ])

? o1.Round()
#--> 5

? o1.NumericValue() # Sensitive to current on the program round, 3.
#--> 981.123

? o1.StringValue() # Rounded to the what is specified at the object level, 5.
#--> 981.12346

pf()
# Executed in 0.03 second(s)

/*-----------------------

pr()

o1 = new stzNumber([ 55993400908134, :Round = 5 ])
? o1.Round()
#--> 5

? o1.Sine()
#--> "-0.99986"

? o1.Cosine()
#--> "-0.01644"

? o1.Tangent()
#--> "60.82558"

? o1.Cotangent()
#--> "0.01644"

pf()
# Executed in 0.08 second(s)

/*-----------------------

pr()

o1 = new stzNumber("12.872")

? o1.IsEqual(12.872)
#--> TRUE

? o1.IsBetween(12, "13")
#--> TRUE

pf()
# Executed in 0.06 second(s)

/*-----------------------

pr()

? StzNumberQ(1).UpTo(7)
#--> 1:7

? StzNumberQ(7).DownTo(1)
#--> 7:1

pf()
# Executed in 0.03 second(s)

/*-----------------------

pr()

? Q(5.12).IsEqualTo(5.1200000000000001)
#--> TRUE

# Because the current round on the program is 2, as defined by default in Ring.
# When Ring rounds the long number provided to 2, it will become 5.12

? Q(5.12).IsEqualTo("5.1200000000000001")
#--> TRUE

# But if we use the round that reads the very last 1 in the decimal part,
# the two numbers will be identified as beeing different:

? Q(5.12).IsEqualTo([ 5.1200000000000001, :Round = 16 ])
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.21

/*-----------------------

? RingMaxRound()
#--> 14

/*-----------------------

pr()

o1 = new stzNumber("123")
? o1.Content()
#--> 123

o1 = new stzNumber("123.")
? o1.Content()
#--> 123.0

o1 = new stzNumber([ "123", 3 ])
? o1.Content()
#--> 123.000

pf()

/*-----------------------

pr()

o1 = new stzNumber(-123)
o1.RoundTo(3)
#--> "-123.000"

? o1.Content()

pf()

/*-----------------------

pr()

? MaxNumberInRing()
#--> 999999999999999

? MaxRoundInRing()
#--> 14

pf()
# Executed in 0.03 second(s)

/*-----------------------

pr()

o1 = new stzNumber("23500.124")

? o1.Round()
#--> 3

? o1.MaxRound()
#--> 6

o1.RoundTo(:Max)
? o1.Content()
#--> 23500.12399999999980

pf()
# Executed in 0.06 second(s)

/*-----------------------

pr()

o1 = new stzNumber("123") 
o1.RoundTo(:Max)
? o1.Content()
#--> "123.00000000000000"

o1 = new stzNumber("123456789012345")
o1.RoundTo(:Max)
? o1.Content()
#--> "12345678912345"

pf()

/*-----------------------

pr()

o1 = new stzNumber("123.")
? o1.RoundedTo(:Max)
#--> "123.0000000000"

pf()
# Executed in 0.05 second(s)

/*-----------------------

pr()

o1 = new stzNumber("12.456")

? o1.RoundedTo(:Max)
#--> 12.456

? o1.RoundedTo(0)
# --> "12"

? o1.RoundedTo(1)
#--> "12.5"

? o1.RoundedTo(2)
#--> "12.46"

? o1.RoundedTo(3)
#--> "12.456"

? o1.RoundedTo(4)
#--> "12.456"

? o1.RoundedTo(5)
#--> "12.456"

pf()
# Executed in 0.19 second(s)

/*=================

pr()

Q(14) {

	? IsDividableBy(2)
	#--> TRUE

	? IsDividableBy("2")
	#--> TRUE

	? IsDividableBy("2.00")
	#--> TRUE

	? IsDividableBy("2.001")
	#--> FALSE
}

pf()

/*-----------------------  #ERROR

? StzNumberQ("25").Modulo("5")

/*-----------------------

o1 = new stzBinaryNumber("0b00101011000011")
? o1.ToDecimalForm()

/*-----------------------

o1 = new stzNumber("12500")
? o1.ToBinaryForm()

/*-----------------------

o1 = new stzNumber("-328")
? o1.ToBinaryForm()

/*-----------------------

o1 = new stzNumber("12500")
? o1.ToHexForm()
? o1.ToOctalForm()

? o1.ToHexFormWithoutPrefix()
? o1.ToOctalFormWithoutPrefix()

/*----------------------- ERROR

o1 = new stzNumber("12500")
? o1.ToBinaryFormwithoutPrefix()

/*----------------------- /////

o1 = new stzNumber(24)
? o1.SubStructQ(12).Content()
? o1.AddManyXT([ "4.65775", "3", "2" ], :ReturnIntermediateResults = TRUE)
//? o1.SubStructManyXT([ "12", "10.6532", "3" ], :ReturnIntermediateResults = TRUE )
//? o1.Content()
/*
? o1.ToBinaryFormWithoutPrefix()
? o1.ToSignedBinaryFormWithoutPrefix()
//? o1.ToSignedBinaryForm()
/*
//o1 = new stzNumber("-12_349") #ERRor with ? o1.HasFractionalPart()
o1 = new stzNumber("-12_349.23")

//? o1.Number()
//? o1.IntegerPartValue()
//? o1.FractionalPart()
//? o1.FractionalPartToBinaryFormWithoutZeroDot()
? o1.IntegerPartToBinaryForm()
? o1.ToBinaryForm()
/*
? o1.IntegerPartValue()
? o1.IntegerPartWithoutSign()
? o1.FractionalPart()
? o1.FractionalPartWithoutZeroDot()

/*
//o1 = new stzNumber("o30467")
//o1 = new stzNumber("xE019")
o1 = new stzNumber("b100110011")
o1 = new stzNumber("369900990099")
? o1.RemoveSignQ().Content() # or o1.SignRemoved()
? o1.NumberOfDigitsInIntegerPart()
? o1.Round()

/*-------------- #TODO Review implementation

pr()

o1 = new stzNumber(12590)
? o1.ApplyFormatXT([
	# Precision
	:RestrictFractionalPart = FALSE,
	:NumberOfDigitsInFractionalPart = 5,
	:RoundItWhenRestricted = FALSE,

	# Round
	:ApplyRound = TRUE,
	:RoundTo = 5, # !! change this to 2 ans see result

	# Adjustment
	:Width = 15,
	:FillBlanksWith = " ",

	:AlignTo = :Center, # :Left, :Right
	:FixPrefixToLeft = TRUE,
	:FixSuffixToRight = FALSE,
	
	# Sign
	:ShowSign = TRUE,
	:PutNegativeBetweenParentheses = TRUE,

	# Prefix, separators, and suffix
	:Prefix = "$",

	:ThousandsSeparator = ".",
	:FractionalSeparator = ",",

	:Suffix = _NULL_,

	# Conversion
	:ToPercentage = FALSE,
	:ToScientificNotation,

	:ToHex,
	:ToBinary,
	:ToOctal,
	:ToBase = 0,

	:ToIndian,
	:ToRoman
])

pf()

/*---

pr()

#TODO in stzListOfNumbers() -> Applyformat
#	$     (15.600,00)
#	$       3.182,15
#	$         404,82

pf()

/*---

pr()

? StringToNumber("x12.34")
#--> 18

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*---

pr()

SetActiveRound(10)
? GetActiveRound()

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzNumber("4")
? o1.IsOneDigit()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*------

pr()

o1 = new stzNumber("259715288")
o1 {
	? Number()

	? UnitsInHundreds() 	#--> 8
	? DozensInHundreds()	#--> 28
	? HundredsInHundreds()	#--> 2
}

pf()
# Executed in 0.05 second(s) in Ring 1.22

/*

o1 = new stzNumber(12_531_078_512_456)
? o1.Structure()
? o1.AllUnits()

o1 {
	? Billions()
	? BillionsXT()
	
	? UnitsInBillions()
	? DozensInBillions()
	? HundredsInBillions()
	
	? HasBillions()
}

/*
o1 = new stzNumber("2345")
? o1.Sign()
? o1.IsPositive()

/*---- // TODO: ERROR

o1 = new stzNumber("27 898 116.56")
? o1.Structure(:AsListOfLists)
/*
	Returns:
	atrillions
		units: 0
		dozens: 0
		Thousands: 0
	abillions
		units:0
		dozens: 0
		Thousands: 0
	amillions
		units: 7
		dozens: 2
		Thousands: 0
	athousands
		units: 8
		dozens: 9
		Thousands: 8
	aHundreds
		units: 6
		dozens: 1
		Thousands: 1
*/
/*
? sin(13) # Gives 0.42
o1 = new stzNumber(13)
? o1.Sine() # Gives 0.4201670368266
/*
? IntegerPart(12.567)
? IsBit(3)

SetActiveRound(3)
? getActiveRound()

n = StringToNumber("12")
? n

? IsInteger(56.145)

? GetUnitsDozensAndThousands(125)
? GetMicroStructure(113)
/*
// Coverting a number from any form to any form

? NumberConvert("1031", :FromDecimal, :ToDecimal)
? NumberConvert("1031", :FromDecimal, :ToBinary)
? NumberConvert("1031", :FromDecimal, :ToOctal)
? NumberConvert("1031", :FromDecimal, :ToHex)
? ""
? NumberConvert("b10000000111", :FromBinary, :ToDecimal)
? NumberConvert("b10000000111", :FromBinary, :ToBinary)
? NumberConvert("b10000000111", :FromBinary, :ToOctal)
? NumberConvert("b10000000111", :FromBinary, :ToHex)
? ""
? NumberConvert("o2007", :FromOctal, :ToDecimal)
? NumberConvert("o2007", :FromOctal, :ToBinary)
? NumberConvert("o2007", :FromOctal, :ToOctal)
? NumberConvert("o2007", :FromOctal, :ToHex)
? ""
? NumberConvert("x407", :FromHex, :ToDecimal)
? NumberConvert("x407", :FromHex, :ToBinary)
? NumberConvert("x407", :FromHex, :ToOctal)
? NumberConvert("x407", :FromHex, :ToHex)



/*
? NumberIsInDecimalForm("1031")
? NumberIsInOctalForm("o2700")
? NumberIsInBinaryForm("b111010000010")
? StringContainsNumberInHexform("x407")
? ""

// Converting a decimal number to binary, octal and hex
o1 = new stzNumber("1031")
? o1.Number()
? o1.ToBinary()
? o1.ToOctal()
? o1.ToHex()
? ""

// Converting binary, octal and hex numbers to decimal
o1 = new stzNumber("")
o1.FromBinary("b10000000111")
? o1.Content()

o1.FromHex("x407")
? o1.Content()

o1.FromOctal("o2007")
? o1.Content()

