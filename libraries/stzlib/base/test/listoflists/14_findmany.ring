# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #14.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, 4, "|", 2, 3, 4, 5, "|", 2, 3, 4, 5 ])

? @@( AreContiguous( o1.FindManyQ([ 2, 3, 4 ]) / 3 ) ) + NL
#--> TRUE

? @@( o1.FindMany([ 2, 3, 4 ]) ) + NL
#--> [ 2, 3, 4, 6, 7, 8, 11, 12, 13 ]

? @@( o1.FindManyQ([ 2, 3, 4 ]) / 3 ) + NL
#--> [ [ 2, 3, 4 ], [ 6, 7, 8 ], [ 11, 12, 13 ] ]

? AreContiguous( [ [ 2, 3, 4 ], [ 6, 7, 8 ], [ 11, 12, 13 ] ] )
#--> TRUE

pf()
# Executed in 0.05 second(s) in Ring 1.21
