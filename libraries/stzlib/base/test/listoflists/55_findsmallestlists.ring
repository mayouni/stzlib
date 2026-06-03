# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #55.

load "../../stzBase.ring"

pr()

o1 = new stzLists([ 1:2, 1:5, 1:3, 1:2 ])

? @@( o1.FindSmallestLists() ) + NL
#--> [1, 4]

? @@( o1.SmallestLists() ) + NL
#--> [ [1, 2], [1, 2] ]

? @@( o1.SmallestListsZ() )
#--> [ [ [ 1, 2 ], 1 ], [ [ 1, 2 ], 4 ] ]

pf()
# Executed in 0.07 second(s)
