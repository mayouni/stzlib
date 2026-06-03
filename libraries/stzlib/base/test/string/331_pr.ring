# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #331.

load "../../stzBase.ring"

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstD("♥♥♥", :Backward)
#--> 13

? o1.FindLastD("♥♥♥", :Backward)
#--> 3

? o1.FindNthD(2, "♥♥♥", :Backward) + NL
#--> 8

? o1.FindD("♥♥♥", :Backward)
#--> [13, 8, 3 ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
