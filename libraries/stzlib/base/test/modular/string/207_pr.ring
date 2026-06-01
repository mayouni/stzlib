# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #207.

load "../../../stzBase.ring"

#                   1  4  78
o1 = new stzString("...ring...")

? o1.FindFirst("ring")
#--> 4

? @@( o1.FindAsSection("ring") )
#--> [ 4, 7 ]

? @@( o1.AntiFind("ring") )
#--> [1, 8]

? @@( o1.AntiFindAsSections("ring") )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18
