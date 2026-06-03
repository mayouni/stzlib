# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #933.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(2)
? @@( o1.SplitToNParts(2) )
#--> [ [ 1, 1 ], [ 2, 2 ] ]

? @@( o1.SplitToPartsOfNItemsXT(2) )
#--> [ [ 1, 2 ] ]

pf()
# Executed in 0.03 second(s).
