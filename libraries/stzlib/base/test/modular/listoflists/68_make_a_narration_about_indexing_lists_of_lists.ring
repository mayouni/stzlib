# Narrative
# --------
# #TODO Make a narration about indexing lists of lists
#
# Extracted from stzlistofliststest.ring, block #68.

load "../../../stzBase.ring"


pr()

# In this example, we are going to index those three lists:

a1 = [ "A", "B", "A" ]
a2 = [ "A", "B", "C" ]
a3 = [ "C", "D", "A" ]

o1 = new stzListOfLists([ a1, a2, a3 ])

# First, we index them on the positions occuppied by each item
# in each list

? @@NL( o1.Index() ) + NL
#--> [
#	[ "A", [ 1, 1, 2, 3 ] ],
#	[ "B", [ 1, 2 ] ],
#	[ "C", [ 2, 3 ] ],
#	[ "D", [ 3 ] ]
# ]

? @@NL( o1.IndexXT() )
#--> [
#	[ "A", [ [ 1, 1 ], [ 1, 3 ], [ 2, 1 ], [ 3, 3 ] ] ],
#	[ "B", [ [ 1, 2 ], [ 2, 2 ] ] ],
#	[ "C", [ [ 2, 3 ], [ 3, 1 ] ] ],
#	[ "D", [ [ 3, 2 ] ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
