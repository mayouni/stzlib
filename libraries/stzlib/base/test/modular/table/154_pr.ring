# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #154.

load "../../../stzBase.ring"


o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ColToColName(2)
#--> "palette2"

? o1.ColToColName(:PALETTE2) + NL
#--> "palette2"

? o1.TheseColsToColNames([3, :PALETTE1, 2])
#--> [ "palette3", "palette1", "palette2" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.20
