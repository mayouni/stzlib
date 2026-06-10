# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #201.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 , "*", 5, 6, "*", 8 ])

? @@( o1.SplitAt("*") )
#--> [ [ 1, 2, 3 ], [ 5, 6 ], [ 8 ] ]

? @@( o1.SplitAtZZ("*") ) + NL
#--> [ [ 1, 3 ], [ 5, 6 ], [ 8, 8 ] ]

? @@( o1.AntiPositions([ 4, 7 ]) )
#--> [ 1, 2, 3, 5, 6, 8 ]

? @@( o1.AntiPositionsZZ([ 4, 7 ]) )
# [ [ 1, 3 ], [ 5, 6 ], [ 8, 8 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
