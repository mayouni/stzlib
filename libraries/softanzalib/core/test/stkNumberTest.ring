
load "../common/stkNumberCommons.ring"
load "../number/stkNumber.ring"
load "../error/stkError.ring"

load "../number/stkSciNumber.ring"

/*== Flexible initialisation

# The object is initialised with a number

o1 = new stzCoreNumber(123.4)

	# We can check that numeric value

	? o1.NValue()
	#--> 123.40

	# along with its string representation

	? o1.SValue()
	#--> '123.40'

	#NOTE

	# As you can see, the string value contains 2 rounds.
	# That's because even though we wrote 123.4 in the
	# initialisation of the object, its effective value
	# is 123.40.

	# In this case, the current round (which is 2 by default)	
	# is used to transform the number into a string:

	? CurrentRound()
	#--> 2

	decimals(3)
	o1 = new stkNumber(123.4)

	? o1.SValue() + NL
	#--> '123.400'

# The other way around, we can provide a number in string

decimals(2) # to set the default round back

o2 = new stzCoreNumber("678.908")

	# The string value stays the same

	? o2.SValue()
	#--> "678.908"

	# And the object identifies the round 3 defined by the string

	? o2.Round()
	#--> 3

	# But the numeric value is impacted by the current round
	# in the program (which is 2 in our case)

	? o1.NValue()
	#--> 123.40

	# The advantage of storing the round provided by the string
	# is that we can use it to make calculations:

	? o2 - "0.201"
	#--> '678.707'

/*---

oNum = new stzCoreNumber(1234.56)

cQuery = "INSERT INTO transactions (amount) VALUES ('" +
	  oNum.SValue() + "')"

? cQuery
#--> "INSERT INTO transactions (amount) VALUES ('1234.56')"

/*== Rounding protection

decimals(2)  # Default in Ring

o1 = new stzCoreNumber("123.4567")
? o1.Round()
#--> 4

? o1.SValue()
#--> "123.4567"

? o1.NValue()
#--> 123.46 (affected by global decimals)

/*=== Sign

oPositive = new stzCoreNumber(42)
oNegative = new stzCoreNumber(-42)

? oPositive.Sign()
#--> "+"

? oNegative.Sign()
#--> "-"

/*---

o1 = new stkNumber("-23.656")

# Including the minus in decimal part of negative numbers

	? o1.DecimalPart()
	#--> 0.66
	
	o1.WithMinusInDecimalPart()
	
	? o1.DecimalPart()
	#--> -0.66
	
	o1.NoMinusInDecimalPart()
	
	? o1.DecimalPart() + NL
	#--> 0.66

# Same test using the string representation of the number
# (note how the value keeps the defined round in the string)

	? o1.StringDecimalPart()
	#--> '0.656'
	
	o1.WithMinusInDecimalPart()
	
	? o1.StringDecimalPart()
	#--> '-0.656'
	
	o1.NoMinusInDecimalPart()
	
	? o1.StringDecimalPart() + NL
	#--> '0.656'

/*=== Integer and Decimal Parts

o1 = new stzCoreNumber(123.45)

? o1.IntPart()
#--> 123

? o1.SIntPart()
#--> "123"

? o1.DecPart()
#--> 0.45

? o1.SDecPart()
#--> "0.45"

/*-- Show and hide positive sign in string display

o1 = new stkNumber("12.4")
? o1.SValue()
#--> '12.4'

? o1.@bShowPositive
#--> FALSE

o1.ShowPositive()

? o1.@bShowPositive
#--> TRUE

? o1.SValue()
#--> '+12.4'

o1.HidePositive()

? o1.@bShowPositive
#--> FALSE

? o1.SValue()
#--> '12.4'

/*---

oDuration = new stzCoreNumber(3.75)  # 3 hours and 45 minutes
nHours = oDuration.IntPart()
nMinutes = oDuration.DecPart() * 60

? "Duration: " + nHours + " hours and " + nMinutes + " minutes"
#--> Duration: 3 hours and 45 minutes

/*--- Number spacification

o1 = new stzCoreNumber(1234567890.123456)

? o1.Spacified()
#--> 1_234_567_890.12"

# we get 2 rounds in the string representation because 2 is
# the courrent rount in the program:

? CurrentRound()
#--> 2

# Hence, the number we provided (1234567890.123456) is automatically
# orounded by Ring to 2 positions:

? 1234567890.123456
#--> 1234567890.12

# Then, the stzNumber object just stringifies it to get
# the corresponding output ("1234567890.12")

# You can internally change the round of the number independently
# from the gloabl round in the Ring program:

o1.SetRound(5)
? o1.Spacified()
#--> 1_234_567_890.12346

o1.SetRound(3)
? o1.Spacified()
#--> 1_234_567_890.123

/*--------

? NumberSpacify(-511_234_567_890.123456, "_", 3, 3)
#--> '-511_234_567_890.12'

/*----//// #ring why rounding is not precise? what impact? what is the solution?

n = 0+ "11234567890.123"
? n
#--> -511234567890.12

decimals(7)
? n
#--> 11234567890.1229992

/*-----

o1 = new stkNumber("1223.87636")
? o1.Round()
#--> 5

/*-----

? SFract("1223.87636")

//? SFract(-511_234_567_890.12)

/*====== MaxRound()
*/
? log10(10)

