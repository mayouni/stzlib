# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #357.

load "../../../stzBase.ring"


o1 = new stzString("hello ring what a nice ring!")

? @@( o1.FindAsSections( "ring" ) )
#--> [ [7, 10], [24, 27] ]

? @@( o1.FindAsAntiSections("ring") )
#--> [ [1, 6], [11, 23], [28, 28] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
