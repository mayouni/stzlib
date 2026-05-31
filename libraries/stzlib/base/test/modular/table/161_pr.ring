# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #161.

load "../../../stzBase.ring"


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

o1.RemoveCol(1)
o1.RemoveCol(1)

? o1.Show()
#--> PALETTE3
#    --------
#      Yellow
#         Red
#     Magenta
#       Black

o1.RemoveCol(1)

o1.Show()
#--> COL1
#    ----
#    ""

o1.RemoveCol(2)
#--> Error message:
#    Incorrect value! n must correspond to a valid number of column.

pf()
# Executed in 0.12 second(s)
