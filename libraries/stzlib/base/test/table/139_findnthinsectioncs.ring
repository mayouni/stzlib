# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #139.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindNthInSectionCS(2, :From = :FirstCell, :To = [3, 3], "red", :CS = FALSE) )
#--> [2, 2]

? @@( o1.FindFirstInSection(:From = :FirstCell, :To = [3, 3], "Red") )
#--> [1, 1]

? @@( o1.FindLastInSection(:From = :FirstCell, :To = [3, 3], "Red") )
#--> [3, 2]

pf()
# Executed in 0.03 second(s) in Ring 1.17
# Executed in 0.22 second(s) in Ring 1.20
