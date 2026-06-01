# Narrative
# --------
# Using ..ST() + ..D() + ZZ() prefixes
#
# Extracted from stzStringTest.ring, block #319.

load "../../../stzBase.ring"


pr()

#                     3 5
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindNthSTDZZ(2, "♥♥♥", :StartingAt = 10, :Backward)
#--> [ 3, 5 ]

? o1.FindFirstSTDZZ("♥♥♥", :StartingAt = 5, :Backward)
#--> [ 3, 5 ]

? o1.FindLastSTDZZ("♥♥♥", :StartingAt = :LastChar, :Backward)
#--> [ 3, 5 ]

pf()
# Executed in 0.08 second(s) in Ring 1.21
