# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #560.

load "../../stzBase.ring"


o1 = new stzSplitter(5)

? @@( o1.SplitAfter(3) )
#--> [ [ 1, 3 ], [ 4, 5 ] ]

? @@( o1.SplitAfter(1) )
#--> [ [ 1, 1 ], [ 2, 5 ] ]

? @@( o1.SplitAfter(5) ) + NL
#--> [ [ 1, 5 ] ]

? @@( o1.SplitAfterPositions([ 3, 5 ]) ) + NL
#--> [ [ 1, 3 ], [ 4, 5 ] ]

? @@( o1.SplitAfterPositions([ 1, 5 ]) ) + NL
#--> [ [ 1, 1 ], [ 2, 5 ] ]

? @@( o1.SplitAfterPositions([ 1, 3, 5 ]) )
#--> [ [ 1, 1 ], [ 2, 3 ], [ 4, 5 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
