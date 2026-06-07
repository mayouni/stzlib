# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #312.
#ERR Error (R41) : Invalid numeric string

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthPrevious(:Last, "♥♥♥", :StartingAt = 12)
#--> 3

? o1.FindNthPrevious(:First, "♥♥♥", :StartingAt = 12)
#--> 8

pf()
# Executed in 0.06 second(s)
