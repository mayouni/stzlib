# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #137.
#ERR Error (R14) : Calling Method without definition: findinsectioncs

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", TRUE) )
#--> [ ]

? @@( o1.FindInSectionCS([1, 1], [3, 2], "Red", TRUE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", :CS = FALSE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

pf()
# Executed in 0.03 second(s)
