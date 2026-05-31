# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #8.

load "../../../stzBase.ring"


o1 = new stzSplitter(12)
? @@( o1.SplitToPartsOfNPositions(5) )
#--> [ [ 1, 5 ], [ 6, 10 ], [ 11, 12 ] ]

? @@( o1.SplitToPartsOfExactlyNPositions(5) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

pf()
# Executed in 0.09 second(s)
