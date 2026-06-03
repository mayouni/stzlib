# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #15.

load "../../stzBase.ring"


Q("123456789") {

	? @@( ARandomSection() ) + NL # Or ASection() or ASubString etc.
	#--> "234"

	? @@( ARandomSectionZ() ) + NL
	#--> [ "678", [ 6, 8 ] ]

	? @@( SomeRandomSections() ) + NL
	#--> [ "345678", "4567" ]

	? @@( SomeRandomSectionsZ() ) + NL
	#--> [ [ "3456", 3 ], [ "45", 4 ] ]

	? @@( SomeRandomSectionsZZ() )
	#--> [
	# 	[ "23456", [ 2, 6 ] ],
	# 	[ "12", [ 1, 2 ] ],
	# 	[ "78", [ 7, 8 ] ],
	# 	[ "34", [ 3, 4 ] ],
	# 	[ "89", [ 8, 9 ] ],
	# 	[ "4567", [ 4, 7 ] ],
	# 	[ "56", [ 5, 6 ] ]
	# ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 7.76 second(s) in Ring 1.19
