# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #819.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(12)

? @@( o1.GetPairsFromPositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 3 ], [ 3, 8 ], [ 8, 10 ], [ 10, 12 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 8, 10 ]) )
#--> [ [ 1, 2 ], [ 3, 7 ], [ 8, 9 ], [ 10, 12 ] ]

pf()
# Executed in 0.03 second(s).
