
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
	? oBig.SValue() + NL
	#--> 795139556375158458500672312034291657065.10336
	? oBig.Round() + NL
	#--> 5

oBig.Divide("2")
	? oBig.SValue()
	#--> 397569778187579229250336156017145828532.55168
	? oBig.Round() + NL
	#--> 5

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

/*--------- #narration
*/

# stkBigNumber has 3 important criterias regarding rounding:
#	1. It maintains both the current value and the initial value (before any rounding).
#	2. It has methods for both viewing a rounded value (RoundedTo), without modifying
# 	   the number and actually rounding the number (RoundTo), and thus modifiying it.
# 	3. It keeps track of the current precision (current round) separately from the full
# 	   precision of the initial value.

# Let's check this by example.

oBig = new stkBigNumber("-123_456_789")
	? oBig.RoundedTo(0)
	#--> -123456789

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

# The above demonstration highlights the practical benefits of stkBigNumber:
#
# 1. Crucial for precise financial or scientific calculations.
# 2. Allows flexible reporting at different precisions without data loss.
# 3. Enables stepwise calculations with specific precision requirements.
# 4. Simplifies rounding by eliminating need for manual tracking of original values.
# 5. Reduces risk of precision loss in complex calculations.
# 6. Beneficial for auditing or tracing calculation evolution.
#
# This approach offers advantages over systems without such flexibility:
#
# - No need to create multiple copies for different precision requirements.
# - Ability to always refer back to the initial value.
# - Can observe how rounding affects the result at each step.
# - Provides a robust foundation for applications requiring high precision
#   and traceability in numeric operations.

#~~~~~~~~~~~~

? NL + "~~~" + NL
? (clock() - t0) / clockspersecond()
