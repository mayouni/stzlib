# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #70.

load "../../../stzBase.ring"


o1 = new stzListOfLists([
	[ "A", "♥", "B" ],
	[ "C", "D", "♥", "♥" ],
	[ "E", "♥", "A" ]
])

? @@( o1.FindInLists("♥") ) + NL
#--> [ [ 1, 2 ], [ 2, 3 ], [ 2, 4 ], [ 3, 2 ] ]

? @@( o1.FindInLists([ "A", "♥" ]) )
#--> [ [ 1, 1 ], [ 1, 2 ], [ 2, 3 ], [ 2, 4 ], [ 3, 2 ], [ 3, 3 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
