# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #160.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Cell(3, 2)
#--> "Red"

? o1.Cell(1, 1)
#--> "Red"

? o1.Cell(0, 2)
#--> Error message: Array Access (Index out of range) 

pf()
# Executed in 0.02 second(s)
