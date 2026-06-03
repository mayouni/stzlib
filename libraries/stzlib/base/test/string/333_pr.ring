# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #333.

load "../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstDZZ("♥♥♥", :Backward)
#--> [ 13, 15 ]

? o1.FindLastDZZ("♥♥♥", :Backward)
#--> [ 3, 5 ]

? o1.FindNthDZZ(2, "♥♥♥", :Backward)
#--> [ 8, 10 ]

? @@( o1.FindDZZ("♥♥♥", :Backward) )
#--> [ [ [ 13, 15 ], [ 8, 10 ], [ 3, 5 ] ]

pf()
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.36 second(s) in Ring 1.17
