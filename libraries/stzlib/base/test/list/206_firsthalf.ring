# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #206.
#ERR Error (R14) : Calling Method without definition: firsthalfxt

load "../../stzBase.ring"

   

pr()

o1 = new stzList([ "1", "2", "3", "4", "5", "6", "7", "8", "9" ])

# FIRST HALF

	? @@( o1.FirstHalf() )
	#--> [ "1", "2", "3", "4" ]
	? @@( o1.FirstHalfXT() ) + NL
	#--> [ "1", "2", "3", "4", "5" ]
	
	? @@( o1.FirstHalfAndItsPosition() )
	#--> [ [ "1", "2", "3", "4" ], 1 ]
	? @@( o1.FirstHalfAndItsSection() ) + NL
	#--> [ [ "1", "2", "3", "4" ], [ 1, 4 ] ]
	
	? @@( o1.FirstHalfAndItsPositionXT() )
	#--> [ [ "1", "2", "3", "4", "5" ], 1 ]
	? @@( o1.FirstHalfAndItsSectionXT() ) + NL + NL + "---" + NL
	#--> [ [ "1", "2", "3", "4", "5" ], [ 1, 5 ] ]

# SECOND HALF

	? @@( o1.SecondHalf() )
	#--> [ "5", "6", "7", "8", "9" ]
	? @@( o1.SecondHalfXT() ) + NL
	#--> [ "6", "7", "8", "9" ]
	
	? @@( o1.SecondHalfAndItsPosition() )
	#--> [ [ "5", "6", "7", "8", "9" ], 5 ]
	? @@( o1.SecondHalfAndItsSection() ) + NL
	#--> [ [ "5", "6", "7", "8", "9" ], [ 5, 9 ] ]
	
	? @@( o1.SecondHalfAndItsPositionXT() )
	#--> [ [ "6", "7", "8", "9" ], 6 ]
	? @@( o1.SecondHalfAndItsSectionXT() ) + NL + NL + "---" + NL
	#--> [ [ "6", "7", "8", "9" ], [ 6, 9 ] ]

#-- THE TWO HALVES

	? @@( o1.Halves() )
	#--> [ [ "1", "2", "3", "4" ], [ "5", "6", "7", "8", "9" ] ]

	? @@( o1.HalvesXT() )
	#--> [ [ "1", "2", "3", "4", "5" ], [ "6", "7", "8", "9" ] ]

	? @@( o1.HalvesAndPositions() )
	#--> [
	# 	[ [ "1", "2", "3", "4" ], 1 ],
	# 	[ [ "5", "6", "7", "8", "9" ], 5 ]
	# ]

	? @@( o1.HalvesAndPositionsXT() )
	#--> [
	# 	[ [ "1", "2", "3", "4", "5" ], 1 ],
	# 	[ [ "6", "7", "8", "9" ], 6 ]
	# ]

	? @@( o1.HalvesAndSections() )
	#--> [
	# 	[ [ "1", "2", "3", "4" ], [ 1, 4 ] ],
	# 	[ [ "5", "6", "7", "8", "9" ], [ 5, 9 ] ]
	# ]

	? @@( o1.HalvesAndSectionsXT() )
	#--> [
	# 	[ [ "1", "2", "3", "4", "5" ], [ 1, 5 ] ],
	# 	[ [ "6", "7", "8", "9" ], [ 6, 9 ] ]
	# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.32 second(s) in Ring 1.17
