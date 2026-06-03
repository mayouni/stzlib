# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #147.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.NumberOfOccurrence( :Of = "Red" )
#--> 3

? @@( o1.FindNthCell(1, "Red") )
#--> [ 1, 1 ]

? @@( o1.FindNthCell(2, "Red") )
#--> [ 2, 2 ]

? @@( o1.FindLastCell( "Red" ) )
#--> [ 3, 2 ]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.38 second(s) in Ring 1.17
