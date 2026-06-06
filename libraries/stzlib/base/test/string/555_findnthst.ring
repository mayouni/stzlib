# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #555.

load "../../stzBase.ring"

pr()

o1 = new stzString("12*45*78*90")

? o1.FindNthST(2, "*", :StartingAt = 4)
#--> 9

? o1.FindFirstST("*", :StartingAt = 4)
#--> 6

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.20
