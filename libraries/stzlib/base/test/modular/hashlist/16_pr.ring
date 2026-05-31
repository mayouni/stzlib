# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #16.

load "../../../stzBase.ring"


o1 = new stzHashList([
	:one	= "will not be classified",
	:two	= [ "will", "be", "classified" ],
	:three	= [ "this", "one", "also", "will" , "be", "classsified" ],
	:four	= "nor this will be classified",
	:five	= [ "guess", "if", "this", "will", "be", "classified" ],
	:six	= "and this",
	:seven	= "and this" #TODO // use an object and test
])

? o1.HowManyKlassInLists()
#--> 9

? @@NL( o1.KlassifyItemsInLists() ) # Or KlassifyInLists()
#--> [
#	[ "will", 	[ [ 2, [ 1 ] ], [ 3, [ 4 ] ], [ 5, [ 4 ] ] ] ],
#	[ "be", 	 	[ [ 2, [ 2 ] ], [ 3, [ 5 ] ], [ 5, [ 5 ] ] ] ],
#	[ "classified",[ [ 2, [ 3 ] ], [ 5, [ 6 ] ] ] ],
#	[ "this", 	[ [ 3, [ 1 ] ], [ 5, [ 3 ] ] ] ],
#	[ "one", 		[ [ 3, [ 2 ] ] ] ],
#	[ "also", 	[ [ 3, [ 3 ] ] ] ],
#	[ "classsified", [ [ 3, [ 6 ] ] ] ],
#	[ "guess", 	 	[ [ 5, [ 1 ] ] ] ],
#	[ "if", 	 	[ [ 5, [ 2 ] ] ] ]
# ]

pf()
# Executed in 0.04 second(s)
