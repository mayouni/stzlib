# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #111.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, [ "a", "b" ], 4, [ "c", "d"], [ "a", "b" ] ])
? o1.ContainsPairs()
#--> TRUE

? @@( o1.FindPairs() )
#--> [ 3, 5, 6 ]

? @@( o1.Pairs() )
#--> [ [ "a", "b" ], [ "c", "d" ], [ "a", "b" ] ]

? @@( o1.PairsU() )
#--> [ [ "a", "b" ], [ "c", "d" ] ]

? @@( o1.PairsZ() ) + NL
#--> [
#	[ [ "a", "b" ], [ 3, 6 ] ],
#	[ [ "c", "d" ], [ 5 ] ]
# ]

? @@( o1.Pairified() )
#--> [
#	[ 1, NULL ], [ 2, NULL ], [ "a", "b" ],
#	[ 4, NULL ], [ "c", "d" ], [ "a", "b" ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
