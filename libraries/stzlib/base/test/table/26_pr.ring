# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #26.

load "../../stzBase.ring"


o1 = new stzTable([
	:COL1 = [ "I", 1 ],
	:COL2 = [ AHeart(), 2 ],
	:COL3 = [ "Ring", 3 ],
	:COL4 = [ "Language", 4 ]
])

? o1.ShowXT([
	:Separator 	  = "   ",
	:Alignment 	  = :Right,
		
	:UnderLineHeader  = TRUE,
	:UnderLineChar 	  = "-",
	:IntersectionChar = " ",
		
	:ShowRowNumbers   = FALSE
])

#--> COL1   COL2   COL3       COL4
#    ----- ------ ------ ---------
#       I      ♥   Ring   Language
#       1      2      3          4

pf()
# Executed in 0.10 second(s)
