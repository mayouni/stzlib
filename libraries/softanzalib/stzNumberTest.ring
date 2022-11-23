load "stzlib.ring"


/*-----------------

? Q(25).MultiplesUntilQR(1050, :stzListOfNumbers).
	LeastCommonNumber(:With = Q(42).MultiplesUntil(1050) )
#--> 1050

/*-----------------

o1 = new stzListOfNumbers([8, 12, 89, 46])
? o1.LeastCommonNumber(:With = [4, 6, 12, 89]) 		#--> 12
? o1.GreatestCommonNumber(:With = [4, 6, 12, 89])	#--> 89

/*-----------------
*/
# Least common multiple between 25 and 42
? Q(25).LeastCommonMultiple(:With = 42) # or simply Q(25).LCM(42)
#--> 1050

# Ok, but how this is found in practice, like if we make it by hand?
# First, let's see the multiples of 25 up to 1050
aList1 = Q(25).Multiples(:UpTo = 1050)
#--> [
#	25, 50, 75, 100, 125,
#	150, 175, 200, 225, 250,
#	275, 300, 325, 350, 375,
#	400, 425, 450, 475, 500,
#	525, 550, 575, 600, 625,
#	650, 675, 700, 725, 750,
#	775, 800, 825, 850, 875,
#	900, 925, 950, 975,
#	1000, 1025, 1050
# ]

# This means that 25 should be multiplied 42 times to obtain 1050.
? len(aList1)

# Then we look to the multiples of 42 up to 1050
aList2 = Q(42).Multiples(:UpTo = 1050)
#--> [
#	42, 84, 126, 168, 210,
#	252, 294, 336, 378, 420,
#	462, 504, 546, 588, 630,
#	672, 714, 756, 798, 840,
#	882, 924, 966, 1008, 1050
# ]

# Note that they are 25 times:
? len(aList2) # You can also use Q(42).NumberOfMultiples(:UpTp = 1050)

#--> The fact of multipying 25 up to 42 times before we reach 1050,
# and multiplying 42 up to 25 times to reach the same number,
# means that the two numbers actually don't have any common multiple
# before 1050 itself. This can be suffucent to deduce that 1050 is
# effectively the Least Common Multiple of 25 and 42.

# But, I know, for some of us, this seams to be some how abstract.
# Hopefully, there is an other concrete way to check it. And this is
# what we do in practice:

# we scan the numbers of aList1 and aList2 and see what is the first
# common number between them. Try to do it manually...

# It takes some time before you see that the last number, 1050, is
# actually the uniqie common number between the two lists! Now we
# are convainced the output of Sioftanza function LCM() was correct/

# for 1050 to effectively be the LCM of 25 and 42, the least common
# number between aList1 and aList2 should be 1050. Let's check it:
? StzListOfNumbersQ(aList1).LeastCommonNumber(aList2)
#--> 1050

# We are done! We demonstrated our initial result.

# We would be able to make the job in only one line
? Q(25).MultiplesUntilQR(1050, :stzListOfNumbers).
	LeastCommonNumber(:With = Q(42).MultiplesUntil(1050) )
#--> 1050

