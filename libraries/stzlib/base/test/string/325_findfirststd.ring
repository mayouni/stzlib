# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #325.
#ERR Error (R14) : Calling Method without definition: findfirststd

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstSTD("♥♥♥", :StartingAt = 12, :Backward)
#--> 8

? o1.FindLastSTD("♥♥♥", :StartingAt = 12, :Backward)
#--> 3

? o1.FindNthSTD(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> 3

pf()
# Executed in 0.02 second(s) in Ring 1.21
