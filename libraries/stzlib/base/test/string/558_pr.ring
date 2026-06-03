# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #558.

load "../../stzBase.ring"


o1 = new stzString("12*A*33*A*")

? @@( o1.FindSubStringBoundedBy("A", [ "*", "*" ]) )
#--> [ 4, 9 ]

? @@( o1.FindSubStringBoundedByAsSections("A", [ "*", "*" ]) )
#--> [ [ 4, 4 ], [ 9, 9 ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.22
