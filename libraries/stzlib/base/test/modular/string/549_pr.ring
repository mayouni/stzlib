# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #549.

load "../../../stzBase.ring"


o1 = new stzString("***ONE***TWO***THREE***")

? @@( o1.FindMany([ "ONE", "TWO", "THREE"]) ) + NL
#--> [ 4, 10, 16 ]

? @@( o1.SplitQ(:Using = "***").Content() ) + NL
#--> [ "ONE", "TWO", "THREE" ]

? @@( o1.FindAnyBoundedByIB("**") ) + NL
#--> [ 1, 7, 13 ]

? @@( o1.FindAnyBoundedByIBZZ("**") )
#--> [ [ 1, 8 ], [ 7, 14 ], [ 13, 22 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.14 second(s) in Ring 1.18
