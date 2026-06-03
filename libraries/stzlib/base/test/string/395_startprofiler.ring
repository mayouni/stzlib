# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #395.

load "../../stzBase.ring"


o1 = new stzString("ABC♥DEF★GHI♥JKL")
o1.ReplaceW(' Q(@char).IsNotLetter() ', :With = " ")
? o1.Content()
#--> ABC DEF GHI JKL

StopProfiler()
#--> Executed in 0.14 second(s)
