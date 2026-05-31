# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #54.

load "../../../stzBase.ring"


o1 = new stzLists([ 1:2, 1:5, 1:3, 1:5 ])

? @@( o1.FindLargestLists() ) + NL
#--> [2, 4]

? @@( o1.LargestLists() ) + NL
#--> [ [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ] ]

? @@( o1.LargestListsZ() )
# [ [ [ 1, 2, 3, 4, 5 ], 2 ], [ [ 1, 2, 3, 4, 5 ], 4 ] ]

pf()
# Executed in 0.07 second(s)
