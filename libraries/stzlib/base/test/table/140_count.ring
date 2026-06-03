# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #140.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Count("Red")
#--> 3

? o1.Count(:SubValue = "e")
#--> 11

? o1.CountInCol(:PALETTE1, "Blue")
#--> 2

? o1.CountInRow(2, "Red")
#--> 2

? o1.CountInCells( [ [1, 1], [2,1], [2, 2] ], "Red" )
#--> 2

? o1.CountInCells( [ [1, 1], [2,1], [2, 2] ], :SubValue = "e" )
#--> 3

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.24 second(s) in Ring 1.17
