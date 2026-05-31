# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #22.

load "../../../stzBase.ring"


o1 = new stzListOfLists([
	[ :is, :will, :can, :some, :can ],
	[ :can, :will ],
	[ :will ]
])

? @@NL( o1.Index() ) + NL
#--> [
#	[ "is", [ 1 ] ],
#	[ "will", [ 1, 2, 3 ] ],
#	[ "can", [ 1, 1, 2 ] ], [ "some", [ 1 ] ]
# ]

? @@NL( o1.IndexXT() )
#--> [
#	[ "is", 	[ [ 1, 1 ] ] ],
#	[ "will", 	[ [ 1, 2 ], [ 2, 2 ], [ 3, 1 ] ] ],
#	[ "can", 	[ [ 1, 3 ], [ 1, 5 ], [ 2, 1 ] ] ],
#	[ "some", 	[ [ 1, 4 ] ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
