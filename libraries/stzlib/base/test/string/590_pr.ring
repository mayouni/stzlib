# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #590.

load "../../stzBase.ring"


o1 = new stzString("Ring>>, the nice ---Ring---, the beautiful ((Ring")
? @@( o1.BoundsOf("Ring") )
#--> [ "---", "---" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.09 second(s) in ring 1.20
