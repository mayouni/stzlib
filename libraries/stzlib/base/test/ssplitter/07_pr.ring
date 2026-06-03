# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #7.

load "../../stzBase.ring"


o1 = new stzSplitter(10)

? @@( o1.SplitToNParts(2) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

? @@( o1.SplitToPartsOfNPositions(2) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]

#--

? @@( o1.SplitToPartsOfNPositions(3) ) # Same as SplitToPartsOfExactlyNPositions
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

? @@( o1.SplitToPartsOfNPositionsXT(3) ) + NL # XT ~> adds the remaining part
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
