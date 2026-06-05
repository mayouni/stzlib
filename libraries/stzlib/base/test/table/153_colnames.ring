# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #153.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

o1.AddCol( :PALETTE4 = [ "Magenta", "Blue", "White", "Red" ])

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3", "palette4" ]

? o1.HasColName(:PALETTE4)
#--> TRUE

? @@( o1.Col(:PALETTE4) )
#--> [ "Magenta", "Blue", "White", "Red" ]

o1.RemoveCol(:PALETTE4)

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3" ]

pf()
# Executed in 0.04 second(s)
