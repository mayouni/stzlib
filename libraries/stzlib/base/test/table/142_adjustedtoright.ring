# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #142.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "Red", "PALETTE" ])
? o1.AdjustedToRight()
#--> [
#	"    Red",
#	"PALETTE"
# ]

pf()
# Executed in 0.08 second(s)
