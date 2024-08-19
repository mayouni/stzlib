
load "../Common/stkRingLibs.ring"
load "../common/stkNumberCommons.ring"
load "../number/stkBigNumber.ring"
load "../error/stkError.ring"


oBig = new stkBigNumber("324_987_182_091_876_345.078")
? oBig.SValue()
#--> 324987182091876345.078

oOther = new stkBigNumber("89_988_373_988_123.78099")

? oBig.Add(oOther)
#--> 325_077_170_465_864_468.85899

? oBig.Subtract(oOther)
#--> 324897193717888221.298

? oBig.Multiply(oOther)
#--> 29_245_068_083_430_252_106_011_066_913_763_843.11296.
#--> Online tool: 29,245,068,083,430,251,952,666,249,756,015.33646722

