# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #135.
#ERR Error (R14) : Calling Method without definition: findinsection

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindInSection([1,2], [3,2], "Red") )
#--> [ [ 2, 2 ], [ 3, 2 ] ]

pf()
# Executed in 0.02 second(s)
