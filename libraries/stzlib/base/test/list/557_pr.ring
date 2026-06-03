# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #557.

load "../../stzBase.ring"


o1 = new stzSplitter(5)

? @@( o1.SplitAt(1) )
#--> [ [ 2, 5 ] ]

? @@( o1.SplitAt(5) ) + NL
#--> [ [ 1, 4 ] ]

? @@( o1.SplitAtPositions([ 3, 5 ]) ) + NL
#--> [ [ 1, 2 ], [ 4, 4 ] ]

? @@( o1.SplitAtPositions([ 1, 5 ]) ) + NL
#--> [ [ 2, 4 ] ]

? @@( o1.SplitAtPositions([ 1, 3, 5 ]) )
#--> [ [ 2, 2 ], [ 4, 4 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
