# Narrative
# --------
# Find and AntiFind in stzList
#
# Extracted from stzlisttest.ring, block #34.

load "../../stzBase.ring"


pr()

o1 = new stzList([ "1", "2", "♥", "4", "5", "♥", "6", "7", "♥", "9" ])

? @@( o1.Find("♥") ) + NL
#--> [ 3, 6, 9 ]

? @@( o1.AntiFind("♥") ) + NL
#--> [ 1, 2, 4, 5, 7, 8, 10 ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) before
