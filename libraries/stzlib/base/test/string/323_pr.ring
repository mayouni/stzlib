# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #323.

load "../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstST("♥♥♥", :StartingAt = 6)
#--> 8

? o1.FindLastST("♥♥♥", :StartingAt = 6)
#--> 13

? o1.FindNthST(2, "♥♥♥", :StartingAt = 6)
#--> 13

pf()
# Executed in 0.02 second(s) in Ring 1.21
