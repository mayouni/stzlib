

load "../Common/stkRingLibs.ring"
load "../common/stkNumberCommons.ring"
load "../number/stkBigNumber.ring"
load "../error/stkError.ring"


#NOTE Tool used to check result:
# https://www.calculator.net/big-number-calculator.htm

decimals(3)
t0 = clock()


#~~~~~

#===== BASIC OPERATIONS

/*----- Addition

? "Testing Addition"
oBig = new stkBigNumber("324_987_182_091_876_345.078")
oBig.Add("122_333_987_337_132_339.987653")
? oBig.SValue() + NL
#--> 447_321_169_429_008_685.065653

/*----- Subtraction

? "Testing Subtraction"
oBig = new stkBigNumber("324_987_182_091_876_345.078")

oBig.Subtract("122_333_987_337_132_339.987653")
? oBig.SValue() + NL
#--> 202_653_194_754_744_005.090347
/*
#----- Multiplication
? "Testing Multiplication"
oBig = new stkBigNumber("324_987_182_091_876_345.078")
oBig.Multiply("122_333_987_337_132_339.987653")
? oBig.SValue() + NL
#--> 39_756_977_818_757_922_769_007_316_455_505_225.287321934

#----- Division
? "Testing Division"
oBig = new stkBigNumber("324987182091876345.078")
oBig.Divide("876234987333.9876673")
? oBig.SValue() + NL
#--> 370890.442392

#===== COMPARING THE NUMBER WITH AN OTHER

# if both are equal ~> 0
# if the main number is smaller ~> -1
# if the main number is greater ~> 1

oBig = new stkBigNumber("12345.6789")
? oBig.CompareWith("12345.67890")
#--> 0

oBig = new stkBigNumber("9_999_999_999.9999")
? oBig.Compare("10_000_000_000.0001")
#--> 1

oBig = new stkBigNumber("1234.5670")
? oBig.Comparewith("1234.567")
#--> 0

oBig = new stkBigNumber("-12345.67")
? oBig.Comparewith("-12345.68")
#--> 1

oBig = new stkBigNumber("-9999.9999")
? oBig.Comparewith("9999.9999")
#--> -1

oBig = new stkBigNumber("000123.4500")
? oBig.Comparewith("123.45")
#--> 0

oBig = new stkBigNumber("1.0")
? oBig.Comparewith("1")
#--> 0

oBig = new stkBigNumber("-1.1")
? oBig.Comparewith("-1.01")
#--> -1

#===== ABSOLUTE VALUE

? "Testing absolute value:"
oBig = new stkBigNumber("12_198_576.9983")
? oBig.Abs() + nl
#--> 12_198_576.9983
/*
#===== PRECISION AND ROUNDING

#----- Setting Precision
? "Testing Precision Setting"
oBig = new stkBigNumber("12_345_549.878546")
oBig.SetPrecision(2)
? oBig.SValue() + NL
#--> 12_345_549.88

#----- Rounding
? "Testing Rounding"
oBig = new stkBigNumber("123_456_789.87")
? oBig.Rounded(1) + NL
#--> 123_456_789.9

#----- Precision with Symbols
? "Testing Precision with Symbols"
oBig = new stkBigNumber("12345.6789")
oBig.SetPrecision(:Max)
? oBig.SValue()
#--> 12345.6789000000000000000000000000
oBig.SetPrecision(:Default)
? oBig.SValue() + NL
#--> 12345.678900

#===== SPACIFICATION

#----- Spacification
? "Testing Spacification"
oBig = new stkBigNumber("324987182091876345.078")
? oBig.Spacified() + NL
#--> 324_987_182_091_876_345.078

#----- Unspacification
? "Testing Unspacification"
oBig = new stkBigNumber("12_345_678.67")
oBig.Unspacify()
? oBig.Value() + NL
#--> 12345678.67

#===== EDGE CASES

#----- Large Numbers
? "Testing Large Numbers"
oBig = new stkBigNumber("999_999_999_999_999_999.999")
oBig.Add("1")
? oBig.SValue() + NL
#--> 1_000_000_000_000_000_000.999

#----- Negative Numbers
? "Testing Negative Numbers"
oBig = new stkBigNumber("-12_345.6789")
oBig.Multiply("98_765.4321")
? oBig.SValue() + NL
#--> -1_219_326_311.12635269

#----- Zero
? "Testing Zero"
oBig = new stkBigNumber("0")
oBig.Add("0")
? oBig.SValue() + NL
#--> 0

#----- Very Large Numbers
? "Testing Very Large Numbers"
oBig = new stkBigNumber("999999999999999999999999999999999999999")
oBig.Multiply("999999999999999999999999999999999999999")
oBig.Spacify()
? oBig.SValue() + NL
#--> 999_999_999_999_999_999_999_999_999_999_999_999_998_000_000_000_000_000_000_000_000_000_000_000_000_001

#===== ADDITIONAL TESTS

#----- Division by Zero
? "Testing Division by Zero"
oBig = new stkBigNumber("100")
try
    oBig.Divide("0")
catch
    ? "Error caught!"
done
? ""
#--> Error caught: Division by zero is not allowed

#----- Negative Zero
? "Testing Negative Zero"
oBig = new stkBigNumber("-0")
? oBig.SValue() + NL
#--> 0

#----- Chained Operations
? "Testing Chained Operations"
oBig = new stkBigNumber("10")
oBig { Add("5") Multiply("2") Subtract("3") Divide("2") }
? oBig.SValue() + NL
#--> 13.5

#----- Comparison

? "Testing Comparison"
oBig = new stkBigNumber("100.001")
? (oBig.Compare("100") > 0)
? ""
#--> true

#----- Comparison

? "Testing power"

oBig = new stkBigNumber("714_218_155.17")
oBig.Power(4)
? oBig.SValue()
#--> 260_209_736_209_914_820_394_395_266_746_306_813.11789521

# Note that Ring native pow() function is incorrect
//? pow(714_218_155.17, 4)
#--> 260_209_736_209_914_749_458_901_418_828_103_680
#                        \_ Erronous result starts here
? ""

? "Testing power of a negative number" + NL

oBig = new stkBigNumber("-714_218_155.17")
oBig.Power(7)
? oBig.SValue() + NL
#--> -94_801_716_153_963_020_293_871_604_048_857_032_982_962_454_161_010_834_394_311_299.57107820225173

oBig = new stkBigNumber("-714_218_155.17")
oBig.Power(4)
? oBig.SValue()
#--> 94_801_716_153_963_020_293_871_604_048_857_032_982_962_454_161_010_834_394_311_299.57107820225173

#===== MORE SUBSTRACTIONS
*/

