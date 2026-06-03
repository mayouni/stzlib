# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #121.

load "../../stzBase.ring"

pr()

o1 = new stzString("aa***aa**aa***aa")

? @@( o1.BoundedBy("aa") )
#--> [ "***", "**", "***" ]

pf()
# Executed in 0.08 second(s)
