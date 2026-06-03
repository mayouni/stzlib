# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #330.
#ERR Error (R14) : Calling Method without definition: findfirstdzz

load "../../stzBase.ring"

pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstDZZ("♥♥♥", :Backward)
#--> [13, 15]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18