/*-----------------

? @@S( Q(25).MultiplesUpTo(1050) ) + NL
#--> [
#	25, 50, 75, 100, 125,
#	150, 175, 200, 225, 250,
#	275, 300, 325, 350, 375,
#	400, 425, 450, 475, 500,
#	525, 550, 575, 600, 625,
#	650, 675, 700, 725, 750,
#	775, 800, 825, 850, 875,
#	900, 925, 950, 975,
#	1000, 1025, 1050
# ]

? @@S( Q(42).MultiplesUpTo(1050) ) + NL
#--> [
#	42, 84, 126, 168, 210,
#	252, 294, 336, 378, 420,
#	462, 504, 546, 588, 630,
#	672, 714, 756, 798, 840,
#	882, 924, 966, 1008, 1050
# ]


/*----------------

# Least common multiplier between 25 and 42
? Q(25).LCM(42)
#--> 1050

? @@S( Q(1050).PrimeFactorsXT() ) + NL
#--> [ [ 2, 525 ], [ 3, 350 ], [ 5, 210 ], [ 7, 150 ] ]

? @@S( Q(1050).FactorsXT() )
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


/*

for i = 1 to 300
	n1 = 25 * i
	n2 = 42 * i
	if n1 = n2
		? i
	ok
next
? "end"


/*
( Q(11) * [2, 3] ).Content()


/*------------------

o1 = new stzNumber(11)
//? o1.RepeatedNTimes(3)
#--> [11, 11, 11]

# Don't confuse with:
o1.Times(3)
? o1.Value()
#--> 33

o1.Times([2, 3])
? o1.Value()

/*------------------

o1 = new stzNumber(11)
o1.MultiplyByMany([2, 3])
? o1.Value()
#--> 66

/*------------------

o1 = new stzNumber(5)
? @@S( o1.RepeatXT(:InA = :List, :OfSize = 2) )
#--> [ 5, 5 ]

? o1.RepeatXT(:InA = :String, :OfSize = 7)
#--> "5555555"

? @@S( o1.RepeatXT(:InA = :Grid, :OfSize = [3, 3]) )
#-->
# [
# 	[ "5", "5", "5" ],
# 	[ "5", "5", "5" ],
# 	[ "5", "5", "5" ]
# ]

/*-----------------------

? o1.RepeatedInAPair()
#--> [5, 5]

/*-----------------------

o1 = new stzNumber(5)
? ring_type(o1.Number()) #--> NUMBER

/*-----------------------

? o1.RepeatedInAPairQ().Types()
#--> [ "STRING", "STRING" ]

/*-----------------------

? @@S( CircledNumbers() )
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

/*-----------------------

 ? Q(10) ^ 3 #--> 1000

/*-----------------------

o1 = new stzNumber( 55993400908134 )
decimals(12) # TODO: should return numbers above in string form with the max round
? o1.Sine()		# --> -0.999864884364
? o1.Cosine()		# --> -0.016438157335
? o1.Tangent() 		# --> 60.825849514064
? o1.Cotangent() 	# --> 0.016440378687

/*-----------------------

? StzNumberQ(1).UpTo(7) 	# --> 1:7
? StzNumberQ(7).DownTo(1)	# --> 7:1

/*-----------------------

? _(5.12).@.IsEqualTo(5.1200000000000000000001)

? _(5.12).@.IsEqualTo("5.1200000000000000000001")	# Because "5.12" is a number in string

/*-----------------------

? RingMaxRound()	# --> 90

/*-----------------------

o1 = new stzNumber(-123)
? o1.RoundTo(3)	# "-123.000"

/*-----------------------

o1 = new stzNumber("123") 
? o1.RoundTo(:Max)	# --> "123.000000000000"

o1 = new stzNumber("123345678912345")
? o1.RoundTo(:Max)	# --> "123345678912345"

/*----------------------- REVIEW

o1 = new stzNumber("123.")
? o1.RoundTo(:Max)	# --> "123.0000000000"

/*-----------------------

o1 = new stzNumber("12.456")
? o1.RoundTo(:Max)	# --> 12.456
? o1.RoundTo(0) 	# --? "12"
? o1.RoundTo(1) 	# --> "12.5"
? o1.RoundTo(2) 	# --> "12.46"
? o1.RoundTo(3) 	# --> "12.456"
? o1.RoundTo(4)	 	# --> "12.456"
? o1.RoundTo(5)		# --> "12.456"


/*-----------------------

? StzNumberQ(14).IsDividableBy(2)

/*-----------------------  # ERROR

o1 = new stzNumber(120)
aResult = o1.ListifyXT([ :NumberIsContainedInString = FALSE ])
? aResult
? type(aResult[1])

/*-----------------------  # ERROR

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
? o1.SubstractQ(12).Content()
? o1.AddManyXT([ "4.65775", "3", "2" ], :ReturnIntermediateResults = TRUE)
//? o1.SubstractManyXT([ "12", "10.6532", "3" ], :ReturnIntermediateResults = TRUE )
//? o1.Content()
/*
? o1.ToBinaryFormWithoutPrefix()
? o1.ToSignedBinaryFormWithoutPrefix()
//? o1.ToSignedBinaryForm()
/*
//o1 = new stzNumber("-12_349") # Error with ? o1.HasFractionalPart()
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

/*--------------

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

	:Suffix = NULL,

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

/*
TODO in stzListOfNumbers() -> Applyformat
	$     (15.600,00)
	$       3.182,15
	$         404,82

*/

