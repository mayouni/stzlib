# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #934.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(5)
? @@( o1.SplitToNParts(2) )
#--> [ [ 1, 3 ], [ 4, 5 ] ]

? @@( o1.SplitToPartsOfNItemsXT(5) )
#--> [ [ 1, 5 ] ]

? @@( o1.SplitToPartsOfNItemsXT(4) )
#--> [ [ 1, 4 ], [ 5, 5 ] ]

pf()
# Executed in 0.03 second(s).
