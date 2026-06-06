# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #327.

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ 8, 10 ]

? o1.FindLastSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ 3, 5 ]

? o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> [ 3, 5 ]

pf()
# Executed in 0.08 second(s) in Ring 1.21
