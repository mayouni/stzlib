# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #124.

load "../../../stzBase.ring"


o1 = new stzString("aa***aa**aa***aa")

? @@( o1.FindAnyBoundedBy("aa") )
#--> [ 3, 8, 12 ]

? @@( o1.FindAnyBoundedByAsSections("aa") )
#--> [ [ 3, 5 ], [ 8, 9 ], [ 12, 14 ] ]

pf()
# Executed in 0.10 second(s)
