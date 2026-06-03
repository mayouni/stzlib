# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #16.
#ERR Error (R3) : Calling Function without definition: arandomsectionz

load "../../stzBase.ring"

pr()

Q([ "1", "2", "3", "4", "5", "6", "7", "8", "9" ]) {

	? @@( ARandomSection() ) + NL
	#--> [ "7", "8" ]

	? @@( ARandomSectionZ() ) + NL
	#--> [ [ "3", "4", "5", "6", "7", "8" ], 3 ]

	? @@( ARandomSectionZZ() ) + NL
	#--> [ [ "1", "2", "3", "4", "5", "6" ], [ 1, 6 ] ]


	? @@( SomeRandomSections() ) + NL
	#--> [
	# 	[ "1", "2", "3", "4", "5", "6" ],
	# 	[ "5", "6", "7", "8", "9" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8" ],
	# 	[ "1", "2", "3", "4", "5", "6", "7", "8", "9" ],
	# 	[ "8", "9" ], [ "4", "5", "6" ]
	# ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [
	# 	[ [ "5", "6", "7", "8" ], 5 ],
	# 	[ [ "1", "2", "3", "4", "5", "6", "7" ], 1 ]
	# ]

	? @@( SomeRandomSectionsZZ() ) + NL
	#--> [
	# 	[ [ "6", "7", "8" ], [ 6, 8 ] ],
	# 	[ [ "7", "8" ], [ 7, 8 ] ]
	# ]

	? @@( NRandomSections(2) ) + NL
	#--> [ [ "1", "2", "3", "4", "5" ], [ "4", "5", "6" ] ]

	? @@( NRandomSectionsZ(2) ) + NL
	#--> [ [ [ "3", "4", "5", "6" ], 3 ], [ [ "8", "9" ], 8 ] ]

	? @@( NRandomSectionsZZ(2) )
	#--> [
	# 	[ [ "4", "5" ], [ 4, 5 ] ],
	# 	[ [ "1", "2", "3", "4" ], [ 1, 4 ] ]
	# ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
