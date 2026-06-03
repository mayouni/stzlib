# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #157.

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

o1.EraseRow(2)
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#                               
#        Blue      Green    Magenta
#       White       Gray      Black

o1.EraseRows([3, 1])
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#                               
#                               
#                               
#       White       Gray      Black

pf()
# Executed in 0.18 second(s)
