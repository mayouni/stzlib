# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #321.
#ERR Error (R14) : Calling Method without definition: findnthszz

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSZZ(2, "♥♥♥", :StartingAt = 3)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindFirstSZZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", [8, 10] ]

? o1.FindLastSZZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", [13, 15] ]

pf()
# Executed in 0.05 second(s)
