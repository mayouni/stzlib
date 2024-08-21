
load "../Common/stkRingLibs.ring"

load "../common/stkNumberCommons.ring"
load "../number/stkBigNumber.ring"

load "../error/stkError.ring"

decimals(3)
t0 = clock()

/*-------
*/
oBig1 = new stkBigNumber("324987182091876345.078")
oBig1.Divide("876234987333.9876673")
? oBig1.SValue()
#--> 370890.442392

oBig2 = new stkBigNumber("1.5")
oBig2.Divide("0.3")
? oBig2.SValue()
#--> 5

oBig3 = new stkBigNumber("1")
oBig3.Divide("3")
? oBig3.SValue()
#--> 0.333333

/*-------

oBig = new stkBigNumber("324_987_182_091_876_345.078")

? oBig.SValue()
#--> 324987182091876345.078

oBig.Add("122_333_987_337_132_339.987653")
? oBig.SValue()
#--> 447321169429008685.065653

oBig.Subtract("122_333_987_337_132_339.987653")
? oBig.SValue() + NL
#--> 324987182091876345.078


oBig.Multiply("122_333_987_337_132_339.987653")
? oBig.SValue()
#--> 39756977818757922769007316455505225.287321934

oBig.Multiply("2")
? oBig.SValue() + NL
#--> 795139556375158458500672312034291657065.10336

oBig.Divide("2")
? oBig.SValue()
#--> 90070405001030306060105.10336

#--> Online tool: 29,245,068,083,430,251,952,666,249,756,015.33646722
*/

? NL + "~~~" + NL
? (clock() - t0) / clockspersecond()
