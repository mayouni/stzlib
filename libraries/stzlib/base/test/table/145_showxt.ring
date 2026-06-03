# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #145.
#ERR Error (R14) : Calling Method without definition: showxt

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([ :ShowRowNumbers, :IntersectionChar = "+" ])
#--> # | PALETTE1 | PALETTE2 | PALETTE3
#    -- ---------- ---------- ---------
#    1 |      Red |    White |   Yellow
#    2 |     Blue |      Red |      Red
#    3 |     Blue |    Green |  Magenta
#    4 |    White |     Gray |    Black

? @@NL( o1.SectionZ(:From = [1,2], :To = [3,2]) ) + NL
#--> [
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

? @@NL( o1.FindInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [
#	[ [ 1, 2 ], [ 4 ] ],
#	[ [ 1, 3 ], [ 4 ] ],
#	[ [ 1, 4 ], [ 5 ] ],
#	[ [ 2, 2 ], [ 2 ] ],
#	[ [ 2, 3 ], [ 3, 4 ] ],
#	[ [ 3, 1 ], [ 2 ] ],
#	[ [ 3, 2 ], [ 2 ] ]
# ]

? @@( o1.FindNthInSection(:First, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 1, 2 ], 4 ]

? @@( o1.FindNthInSection(:Last, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

? @@( o1.FindLastInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

pf()
# Executed in 0.20 second(s) in Ring 1.20
# Executed in 0.51 second(s) in Ring 1.17
