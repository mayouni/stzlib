# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #141.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.SectionContains( [1, 2], [3, 2], "Red" )
#--> TRUE

? o1.SectionContains( [1, 2], [3, 2], :SubValue = "ed" )
#--> TRUE

pf()
# Executed in 0.04 second(s)
