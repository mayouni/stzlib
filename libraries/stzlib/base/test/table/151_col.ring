# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #151.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Col(2) )
#--> [ "White", "Red", "Green", "Gray" ]

? @@( o1.HasColName(:PALETTE2) )
#--> TRUE

? o1.HasColNames([ :PALETTE1, :PALETTE3 ]) #--> TRUE
#--> TRUE

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3" ]

pf()
# Executed in 0.02 second(s)
