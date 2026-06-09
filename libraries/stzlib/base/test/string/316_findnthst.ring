# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #316.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthST(1, "♥♥♥", :StartingAt = 3)
#--> 3

? o1.FindNext("♥♥♥", :StartingAt = 3)
#--> 8

? o1.FindPrevious("♥♥♥", :StartingAt = 10)
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.18
