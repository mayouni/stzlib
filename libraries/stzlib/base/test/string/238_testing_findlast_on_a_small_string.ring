# Narrative
# --------
# # Testing FindLast() on a small string
#
# Extracted from stzStringTest.ring, block #238.

load "../../stzBase.ring"

pr()

StartProfiler()
#                    2    7
o1 = new stzString("•♥••••♥••")
? o1.FindLast("♥")
#--> 7

? o1.FindLast("_")
#--> 0

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.21
