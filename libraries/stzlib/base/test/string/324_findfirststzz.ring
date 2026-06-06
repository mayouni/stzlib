# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #324.

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSTZZ("♥♥♥", :StartingAt = 6)
#--> [ 8, 10 ]

? o1.FindLastSTZZ("♥♥♥", :StartingAt = 6)
#--> [ 13, 15 ]

? o1.FindNthSTZZ(2, "♥♥♥", :StartingAt = 6)
#--> [ 13, 15 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.16 second(s) in Ring 1.17
