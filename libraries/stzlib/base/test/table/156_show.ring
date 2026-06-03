# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #156.

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
#        Red      White     Yellow
#       Blue        Red        Red
#       Blue      Green    Magenta
#      White       Gray      Black


o1.EraseCol(2)
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red               Yellow
#        Blue                  Red
#        Blue              Magenta
#       White                Black

o1.EraseCols([3 , 1])
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#                            
#                               
#                               
#                               
#    

pf()
# Executed in 0.20 second(s)
