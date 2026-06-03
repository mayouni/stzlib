# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #328.

load "../../stzBase.ring"


#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

? o1.FirstSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", [ 8, 10 ] ]

? o1.LastSTDZZ("♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", [ 3, 5 ] ]

? o1.NthSTDZZ(2, "♥♥♥", :StartingAt = 12, :Backward)
#--> [ "♥♥♥", [ 3, 5 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.18
