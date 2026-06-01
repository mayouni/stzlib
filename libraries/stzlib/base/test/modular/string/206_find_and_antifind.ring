# Narrative
# --------
# Find and AntiFind
#
# Extracted from stzStringTest.ring, block #206.

load "../../../stzBase.ring"


pr()

o1 = new stzString("ring...")
? @@( o1.FindAsSection("ring") )
#--> [1, 4]

? @@( o1.AntiFindAsSection("ring") )
#--> [5, 7]

pf()
#--> Executed in 0.07 second(s)
