# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #818.

load "../../stzBase.ring"


o1 = new stzSplitter(10)

? @@( o1.GetPairsFromPositions([ 1, 3, 8 ]) )
#--> [ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 10 ] ]

pf()
