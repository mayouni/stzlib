# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #133.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Find("Red") ) + NL
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindInCol(:PALETTE1, "Blue") ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInRow(2, "Red") ) 
#--> [ [ 2, 2 ], [ 2, 3 ] ]

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17
