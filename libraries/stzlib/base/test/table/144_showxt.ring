# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #144.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([
	:Separator = " | ",
	:IntersectionChar = "+",
	:Alignment = :Left,
	:UnderLineHeader,
	:ShowRowNumbers
])
#-->
#  # | PALETTE1 | PALETTE2 | PALETTE3
# ---+----------+----------+----------
#  1 | Red      | White    | Yellow   
#  2 | Blue     | Red      | Red      
#  3 | Blue     | Green    | Magenta  
#  4 | White    | Gray     | Black    
#  5 | Red      | White    | Yellow   
#  6 | Blue     | Red      | Red      
#  7 | Blue     | Green    | Magenta  
#  8 | White    | Gray     | Black    
#  9 | Red      | White    | Yellow   
# 10 | Blue     | Red      | Red      
# 11 | Blue     | Green    | Magenta  
# 12 | White    | Gray     | Black    

pf()
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.74 second(s) in Ring 1.17
