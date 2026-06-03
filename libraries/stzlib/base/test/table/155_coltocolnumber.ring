# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #155.
#ERR Error (R14) : Calling Method without definition: thesecolstocolsnumbers

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ColToColNumber(2)
#--> 2

? o1.ColToColNumber(:PALETTE2) + NL
#--> 2

? o1.TheseColsToColsNumbers([:PALETTE3, :PALETTE1, 2])
#--> [ 3, 1, 2 ]

pf()
# Executed in 0.03 second(s)
