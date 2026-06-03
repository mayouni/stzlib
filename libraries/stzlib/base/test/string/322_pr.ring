# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #322.

load "../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 3, :Direction = :Forward)
#--> [ 8, 10 ]

? o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 5, :Direction = :Forward)
#--> [ 8, 10 ]

? o1.FindLastSTDZZ("♥♥♥", :StartingAt = 6, :Direction = :Forward)
#--> [ 13, 15 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
