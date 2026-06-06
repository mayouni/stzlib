# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #202.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "ring", 5, 6, 7 ])

? @@( o1.AntiFind("ring") )
#--> [ 1, 2, 3, 5, 6, 7 ]

? @@( o1.AntiFindZZ("ring") )
#--> [ [ 1, 3 ], [ 5, 7 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
