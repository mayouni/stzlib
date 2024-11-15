
load "../stzcore.ring"

# TODO: WORK IN PROGRESS

decimals(3)
t0 = clock()


/*------- #Todo Divide() lacking

oBig = new stkBigNumber("324987182091876345.078")

oBig.Divide("876234987333.9876673")
	? oBig.SValue()
	#--> 370890.442392
	? oBig.Round() + NL
	#--> 6

oBig = new stkBigNumber("1.5")
	oBig.Divide("0.3")
	? oBig.SValue()
	#--> 5
	? oBig.Round() + NL
	#--> 0

oBig = new stkBigNumber("1")
	oBig.Divide("3")
	? oBig.SValue()
	#--> 0.333333
	? oBig.Round() + NL
	#--> 6

oBig = new stkBigNumber("795139556375158458500672312034291657065.10336")
	oBig.Divide("876234987333.9876673")
	? oBig.SValue()
	#--> 907450133661555453466475424.407391
	? oBig.Round() + NL
	#--> 6

oBig = new stkBigNumber("124_280_400.68")
	oBig.Divide("2")
	? oBig.SValue()
	#--> 62140200.34
	? oBig.Round()
	2

# Executed in 0.024 seconds.

/*-------


oBig = new stkBigNumber("324_987_182_091_876_345.078")

? oBig.SValue()
	#--> 324_987_182_091_876_345.078
	? oBig.Round() + NL
	#--> 3

oBig.Add("122_333_987_337_132_339.987653")
	? oBig.SValue()
	#--> 447_321_169_429_008_685.065653
	? oBig.Round() + NL
	#--> 6

oBig.Subtract("122_333_987_337_132_339.987653")
	? oBig.SValue()
	#--> 324_987_182_091_876_345.078
	? oBig.Round() + NL
	#--> 3

oBig.Multiply("122_333_987_337_132_339.987653")
	? oBig.SValue()
	#--> 39_756_977_818_757_922_769_007_316_455_505_225.287321934
	? oBig.Round() + NL
	#--> 9

oBig.Multiply("2")
	? oBig.SValue()
	#--> 79_513_955_637_515_845_538_014_632_911_010_450.10336
	? oBig.Round() + NL
	#--> 5

oBig.Divide("2")
	? oBig.SValue()
	#--> 39_756_977_818_757_922_769_007_316_455_505_225.55168
	? oBig.Round() + NL
	#--> 5

# Executed in 0.039 seconds.

/*-------

oBig = new stkBigNumber("795139556375158458500672312034291657065.10336")

	oBig.Divide("876234987333.9876673")
	? oBig.SValue()
	#--> 907450133661555453466475424.407391
	? oBig.Round() + NL
	#--> 6

	? oBig.Rounded(2) + NL
	#--> 907450133661555453466475424.41

	? oBig.Rounded(4) + NL
	#--> 907450133661555453466475424.4074

	? oBig.Rounded(5) + NL
	#--> 907450133661555453466475424.40739

	? oBig.Rounded(6) + NL
	#--> 907450133661555453466475424.407391

	? oBig.Rounded(1) + NL
	#--> 907450133661555453466475424.4

# Executed in 0.012 seconds.

/*-------

oBig = new stkBigNumber("123_456_789.87")

	? oBig.Rounded(1)
	#--> 123_456_789.9

	? oBig.Rounded(0) + NL
	#--> 123_456_790

# Executed in almost 0 seconds.

/*-------

oBig = new stkBigNumber("123_456_789")
	? oBig.RoundedTo(0)
	#--> 123_456_789

	? oBig.RoundedTo(1)
	#--> 123_456_789.0

	? oBig.RoundedTo(3)
	#--> 123_456_789.000

# Executed in 0.001 seconds.

/*--------- #narration

# stkBigNumber has 3 important criterias regarding rounding:

#	1. It maintains both the current value and the initial value (before any rounding).

#	2. It has methods for both viewing a rounded value (RoundedTo), without modifying
# 	   the number, and actually rounding the number (RoundTo) and thus modifiying it.

# 	3. It keeps track of the current precision (current round) separately from the full
# 	   precision of the initial value.

# Let's check this by example.

# Create a new stkBigNumber object with a large negative number

oBig = new stkBigNumber("-12_345_567_980_117.8765454")

	# Display the current precision of the number

	? oBig.Precision()
	#--> 7
	
	# Display the number rounded to 3 decimal places without changing the original

	? oBig.RoundedTo(3) # Note the use of the passive form ...ed()
	#--> -12_345_567_980_117.877
	
	# Verify that the original precision hasn't changed

	? oBig.Precision()
	#--> 7
	
	# Round the number to 3 decimal places and modify the original object

	oBig.RoundTo(3) # Note the use of the active form of the verb
	
	# Display the new value of the number after rounding

	? oBig.SValue()
	#--> -12_345_567_980_117.877
	
	# Verify that the precision has been updated to 3

	? oBig.Precision()
	#--> 3
	
	# Display the initial value of the number (before any rounding)

	? oBig.SInitialValue()
	#--> -12_345_567_980_117.8765454
	
	# Display the full precision of the initial value

	? oBig.FullPrecision()
	#--> 7

# Hint : test the same number provided without spacifiers, and see
# how all the outputs are returned unspacified.

# Executed in almost 0 seconds.

/*------

# Negative number spacified

oBig = new stkBigNumber("-123_456_789")
	? oBig.RoundedTo(0)
	#--> -123_456_789

# Negative number unspacifed

oBig = new stkBigNumber("-123456789")
	? oBig.RoundedTo(0)
	#--> -123456789

# Executed in almost 0 seconds.



/*------ #narration

# This code demonstrates the flexibility of the stkBigNumber class
# in handling different precision levels. It shows how to:

# 	1. Check and use maximum and default precision settings.
# 	2. Create a BigNumber with a specific value.
# 	3. View and modify the precision of the number.
# 	4. Access the full precision of the original number.
# 	5. Use symbolic precision settings (:Max and :Default).
# 	6. Restore the number to its original state.
# 	7. Observe how different precision settings affect the displayed value.

# The class maintains the original value while allowing for different
# representations based on the specified precision, providing a powerful
# tool for numeric simulation and operations requiring varying precisions.

# Display the maximum allowed precision for BigNumber

? BigNumberMaxPrecision() # A global setting configurable using SetBigNumberMaxPrecision()
#--> 28

# Display the default precision for BigNumber

? BigNumberDefaultPrecision() + NL 	# Idem, configurable.
#--> 6

# Create a new BigNumber object

oBig = new stkBigNumber("12_345_549.878546")

# Display the current precision of the number (defaults to 6)

? oBig.Precision() # Or Round()
#--> 6

# Set the precision of the number to 2 decimal places (applies only to that number)

oBig.SetPrecision(2) # Or SetRound()

# Display the value after setting precision

? oBig.SValue()
#--> 12_345_549.88

# Display the full precision of the original number

? oBig.FullPrecision() # Or FullRound()
#--> 6

# Set the precision to the maximum allowed

oBig.SetPrecision(:Max)

# Display the new precision

? oBig.Precision()
#--> 28

# Display the value with maximum precision

? oBig.SValue()
#--> 12_345_549.8800000000000000000000000000

# Restore the number to its original state

oBig.Restore()

# Set the precision to the default value

oBig.SetPrecision(:Default)

# Display the new precision

? oBig.Precision()
#--> 6

# Display the value with default precision

? oBig.SValue()
#--> 12_345_549.878546

# Set the precision back to 2 decimal places

oBig.SetPrecision(2)

# Display new rounded value

? oBig.SValue()

#--> 12_345_549.88

# Executed in almost 0 seconds.

/*------------

# Getting a spacified representation of a positive number

oBig = new stkBigNumber("324987182091876345.078")
? oBig.Spacified()
#--> 324_987_182_091_876_345.078

# Getting a spacified representation of a positive number

oBig = new stkBigNumber("-11177875676436736363572788363.98")
? oBig.Spacified()
#--> -11_177_875_676_436_736_363_572_788_363.98

# Not that the number it self has not been spacified, only a copy
# of it as we can understand from using the passive form ...ed()

? oBig.Value() + NL
#--> -11177875676436736363572788363.98

# Of course, we can spacify a number permanantly:

oBig = new stkBigNumber("12345678.67")

? oBig.Value()
#--> 12345678.67

oBig.Spacify()
? oBig.Value()
#--> 12_345_678.67

# And than unspacify it:
oBig.UnSpacify()
? oBig.Value()
#--> 12345678.67

# Executed in almost 0 seconds.

/*------------

# stkBigNumber has a nice spacification feature.
# Let's explore it with example

oBig = new stkBigNumber("-12500277113.9887")

	# The spacification concerns only the integer part

	? oBig.IntPart()
	#--> -12500277113 # contains no _ because the initial number is unspacified

	# You want to get a spacified copy of the value ?

	? oBig.IntPartSpacified() # the inial number remains unspacified
	#--> -12_500_277_113

	? ""

	# Usually, you would rather experience spacification
	# when you get the value of the number:

	# So, by default, the number is not spacified:

	? oBig.SValue() # Or Value() ~> S to inform the reader that the value returned is a string
	#--> -12500277113.9887

	# But you can spacify it permanantly:

	oBig.Spacify()

	? oBig.SValue()
	#--> -12_500_277_113.9887

	# Here, you can get an unspacified copy of the value:

	? oBig.Unspacified()
	#--> -12500277113.9887

	# but the main number remains spacified

	? oBig.SValue()
	#--> -12_549_334_289.0987

	# until you unspacifiy it permanantly:

	oBig.Unspacify()
	? oBig.Value()
	#--> -12500277113.9887

	# and there you can get a copy of the value that is spacified

	? oBig.Spacified()
	#--> -12_500_277_113.9887

	# while leaving the main number unspacified:

	? oBig.Value()
	#--> -12500277113.9887

? " "

# If the number is provided with spacification,
# then the output is also spacified:

oBig = new stkBigNumber("12_549_334_289.0987")

	? oBig.SValue()
	#--> 12_549_334_289.0987

# As we saw, you can turn it off:

	oBig.Unspacify()
	? oBig.SValue()
	#--> 12549334289.0987

# And turn it on again:

	oBig.Spacify()
	? oBig.SValue()
	#--> 12_549_334_289.0987

# Executed in 0.001 seconds.

/*======= #ai These tests where proposed by @chatgpt

# Addition Test with Large Numbers

oBig = new stkBigNumber("999_999_999_999_999_999.999")
oBig.Add("1")
? oBig.SValue()
#--> 1_000_000_000_000_000_000.999
? oBig.Round() + NL
#--> 3

# Executed in 0.001 seconds.

/*--------

# Subtraction Test with Negative Results

oBig = new stkBigNumber("1_000_000.000")

oBig.Subtract("2_000_000.000")
? oBig.SValue()
#--> -1_000_000
? oBig.Round() + NL
#--> 0

# Executed in 0.002 seconds.

/*--------

# Multiplication Test with Multiple Rounding Scenarios

oBig = new stkBigNumber("-12_345.6789")
oBig.Multiply("98_765.4321")
? oBig.SValue()
#--> -1_219_326_311.12635269
? oBig.Round() + NL
#--> 8

# Executed in 0.003 seconds.

/*--------

# Division Test with Precision Edge Cases

oBig = new stkBigNumber("1.000000")
oBig.Divide("3")
? oBig.SValue()
#--> 0.333333
? oBig.Rounded(5) + NL
#--> 0.33333
? oBig.Rounded(10) + NL
#--> 0.3333330000

# Executed in 0.003 seconds.

/*--------

# Rounding Test with Large Negative Numbers

oBig = new stkBigNumber("-987_654_321.123456789")
oBig.RoundTo(4)
? oBig.SValue()
#--> -987_654_321.1235.1235

# Executed in almost 0 seconds.

/*-------- #ring

? 999.999999
#--> 1000.000

/*--------

# Precision Adjustment Test

oBig = new stkBigNumber("999.999999")

? oBig.RoundedTo(0)
#--> 1000

? oBig.RoundedTo(1)
#--> 1000.0

? oBig.RoundedTo(2)
#--> 1000.00

? oBig.RoundedTo(3)
#--> 1000.000

? oBig.RoundedTo(4)
#--> 1000.0000

? oBig.RoundedTo(5)
#--> 1000.00000

? oBig.RoundedTo(6)
#--> 999.999999

? oBig.RoundedTo(7)
#--> 999.9999990

? oBig.RoundedTo(8)
#--> 999.99999900

# Executed in 0.001 seconds.

/*--------
*/
oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(0)
	? oBig.SValue()
	#--> 1000

oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(1)
	? oBig.SValue()
	#--> 1000.0

oBig = new stkBigNumber("999.99999")
	oBig.SetPrecision(2)
	? oBig.SValue()
	#--> 1000.00

oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(3)
	? oBig.SValue()
	#--> 1000.000

oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(4)
	? oBig.SValue()
	#--> 1000.0000

oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(5)
	? oBig.SValue()
	#--> 1000.00000

oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(6)
	? oBig.SValue()
	#--> 999.999999

oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(7)
	? oBig.SValue()
	#--> 999.9999990

oBig = new stkBigNumber("999.999999")
	oBig.SetPrecision(8)
	? oBig.SValue()
	#--> 999.99999900

# Executed in 0.002 seconds.

/*======== #ai test cases and explanations by #chatgpt

# Basic Positive Number

oBig = new stkBigNumber("123.456789")
oBig.SetPrecision(3)
? oBig.SValue()
#--> 123.457

#~> The method rounds 456789 to 457 because the next digit (6) is greater than or equal to 5.

# Executed in almost 0 seconds.

/*--------

# Precision Higher than Current

oBig = new stkBigNumber("123.45")
oBig.SetPrecision(5)
? oBig.SValue()
#--> 123.45000

#~> The method pads the fractional part with zeros.

# Executed in almost 0 seconds.

/*--------

# Precision Lower than Current, No Rounding

oBig = new stkBigNumber("123.456")
oBig.SetPrecision(2)
? oBig.SValue()
#--> 123.46

#~> The third digit (6) results in rounding the second digit from 5 to 6.

# Executed in 0 seconds.

/*--------

# Precision Zero, Positive Number

oBig = new stkBigNumber("123.987")
oBig.SetPrecision(0)
? oBig.SValue()
#--> 124

#~> The fractional part is dropped, and the integer part is incremented due to rounding.

# Executed in almost 0 seconds.

/*--------

# Basic Negative Number

oBig = new stkBigNumber("-123.456789")
oBig.SetPrecision(3)
? oBig.SValue()
#--> -123.457

#~> The method rounds 456789 to 457 because the next digit (6) is greater than or equal to 5.

# Executed in 0.001 seconds.

/*---------

# Precision Zero, Negative Number

oBig = new stkBigNumber("-123.987")
oBig.SetPrecision(0)
? oBig.SValue()
#--> -122

#~> The fractional part is dropped, and the integer part is decremented due to rounding.

# Executed in 0.001 seconds.

/*---------

# Edge Case with Large Negative Number and Rounding Backpropagation

	oBig = new stkBigNumber("-999.999999")
	oBig.SetPrecision(5)
	? oBig.SValue()
	#--> -1000.00000

#~> The rounding causes the fractional part to overflow, requiring the integer part to decrement.

/*---------

# Large Positive Number with Rounding Backpropagation

	oBig = new stkBigNumber("999999999.999999")
	oBig.SetPrecision(5)
	? oBig.SValue()
	#--> 1000000000.00000

#~> The rounding causes the fractional part to overflow, requiring the integer part to increment.

/*---------

# Test Case 9: Negative Number with Multiple Zeroes and Rounding

oBig = new stkBigNumber("-1000.000001")
oBig.SetPrecision(5)
? oBig.SValue()
#--> -1000.00000

#~> The fractional part is rounded, and since the result of rounding is 00000, it does not affect the integer part.

# Executed in almost 0 seconds.

/*========

# Spacification with Various Formats

oBig = new stkBigNumber("123456789.987654321")
? oBig.Spacified()
#--> 123_456_789.987654321

oBig.Spacify()
? oBig.SValue()
#--> 123_456_789.987654321

oBig.Unspacify()
? oBig.SValue()
#--> 123456789.987654321

# Executed in almost 0 seconds.

/*--------

# Restoration After Precision Change

oBig = new stkBigNumber("987654321.123456789")
oBig.SetPrecision(5)
? oBig.SValue()
#--> 987654321.12346

oBig.Restore()
? oBig.SValue()
#--> 987654321.123456789

# Executed in less than 0.001 seconds.

/*--------

# Testing with Symbols for Precision Settings

oBig = new stkBigNumber("12345.6789")
oBig.SetPrecision(:Max)
? oBig.SValue()
#--> 12345.6789000000000000000000000000
? oBig.Round()
#--> 28

oBig.SetPrecision(:Default)
? oBig.SValue()
#--> 12345.678900
? oBig.Round()
#--> 6

# Executed in less than 0.001 seconds.

/*--------

# Testing with Special Cases

oBig = new stkBigNumber("0")
oBig.Add("0")
? oBig.SValue()
#--> 0

oBig = new stkBigNumber("999999999999999999999999999999999999999")
oBig.Multiply("999999999999999999999999999999999999999")
oBig.Spacify()
? oBig.SValue()
#--> 999_999_999_999_999_999_999_999_999_999_999_999_998_000_000_000_000_000_000_000_000_000_000_000_000_001

# Executed in 0.023 seconds.

/*~~~~~~~~~~~~
*/
? NL + "~~~~~~~~~" + NL
? "Executed in " + (clock() - t0) / clockspersecond() + " seconds."