//-- Subtracting Two Positive Integers

oBig = new stkBigNumber("12_345_678_901_234_567_890")
           oBig.Subtract("9_876_543_210_987_654_321")

? oBig.Value()
#--> 2_469_135_690_246_913_569

//-- Subtracting a Larger Number from a Smaller One

oBig = new stkBigNumber("9_876_543_210_987_654_321")
	 oBig.Subtract("12_345_678_901_234_567_890")
? oBig.Value()
#--> -2_469_135_690_246_913_569

//-- Subtracting Two Decimal Numbers

oBig = new stkBigNumber("12345.6789")
	   oBig.Subtract("9876.54321")
? oBig.Value()
#--> 2469.13569

//-- Subtracting Negative Numbers

oBig = new stkBigNumber("-54321")
	  oBig.Subtract("-2345")
? oBig.Value()
#--> -51976

oBig = new stkBigNumber("-2345")
	  oBig.Subtract("-2345")
? oBig.Value()
#--> 0

oBig = new stkBigNumber("-2345")
	  oBig.Subtract("-54321")
? oBig.Value()
#--> 51976

//-- Subtracting a Positive Number from a Negative Number

oBig = new stkBigNumber("-12345")
oBig.Subtract("6789")
? oBig.Value()
#--> -19134

//-- Subtracting Numbers with Different Decimal Places

	oBig = new stkBigNumber("100.456")
	oBig.Subtract("99.9999")
	? oBig.Value()
	#--> 0.4561


#~~~~~

? NL + "~~~~~~~~~" + NL
? "Executed in " + (clock() - t0) / clockspersecond() + " seconds."
