# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #559.

load "../../../stzBase.ring"


o1 = new stzSplitter(5)

? @@( o1.SplitBefore(1) )
#--> [ [ 1, 5 ] ]

? @@( o1.SplitBefore(5) ) + NL
#--> [ [ 1, 4 ], [ 5, 5 ] ]

? @@( o1.SplitBeforePositions([ 3, 5 ]) ) + NL
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

? @@( o1.SplitBeforePositions([ 1, 5 ]) ) + NL
#--> [ [ 1, 4 ], [ 5, 5 ] ]

? @@( o1.SplitBeforePositions([ 1, 3, 5 ]) )
#--> [ [ 1, 2 ], [ 3, 4 ], [ 5, 5 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
