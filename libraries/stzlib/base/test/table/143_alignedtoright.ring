# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #143.
#ERR Error (R14) : Calling Method without definition: alignedtoright

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ ":PALETTE1", "Red", "Blue", "Blue", "White" ])
? o1.AlignedToRight()
#--> [
# 	":PALETTE1",
# 	"      Red",
# 	"     Blue",
# 	"     Blue",
# 	"    White"
# ]

pf()
# Executed in 0.06 second(s)
