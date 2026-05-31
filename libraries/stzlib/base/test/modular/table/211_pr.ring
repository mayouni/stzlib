# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #211.

load "../../../stzBase.ring"


? @@( @SortListsOn(2, [ [ 2, 2 ], [ 2, 4 ] ] ) ) # You can put the list before and it worlks!
#--> [ [ 2, 2 ], [ 2, 4 ] ]

? @@( @SortLists([ [ 2, 2 ], [ 2, 4 ] ]) ) # Uses SortOn(1, )
#--> [ [ 2, 2 ], [ 2, 4 ] ]

? @@( StzListOfPairsQ([ [ 2, 2 ], [ 2, 4 ] ]).SortedOn(2) ) + NL
#--> [ [ 2, 2 ], [ 2, 4 ] ]

# If the column of sort is the last column in the list, and
# if it is made of the same item, then sort is performed
# on the column just before

? @@NL( SortListsOn( 1, [

	[ 2, 3, 1 ],
	[ 4, 2, 1 ],
	[ 7, 4, 1 ]

]) ) + NL
#--> [
#	[ 2, 3, 1 ],
#	[ 4, 2, 1 ],
#	[ 7, 4, 1 ]
# ]

? @@NL( SortListsOn( 3, [

	[ 3, 1, 5 ],
	[ 7, 1, 3 ],
	[ 2, 1, 3 ]

]) ) + NL
#--> [
#	[ 2, 1, 3 ],
#	[ 7, 1, 3 ],
#	[ 3, 1, 5 ]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.11 second(s) in Ring 1.20
