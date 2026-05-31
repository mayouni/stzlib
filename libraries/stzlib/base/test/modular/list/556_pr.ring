# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #556.

load "../../../stzBase.ring"


o1 = new stzSplitter(5)

? @@( o1.GetPairsFromPositions([ 3, 5 ]) )
#--> [ [ 1, 3 ], [ 3, 5 ] ]

? @@( o1.GetPairsFromPositions([ 1, 4 ]) ) + NL
#--> [ [ 1, 4 ], [ 4, 5 ] ]

pf()
# Executed in 0.02 second(s).
