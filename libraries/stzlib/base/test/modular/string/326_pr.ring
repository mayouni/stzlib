# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #326.

load "../../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FirstSTDZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", 8 ]

? o1.LastSTDZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥"", 3 ]

? o1.NthSTDZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", 3 ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
