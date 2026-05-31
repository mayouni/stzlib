# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #143.

load "../../../stzBase.ring"


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
