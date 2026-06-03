# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #28.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "I", "♥" ],
	[ "G", "H", "R" ],
	[ "J", "K", "I", "N", "G" ]
])

? @@(o1.FindExtraItems()) + NL
#--> [
#	[ 1, [ ] ],
#	[ 2, [ 3, 4 ] ],
#	[ 3, [ 3 ] ],
#	[ 4, [ 3, 4, 5, 6 ] ]
# ]

? @@( o1.ExtraItems() )
#--> [ [ ], [ "I", "♥" ], [ "R" ], [ "I", "N", "G" ] ]

pf()