? Sci2Number("3.4028235e+38")
#--> 340282349999999953975856880824270979072.00

/*--

? MaxInt(1234567890123456789012345)
#--> 15                 \__________ non-significant integer part

? MaxInt(1234567890123456789012345.1234567890123456789012345)
#--> 15                 \__________ non-significant integer part

? MaxRound(1234567890123456789012345)
#--> 0

? MaxRound(1234567890123456789012345.1234567890123456789012345)
#--> 0

? MaxRound(8.1234567890123456789012)
#--> 14                    \_______ non-significant fractional part

# Number with large integer part

? MaxRound(1234567890123456789012345.345)
#--> 0

# Number with both large integer and fractional part

? MaxRound(9999999999999.12345678901234)
#--> 2                     \___________ Over-digits

? MaxRound(0.123456789012345678901234)
#--> 14                    \___________ Over-digits



/*-----

? Round(8.1234567890123456789012)

decimals(15)
? 8.1234567890123456789012 * 3

rnf

? Round("-511_234_567_890.1232")
#--> 2                      \_ this part is not considered

? Round("8.1234567890123456789012")
#--> 14                  \_______ this part will round the 4 to 5

? MaxRound("8.1234567890123456789012")
#--> 14

df
/*-----

o1 = new stkNumber("8.1234567890123456789012")
? o1.SValue()
? o1.Round()
#--> 13

sdsd
/*----- #ring

? substr("8.1234567890123456789012", "_", "")
#--> "8.1234567890123456789012"

/*-----

o1 = new stzCoreNumber("-511_234_567_890.123")

? o1.SIntegerPart()
# '-511_234_567_890'

? o1.Round()

? o1.SValue()
#--> '-511_234_567_890.123'

sdsds
? o1.Spacified()
#--> '-511_234_567_890.12'

o1.Unspacify()
? o1.SValue()
#--> '-511234567890.123'

o1.Spacify()
? o1.SValue()
#--> '-511_234_567_890.123'

/*--------

o1 = new stkNumber("12_300")

? o1 + 250	# ~> returns a number

? o1 + "250"	# ~> returns a string
#--> '12550'

? o1.Value()
#--> 12550

/*==========

# Precision Handling in Ring using SoftanzaCore

	# Ring uses C Double data type for storing numbers (C FLOAT in Ring Embedded).
	# This implementation has precision limitations:
	#   - Positive doubles: accurate up to 15 decimal digits
	#   - Negative doubles: accurate up to 14 decimal digits
	
	# Any digits beyond these limits are not calculable by Ring, and the number is rounded
	# to fit within the maximal fraction limit. The SoftanzaCore library provides tools
	# to handle these precision issues effectively.
	
	# The Round() function
	# -------------------
	# Round() determines the effective round of any number by identifying the
	# non-meaningful part beyond the precision limit.
	
	# Demonstrating Round() function:
	? Round(-234.87663637188362538)
	#--> 9
	
	# The function returns 9, indicating that 9 decimal places are meaningful.
	# The effective number taken into account by Ring is: -234.876636372
	# Note that the last digit (1) has been rounded to (2).
	
	# The stzCoreNumber class
	# -----------------------
	
	# This class uses Round() implicitly when initializing a number, ensuring
	# that numbers are always stored with their effective precision.
	
	o1 = new stkNumber(-234.87663637188362538)
	
	# Effective round:
	? o1.Round()
	#--> 9
	
	# String representation (maintains precision):
	? o1.SValue()
	#--> '-234.876636372'
	
	# Numeric value (affected by current round setting):
	? o1.NValue() + NL
	#--> -234.88
	
	# Additional examples
	# -------------------
	
	# Example with a positive number:
	
	o2 = new stkNumber(123.456789012345678)
	#                                 \___ non-meaningful fraction
	? o2.Round()
	#--> 11
	
	? o2.SValue()
	#--> '123.45678901235'
	
	? o2.NValue() + NL
	#--> 123.46
	
	# Example with a very large number:
	o3 = new stkNumber(1234567890127.789)
	
	? o3.Round()
	#--> 1
	
	? o3.SValue()
	#--> '1234567890127.8'
	
	? o3.NValue()
	#--> 1234567890127.79
	#                   \_ The 9 is not meanigful, because it exeeds the max
	# 		       capacity of overall of 15 figits representable in
	# 		       a Ring number. In any calculation Ring will round
	# 		       the number to 1234567890127.8 and works with it.

	# 		       ~> which is the exact value you get in the string
	# 		       representation in stkNumber obtaine by SValue()!

	# Conclusion
	# ----------
	# The SoftanzaCore library provides tools to handle precision limitations
	# in Ring effectively. By using the Round() function and stzNumber class,
	# developers can work with numbers in a way that respects the language's
	# inherent precision limits while maintaining as much accuracy as possible.

/*==========

# ~> Ring uses C Double data type for storing numbers (In Ring Embedded, C FLOAT is used)
# ~> Positive Doubles can accurately represent up to 15 decimal digits.
# ~> Negative Doubles can accurately represent up to 14 decimal digits.

# ~> Any digits beyond these limits are not calculable by Ring, and the number is rounded
#    to cope with the 15 or 14 maximal fractions.

# ~> Softanza has the Round() function to get the effective round of any number:


? Round(-234.87663637188362538)
#--> 9                \______/ non-meaningful part

# Then, the number effevtively taken in account by Ring is: -234.876636372
# ~> You can seee that the last digit 1, has been rounded to 2.

#NOTE
# this Round() function is used implcitely by stzCoreNumber in intiating a number.
# Hence, whatever precision you provide, the class will round to its effective round.

o1 = new stkNumber(-234.87663637188362538)

? o1.Round()
#--> 9

? o1.SValue()
#--> '-234.876636372'

# I used SValue() and not NValue() because NValue() return the numeric value of the
# number which is impacted ny the current round.

? o1.NValue()
# -234.88

/*-----------

? IsInteger(12)
#--> TRUE

? Round(12)
#--> 0

? Round(12.7)
#--> 1

? Round(12.8977)
#-->4

? Round(12.8657239)
#--> 7

	# In fact:

	decimals(15)
	? 12.8657239
	#--> 12.865723900000001
	#              \_ the fraction starting from the first 0 is not meanigful


/*========


# Let's make this multiplication

n = 12.576 * 3.27
? n
#--> 41.12

# Bey default, ring rounds numbers to 2 positions.
# This may hide some numbers in the fractional part.
# Let's extend the decimals() round and see:

decimals(10)
? n
#--> 41.1235200000

# Hence, the product of 12.576 by 3.27, according to
# Ring, is equal to 41.12352

# Softanza has a Round() function that can determine the
# effective round of any number, whatever value is currently
# used in Ring decimals()

? Round(n)
#--> 5

# The number can be transformed to a stzCoreNumber
# and then we can check its string representation

o1 = new stkNumber(n)

? o1.SValue()
#--> '41.12352'

? o1.SFractionalValue()
#--> 0.12352

? NL + "---" + NL

? o1 * "3.27"
#--> '41.09409'

/*--------

o1 = new stkNumber("12.567")
? o1 * "3.27"
#--> '41.09409'

/*--------

o1 = new stkNumber("12300")

? o1 + "2_200"	# spacifies the number, does not alter its value
#--> 14_500

? o1.Value()
#--> 12300

? o1 * 2
#--> 24600	#~> a number because 2 is a number

? o1 * "1_000"
#--> 24_600_000	#~> a spacified string because "1_000" intsructed it to do so

? o1 / 2
#--> 12300000	#~> a number

? o1 / "2_000"
#--> 6_150	#~> a string

*--------


o1 = new stkNumber(14500.90)
? o1.Spacified()
#--> 14_500.90

/*------- #ring

# By default, Ring rounds numbers to 2 positions

n = 12.8745
? n
#--> 12.87

# But internally, the hole decimal part is not lost:

decimals(4)
? n
#--> 14500.90

# That's why stzCoreNumber class, although it has a
# dual representation of numbers (in number and string)
# for practical reasons, the number representation
# should stay it's single source of the truth.

/*------- #ring

? CurrentRound()
#--> 2

decimals(3)
? CurrentRound()
#--> 3

decimals(12)
? CurrentRound()
12

/*-------

o1 = new stkNumber("12300.112")

? o1.NValue()
#--> 12300.11

? o1.Spacified() + NL
#--> '12_300.112'

o1.Add("2_200.789")

? o1.NValue()
#--> 14500.90

? o1.Spacified()

? o1.SValue()


/*--------

o1 = new stkNumber("-12_150_340")

o1.Add(-660)
? o1.NValue()
#--> -12151000

? o1.Spacified()
#--> '-12_151_000'

? o1 - 4800
#--> -12155800		#~> a number because 4800 is a number

? o1 + "800"
#--> -12_155_000	#~> a string because "800" is a string,
			#   spacified because the initial number
			#   "-12_150_340" is spacified



/*--- Precision calculations ///////////////


oNumber = new stzCoreNumber("12.345")
? oNumber * 7.1878
#--> 88.64 (numeric output, global decimals applied)

? oNumber * "5_100.87335"
#--> "88.6371" (string output, maximum precision)
/*
oNumber.SetRound(2)
? oNumber * "7.18"
#--> "88.64" (string output, specified precision)


/*---- //////////////////////////

oNumber = new stzCoreNumber("12_340_560.12")
? oNumber / "2"
#--> "6_170_280.06"

oNumber.Unspacify()
? oNumber / "2"
#--> "6170280.06"

/*---

oNumber = new stzCoreNumber("12340560.12")
? oNumber / "2"
#--> "6170280.06"

oNumber.Spacify()
? oNumber / "2"
#--> "6_170_280.06"