/*
? StringToNumber("x12.34")
/*
SetActiveRound(10)
? GetActiveRound()

/*
o1 = new stzNumber("4")
? o1.IsOneDigit()

/*
o1 = new stzNumber("  12543 110 ")
? o1.RemoveSpacesFrom(:TheLeft)

/*------

o1 = new stzNumber("715")
o1 {
	? Number()

	? UnitsInHundreds()
	? DozensInHundreds()
	? HundredsInHundreds()
}


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


/* TEMPLATE

? "" #-----------

	if oNbr.nbr...() = ...
		? "Testing oNbr.nbr...() ---> Ok :)"
		? " - Correctly returned : ..."
	else
		? "Testing oNbr.nbr...() ---> Failed :("
		? " - Should return : ..."
		? " - But returned  : " + oNbr.nbr...()
	ok
*/
/*
oNbr = new stzNumber("123456.12345678")

? "BEGIN" + NL #-----------

	if oNbr.nbrValue() = "123456.12345678"
		? "Testing oNbr.nbrValue() -> Ok :)"
		? ' - Correctly returned "123456.12345678"'
	else
		? "Testing oNbr.nbrValue() -> Failed :("
		? ' - Should return : "123456.12345678"'
		? " - But returned  : " + oNbr.nbrValue()
	ok

? "" #-----------

	if oNbr.nbrOfDigits() = 14
		? "Testing oNbr.nbrOfDigits() -> Ok :)"
		? " - Correctly returned : 14"
	else
		? "Testing oNbr.nbrOfDigits() -> Failed :("
		? " - Should return : 14"
		? " - But returned  : " + oNbr.nbrOfDigits()
	ok

? "" #-----------

	if oNbr.nbrIntegerPart() = "123456"
		? "Testing oNbr.nbrIntegerPart() -> Ok :)"
		? ' - Correctly returned : "123456"'
	else
		? "Testing oNbr.nbrIntegerPart() -> Failed :("
		? ' - Should return : "123456"'
		? ' - But returned  : "' +
					    oNbr.nbrIntegerPart() + '"'
	ok

? "" #-----------

	if oNbr.nbrOfIntegers() = 6
		? "Testing oNbr.nbrOfIntegers() -> Ok :)"
		? " - Correctly returned : 6"
	else
		? "Testing oNbr.nbrOfIntegers() -> Failed :("
		? " - Should return : 6"
		? " - But returned  : " + oNbr.nbrOfIntegers()
	ok

? "" #-----------

	if oNbr.nbrDecimalPart() = "0.12345678"
		? "Testing oNbr.nbrDecimalPart() -> Ok :)"
		? ' - Correctly returned : "0.12345678"'
	else
		? "Testing oNbr.nbrDecimalPart() -> Failed :("
		? ' - Should return : "0.12345678"'
		? " - But returned  : " + oNbr.nbrDecimalPart()
	ok

? "" #-----------

	if oNbr.nbrOfDecimals() = 8
		? "Testing oNbr.nbrOfDecimals() -> Ok :)"
		? " - Correctly returned : 8"
	else
		? "Testing oNbr.nbrOfDecimals() -> Failed :("
		? " - Should return : 8"
		? " - But returned  : " + oNbr.nbrOfDecimals()
	ok

? "" #-----------

	if oNbr.nbrRoundedTo(3) = "123456.123"
		? "Testing oNbr.nbrRoundedTo(3) -> Ok :)"
		? ' - Correctly returned : "123456.123"'
	else
		? "Testing oNbr.nbrRoundedTo(3) -> Failed :("
		? ' - Should return : "123456.123"'
		? " - But returned  : " + oNbr.nbrRoundedTo(3)
	ok

#-----------

	if oNbr.nbrRoundedSameAs("28.5") = "123456.1"
		? 'Testing oNbr.nbrRoundedSameAs("28.5") -> Ok :)'
		? ' - Correctly returned : "123456.1"'
	else
		? 'Testing oNbr.nbrRoundedSameAs("28.5") -> Failed :('
		? ' - Should return : "123456.1"'
		? " - But returned  : " + oNbr.nbrRoundedSameAs("28.5")
	ok

? "" #-----------

	if oNbr.nbrUnifyRoundWith("28.302", :toGreatest)[1] = "123456.12345678" and
	   oNbr.nbrUnifyRoundWith("28.302", :toGreatest)[2] =     "28.30200000"
		? 'Testing oNbr.nbrUnifyRoundWith("28.302",:toGreatest) -> Ok :)'
		? ' - Correctly returned : [ "123456.12345678" , "28.30200000" , 8 ]'
	else
		? 'Testing oNbr.nbrUnifyRoundWith("28.302",:toGreatest) -> Failed :('
		? ' - Should return : [ "123456.12345678" , "28.30200000" , 8 ]'

		cFirstItem  = '"' +
			      oNbr.nbrUnifyRoundWith("28.302",:toGreatest)[1] + '"'
		cSecondItem = '"' +
			      oNbr.nbrUnifyRoundWith("28.302",:toGreatest)[2] + '"'
		nThirdItem  = oNbr.nbrUnifyRoundWith("28.302",:toGreatest)[3]
		? " - But returned  : [ " + cFirstItem + " , " + cSecondItem + " , " + nThirdItem + " ]"
	ok

	#-----------

	if oNbr.nbrUnifyRoundWith("28.302", :toSmallest)[1] = "123456.123" and
	   oNbr.nbrUnifyRoundWith("28.302", :toSmallest)[2] =     "28.302"
		? 'Testing oNbr.nbrUnifyRoundWith("28.302",:toSmallest) -> Ok :)'
		? ' - Correctly returned : [ "123456.123" , "28.302" , 3 ]'
	else
		? 'Testing oNbr.nbrUnifyRoundWith("28.302",:toSmallest) -> Failed :('
		? ' - Should return : [ "123456.123" , "28.302" , 3 ]'
		cFirstItem  = '"' +
			      oNbr.nbrUnifyRoundWith("28.302",:toSmallest)[1] + '"'
		cSecondItem = '"' +
			      oNbr.nbrUnifyRoundWith("28.302",:toSmallest)[2] + '"'
		nThirdItem  = oNbr.nbrUnifyRoundWith("28.302",:toSmallest)[3]
		? " - But returned  : [ " + cFirstItem + " , " + cSecondItem + " , " + nT hirdItem + " ]"
	ok

