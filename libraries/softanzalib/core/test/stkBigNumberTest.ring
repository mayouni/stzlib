
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
*/

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

	? oBig.Rounded(0)
	#--> 1234567810

#~~~~~~~~~~~~

? NL + "~~~" + NL
? (clock() - t0) / clockspersecond()
