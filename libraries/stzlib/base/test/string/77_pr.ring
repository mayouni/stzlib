# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #77.

load "../../stzBase.ring"


o1 = new stzString("--ring--&__softanza__")

? @@( o1.FindExceptZZ([ "--", "__" ]) )
#--> [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ]

? @@( o1.Except([ "--", "__" ]) ) # Or SubStringsOtherThan()
#--> [ "ring", "&", "softanza" ]

pf()
# Executed in 0.14 second(s)
