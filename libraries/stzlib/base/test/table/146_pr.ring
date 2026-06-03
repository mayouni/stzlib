# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #146.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindCell( "Red" ) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

# Same as:
? @@( o1.FindAllOccurrences( :Of = "Red") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindCells([ "Red", "White" ]) ) # Colors of the Tunisian flag :D
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ], [ 1, 4 ], [ 2, 1 ] ]

pf()
# Executed in 0.06 second(s)
