# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #404.

load "../../stzBase.ring"


o1 = new stzString("@item = This[ @i+1 ]")

? @@( o1.Numbers() ) + NL
#--> [ "+1" ]

? @@( o1.NumbersAfter("@i") )
#--> [ "+1" ]

pf()
# Executed in 0.12 second(s) in Ring 1.21
