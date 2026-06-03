# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #134.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Section([1,2], [3,2]) ) + NL
#--> [ "Blue", "Blue", "White", "Red", "Green", "Gray", "Yellow", "Red" ]

? @@Nl( o1.SectionZ([1,2], [3,2]) ) + NL
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

? @@( o1.SectionAsPositions([1,2], [3,2]) )
#--> [
#	[ 1, 2 ], [ 1, 3 ], [ 1, 4 ],
#	[ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
#	[ 3, 1 ], [ 3, 2 ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17
