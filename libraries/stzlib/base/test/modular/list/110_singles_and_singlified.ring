# Narrative
# --------
# SINGLES AND SINGLIFIED
#
# Extracted from stzlisttest.ring, block #110.

load "../../../stzBase.ring"


pr()

? Q(['alone']).IsSingle()
#--> TRUE

o1 = new stzList([ 1, ['alone1'], 3, ['alone2'], 5, ['alone2'], 7:9 ])

? o1.ContainsSingles()
#--> TRUE

? @@( o1.FindSingles() )
#--> [ 2, 4, 6 ]

? @@( o1.Singles() )
#--> [ [ "alone1" ], [ "alone2" ], [ "alone2" ] ]

? @@( o1.SinglesU() )
#--> [ [ "alone1" ], [ "alone2" ] ]

? @@( o1.SinglesZ() ) + NL
#--> [
#	[ [ "alone1" ], [ 2 ] ],
#	[ [ "alone2" ], [ 4, 6 ] ]
# ]

? @@( o1.Singlified() )
#--> [ [ 1 ], [ "alone1" ], [ 3 ], [ "alone2" ], [ 5 ], [ "alone2" ], [ 7 ] ]

pf()
# Executed in 0.05 second(s)
