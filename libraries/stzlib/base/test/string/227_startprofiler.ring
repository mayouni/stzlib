# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #227.

load "../../stzBase.ring"


o1 = new stzString('This[@i] = This[@i +   1] + @i -    2')
? o1.NumbersAfter("@i")
#--> [ "1", "-2" ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.18
