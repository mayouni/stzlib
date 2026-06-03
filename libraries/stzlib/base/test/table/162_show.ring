# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #162.
#ERR Error (R14) : Calling Method without definition: removecols

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#        Blue        Red        Red
#        Blue      Green    Magenta
#       White       Gray      Black

o1.RemoveCols([1, 2])
? o1.Show()
#--> PALETTE3
#    --------
#      Yellow
#         Red
#     Magenta
#       Black

o1.RemoveCol(:PALETTE3)
? o1.Show()
#--> COL1
#    ----
#    ""
      
pf()
#--> Executed in 0.15 second(s) in Ring 1.20
#--> Executed in 0.50 second(s) in Ring 1.17
