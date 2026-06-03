# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #318.

load "../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.NthSTZ(2, "♥♥♥", :StartingAt = 3)
#--> [ "♥♥♥", 8 ]

? o1.FirstSTZ("♥♥♥", :StartingAt = 5)
#--> [ "♥♥♥", 8 ]

? o1.LastSTZ("♥♥♥", :StartingAt = 6)
#--> [ "♥♥♥", 13 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.18
