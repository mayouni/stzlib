# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #76.

load "../../stzBase.ring"

pr()

o1 = new stzString("--ring--&--softanza--")

? @@( o1.FindExceptZZ("--") )
#--> [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ]

? @@( o1.Except("--") ) # Or SubStringsOtherThan()
#--> [ "ring", "&", "softanza" ]

pf()
# Executed in 0.10 second(s)
