
load "../Common/stkRingLibs.ring"

load "../common/stkNumberCommons.ring"
load "../number/stkBigNumber.ring"

load "../error/stkError.ring"

decimals(3)
t0 = clock()

oBig = new stkBigNumber("324_987_182_091_876_345.078")
? oBig.SValue()
#--> 324987182091876345.078

oBig.Add("122_333_987_337_132_339.987653")
? oBig.SValue()
#--> 447321169429008685.065653

oBig.Subtract("122_333_987_337_132_339.987653")
? oBig.SValue() + Nl
#--> 324987182091876345.078


oBig.Multiply("122_333_987_337_132_339.987653")
? oBig.SValue()
#--> 39756977818757922769007316455505225.287321934

oBig.Multiply("2")
? oBig.SValue()
#--> 795139556375158458500672312034291657065.10336



#--> Online tool: 29,245,068,083,430,251,952,666,249,756,015.33646722

? NL + "~~~" + NL
? (clock() - t0) / clockspersecond()
