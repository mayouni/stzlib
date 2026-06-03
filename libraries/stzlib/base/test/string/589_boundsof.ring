# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #589.
#ERR Error (R14) : Calling Method without definition: boundsof

load "../../stzBase.ring"

pr()

o1 = new stzString("Hello <<<Ring>>, the beautiful ((Ring))!")
? @@( o1.BoundsOf("Ring") )
#--> [ "<<<", ">>", "((", "))" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20
