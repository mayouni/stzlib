# Narrative
# --------
# Splitting a list into HALVES -- and the four ways Softanza lets you ask
# for them.
#
# The plain FirstHalf / SecondHalf split at floor(n/2): for a 9-item list
# the first half is items 1-4 and the second half is items 5-9 (the odd
# middle item goes to the SECOND half). The "XT" (extended) variants move
# the boundary up by one so the middle item lands in the FIRST half
# instead: FirstHalfXT = 1-5, SecondHalfXT = 6-9.
#
# On top of each half you can also ask for its POSITION (where it starts)
# or its SECTION (the [start, end] range), and Halves()/HalvesXT() return
# both halves together. The ...AndPositions / ...AndSections forms bundle
# each half with that metadata -- handy for slicing UIs and reports.
#
# Extracted from stzlisttest.ring, block #206.

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
	#--> [ [ [ "1", "2", "3", "4" ], 1 ], [ [ "5", "6", "7", "8", "9" ], 5 ] ]

	? @@( o1.HalvesAndPositionsXT() )
	#--> [ [ [ "1", "2", "3", "4", "5" ], 1 ], [ [ "6", "7", "8", "9" ], 6 ] ]

	? @@( o1.HalvesAndSections() )
	#--> [ [ [ "1", "2", "3", "4" ], [ 1, 4 ] ], [ [ "5", "6", "7", "8", "9" ], [ 5, 9 ] ] ]

	? @@( o1.HalvesAndSectionsXT() )
	#--> [ [ [ "1", "2", "3", "4", "5" ], [ 1, 5 ] ], [ [ "6", "7", "8", "9" ], [ 6, 9 ] ] ]

pf()
# Executed in almost 0 second(s)
