# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #329.

load "../../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FindFirstAsSection("♥♥♥")
#--> [3, 5]

? o1.FindFirstAsSectionST("♥♥♥", :StartingAt = 5)
#--> [8, 10]

pf()
# Executed in 0.01 second(s) in Ring 1.21
