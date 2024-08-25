
load "../Common/stkRingLibs.ring"

load "../common/stkNumberCommons.ring"
load "../number/stkBigNumber.ring"

load "../error/stkError.ring"

decimals(3)
t0 = clock()


/*-------

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

# Executed in 0.033 seconds.

/*-------

oBig = new stkBigNumber("324_987_182_091_876_345.078")

? oBig.SValue()
	#--> 324987182091876345.078
	? oBig.Round() + NL
	#--> 3

oBig.Add("122_333_987_337_132_339.987653")
	? oBig.SValue()
	#--> 447321169429008685.065653
	? oBig.Round() + NL
	#--> 6

oBig.Subtract("122_333_987_337_132_339.987653")
	? oBig.SValue()
	#--> 324987182091876345.078
	? oBig.Round() + NL
	#--> 3

oBig.Multiply("122_333_987_337_132_339.987653")
	? oBig.SValue()
	#--> 39756977818757922769007316455505225.287321934
	? oBig.Round() + NL
	#--> 9

oBig.Multiply("2")
	? oBig.SValue()
	#--> 795139556375158458500672312034291657065.10336
	? oBig.Round() + NL
	#--> 5

oBig.Divide("2")
	? oBig.SValue()
	#--> 397569778187579229250336156017145828532.55168
	? oBig.Round() + NL
	#--> 5

# Executed in 0.031 seconds.

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

oBig = new stkBigNumber("123_456_789.87")

	? oBig.Rounded(1)
	#--> 123456789.9

	? oBig.Rounded(0) + NL
	#--> 123456790

oBig = new stkBigNumber("123_456_789")
	? oBig.RoundedTo(0)
	#--> 123456789

	? oBig.RoundedTo(1)
	#--> 123456789.0

	? oBig.RoundedTo(3)
	#--> 123456789.000

# Executed in 0.015 seconds.

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
	? oBig.RoundedTo(3)
	#--> -12345567980117.877
	
	# Verify that the original precision hasn't changed
	? oBig.Precision()
	#--> 7
	
	# Round the number to 3 decimal places and modify the original object
	oBig.RoundTo(3)
	
	# Display the new value of the number after rounding
	? oBig.SValue()
	#--> -12345567980117.877
	
	# Verify that the precision has been updated to 3
	? oBig.Precision()
	#--> 3
	
	# Display the initial value of the number (before any rounding)
	? oBig.SInitialValue()
	#--> -12345567980117.8765454
	
	# Display the full precision of the initial value
	? oBig.FullPrecision()
	#--> 7

# Executed in 0.001 seconds.

/*------

oBig = new stkBigNumber("-123_456_789")
	? oBig.RoundedTo(0) + NL
	#--> -123456789

/*------ #narration
*/

# This code demonstrates the flexibility of the stkBigNumber class
# in handling different precision levels. It shows how to:

# 1. Check and use maximum and default precision settings.
# 2. Create a BigNumber with a specific value.
# 3. View and modify the precision of the number.
# 4. Access the full precision of the original number.
# 5. Use symbolic precision settings (:Max and :Default).
# 6. Restore the number to its original state.
# 7. Observe how different precision settings affect the displayed value.

# The class maintains the original value while allowing for different
# representations based on the specified precision, providing a powerful
# tool for numeric operations requiring varying levels of precision.

# Display the maximum allowed precision for BigNumber
? BigNumberMaxPrecision()
#--> 28

# Display the default precision for BigNumber
? BigNumberDefaultPrecision() + NL
#--> 6

# Create a new BigNumber object
oBig = new stkBigNumber("12_345_549.878546")

# Display the current precision of the number (defaults to 6)
? oBig.Precision() # Or Round()
#--> 6

# Set the precision to 2 decimal places
oBig.SetPrecision(2) # Or SetRound()
# Display the value after setting precision
? oBig.SValue()
#--> 12345549.88

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
#--> 12345549.8800000000000000000000000000

# Restore the number to its original state
oBig.Restore()

# Set the precision to the default value
oBig.SetPrecision(:Default)
# Display the new precision
? oBig.Precision()
#--> 6

# Display the value with default precision
? oBig.SValue()
#--> 12345549.878546

# Set the precision back to 2 decimal places
oBig.SetPrecision(2)
# Display the final value
? oBig.SValue()
#--> 12345549.88

# Executed in 0.001 seconds.

/*~~~~~~~~~~~~
*/
? NL + "~~~~~~~~~" + NL
? "Executed in " + (clock() - t0) / clockspersecond() + " seconds."
