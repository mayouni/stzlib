# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #136.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@NL( o1.SectionZ(:From = :FirstCell, :To = [3,2]) )
#--> [
#	[ [ 1, 1 ], "Red" ],
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 1 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

pf()
# Executed in 0.02 second(s)
